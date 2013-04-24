package Util::Job::Server;

use strict;
use warnings;

use POE;
use POE::Wheel::ReadWrite;
use POE::Wheel::ListenAccept;
use POE::Filter::Reference;
use POE::Filter::JSON;
use Util::SHTTPD;


#
#  client protocol
#---------------------------------------
#  poe    => 192.168.1.29:7676
#  http   => 192.168.1.29:8989
#  json   => 192.168.1.29:4848
#
#  worker protocol
#---------------------------------------
#  worker  => 192.168.1.29:4747
#  
#
sub new {
  my $class = shift;
  my $args  = { @_ };
  my $self = bless $args, $class;
  $self->_init();
  return $self;
}

sub _init {
}

sub run {
  my $self = shift;
  POE::Session->create(
    'inline_states' => {
      '_start'                  => \&on_start,
      'on_jclient_accept'       => \&on_jclient_accept,
      'on_jclient_accept_error' => \&on_jclient_accept_error
      'on_jclient_input'        => \&on_jclient_input,
      'on_jclient_error'        => \&on_jclient_error,
      'on_jclient_flush'        => \&on_jclient_flush,
    },
    args => [$self],
  );
  $poe_kernel->run;
}

sub on_start {

  my $self = $_[ARG0];
  $_[HEAP]{'self'} = $self;  # self save to heap

  if ($self->{'worker'}) {
    my $wwheel = POE::Wheel::ListenAccept->new(
      AcceptEvent => "on_wclient_accept",
      ErrorEvent  => "on_wclient_error",
      Handle => IO::Socket::INET->new(
        LocalAddr  => $addr,
        LocalPort  => $port,
        Listen     => 5,
      ), 
    );
  }
  if ($self->{'json'}) {
    my $jwheel = POE::Wheel::ListenAccept->new(
      AcceptEvent => "on_jclient_accept",
      ErrorEvent  => "on_jclient_accept_error",
      Handle => IO::Socket::INET->new(
        LocalAddr  => $addr,
        LocalPort  => $port,
        Listen     => 5,
      ), 
    );
  }
  if ($self->{'http'}) {
  }
  if ($self->{'poe'}) {
    my $pwheel = POE::Wheel::ListenAccept->new(
      AcceptEvent => "on_pclient_accept",
      ErrorEvent  => "on_pclient_accept_error",
      Handle => IO::Socket::INET->new(
        LocalAddr  => $addr,
        LocalPort  => $port,
        Listen     => 5,
      ), 
    );
  }
}

sub on_jclient_accept {


  my $client_socket = $_[ARG0];
  my $io = POE::Wheel::ReadWrite->new(
    Handle => $client_socket,
    InputEvent => "on_jclient_input",
    ErrorEvent => "on_jclient_error",
    FlushEvent => "on_jclient_flush",
  );
  $_[HEAP]{jclient}{ $io->ID() } = $io;

}

sub on_jclient_accept_error {
}

sub on_jclient_input {

  my $self  = $_[HEAP}{'self'};
  my $input = $_[ARG0];
  my $wid   = $_[ARG1];

  my $resource = $self->{'resource'};
  my $svc_map  = $self->{'svc_map'};

  #
  #  call => svc_name
  #  req  => {}
  #
  my $svc_list = $svc_map->{$input->{'call'}}
  unless(@$svc_list) {
    warn "no such service: ", $input->{'call'};
    $_[HEAP]{jclient}{$wid}->put();
  }
  my $jid = $self->{'resource'}->{'jid'}++;
  
}

sub on_jclient_error {
}

sub on_jclient_flush {
  my $wid $_[ARG0];
  delete $_[HEAP]{jclient}{$wid};
}



