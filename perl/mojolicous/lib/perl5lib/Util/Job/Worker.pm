package Util::Job::Worker;

use POE;
use POE::Wheel::ReadWrite;
use POE::Filter::Reference;

sub new {

  my $class = shift;
  my $args  = { @_ };
  my $data  = {};
  my $self = bless $data, $class;

  $self->_init($args);

  return $self;
}

sub _init {
  my $self = shift;
  return $self;
}

#
#  'node_a'  => '192.168.1.29:4541'
#  'node_b'  => '192.168.1.29:4542'
#
sub add_server {

  my $self = shift;
  my $args = { @_ };

  $self->{'_svr_nodes'} = $args;
  return $self;
}

#
#  'svc_name'  => 'package'
#
sub add_service {
  my $self = shift;
  my $args = { @_ };
  $self->{'_svc_list'} = $args;

  for (keys %$args) {
    my $pkg = $args->{$_};
    eval "use $pkg;";
    if($@) {
      warn "load pkg $pkg error:";
      warn "$@";
      return undef;
    }
  }
  return $self;
}

#
#
#
sub run {

  my $self = shift;
  POE::Session->create(
    "inline_states" => {
      '_start'      => \&on_start,

      'on_register' => \&on_register,

      'on_svr_data' => \&on_svr_data,
      'on_svr_req'  => \&on_svr_req,
      'on_svr_fail' => \&on_svr_fail,
     
    },
    args => [$self],
  );
  $poe_kernel->run();
}

sub on_start {
  
  my $self = $_[ARG0];
  my $heap = $_[HEAP];
  $heap->{worker} = $self;

  for my $svr (keys %{$self->{'_svr_nodes'}}) {

    my $address = $self->{'_svr_nodes'}->{$svr};
    my $wheel = POE::Wheel::ReadWrite->new(
      Handle       => IO::Socket::INET->new($address),
      InputEvent   => 'on_svr_data',
      ErrorEvent   => 'on_svr_fail',
      InputFilter  => POE::Filter::Reference->new(),
      OutputFilter => POE::Filter::Reference->new(),
    );

    $heap->{server}->{$wheel->ID()) = [$svr, $wheel];
  }

  $_[KERNEL]->yield('on_register' => $self);

}

#
#
#
sub on_register {

  my $heap = $_[HEAP];
  my $self = $heap->{'worker'};

  warn "on_register called";

  my $svc_list = $self->{'_svc_list'};
  my $svr_list = $heap->{'server'};

  for my $svc_name (keys %{$svc_list}) {

    my $pkg = $svc_list->{$svc_name};
    my $reg_frame = {
      'svc' => $svc_name,
    };

    #
    # send registration frame
    #
    for my $svr (keys %$svr_list) {
      $heap->{'tmp1'}->{$svr}->{$svc_name} = 0;
      warn "begin register svc $svc_name[$pkg] to $svr...";
      $svr->put($reg_frame);
    }
  }

}

sub on_svr_data {

  my $heap  = $_[HEAP];
  my $frame = $_[ARG0];
  my $wid   = $_[ARG1];
  my $tmp   = $heap->{'tmp'};

  warn "on_svr_data called";

  #
  # reg response
  # {
  #   status => 0,
  #   svc    => servce.name
  # }
  #
  if ( $frame->{'status'} == 0) {

    my $svr   = $heap->{server}->{$wid}->[0];
    delete $tmp->{$svr}->{{$frame}->{'svc'}};
 
    my $tmp_svr = $tmp->{$svr};

    unless( scalar %$tmp_svr) {  # now all service is registerred
      delete $heap->{'tmp'}->{$svr};
      # 
      # re-install state machine for this svr wheel
      #
      my $wheel = $heap->{server}->{$wid}->[1];
      $wheel->event('InputEvent' => 'on_svr_req');

      unless(%$tmp) {
        warn "register to all server success";
        delete $heap->{'tmp'};
      }
    }
  }
}

#
# jobserver request
#
sub on_svr_req {

  my $heap  = $_[HEAP];
  my $frame = $_[ARG0];
  my $wid   = $_[ARG1];
  my $svr   = $heap->{'server'}->{$wid}->[0];
  my $w     = $heap->{'server'}->{$wid}->[1];

  my $self  = $heap->{'worker'};

  warn "on_svr_req: request from $svr call_id: ", $frame->{'id'};
  #  request:
  #  {
  #     call  =>  svc_name
  #     req   =>  {}
  #     id    =>  calling_id
  #  }
  #  request:
  #  {
  #     id    => calling_id
  #     res   => {}
  #  }
  #
  my $handler = $self->{'_svc_list'}->{$frame->{'call'}};
  my $req     = $frame->{'req'};
  my $res;
  {
    no strict;
    $res = $handler->($req);    # call service handler
  }
  unless ($res) {
    $w->put({ id => $frame->{'id'}, status => 1, });
  } else {
    $w->put({ id => $frame->{'id'}, status => 0, res => $res});
  }
}

sub on_svr_fail {
   warn "Connection failed or ended.  Shutting down...\n";
   delete $_[HEAP]{client};
}


