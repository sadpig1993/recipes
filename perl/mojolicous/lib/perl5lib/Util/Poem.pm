package Util::PoCo::Poem;

use strict;
use warnings;

use POE::Session;


our $poem_kernel = bless {
  session    => undef,
  master     => undef,
}, __PACKAGE__;

sub import {
  my $pkg = shift;
  my $callpkg = (caller)[0];
  no strict;
  *{"$callpkg\::poem_kernel"} = \$poem_kernel;
}


#
#  alias   =>  pmaster
#  logger  =>  $logger
#
sub spawn {

  my $class  = shift;
  my $args   = { @_ };
  my $logger = $args->{logger};

  my $mpoe = POE::Session->create(

    'inline_states' => {
      '_start'  => sub {
        $_[KERNEL]->alias_set($args->{alias});
      },

      '_child' => sub {
        my ($reason, $child) = @_[ARG0, ARG1];
        my $sid = $child->ID();
        if ($reason eq 'lose') {
          $logger->debug("poe session[$sid] lost");
          for (keys %{$poem_kernel->{session}}) {
            delete $poem_kernel->{session}->{$_} and last if $poem_kernel->{session}->{$_}->[0] == $sid;
          }
        }
        return 1;
      },

      '_stop' => sub {
        $logger->debug("master_poe _stop called sender ID:", $_[SENDER]->ID());
      },
      ########################################
      #
      ########################################
      'on_del_session' => \&on_del_session,
      'on_add_session' => \&on_add_session,

      ########################################
      #
      ########################################
      'on_add_wheel'   => \&on_add_wheel,
      'on_del_wheel'   => \&on_del_wheel,
    }
  );

  unless($mpoe) {
    $logger->error("POE::Sesion->create failed");
    return undef;
  }
  $logger->debug("master POE is created successfully");
  return $mpoe;
}


#
#
#
sub on_del_session {

  my $sname  = $_[ARG0];
  my $logger = $_[HEAP]{logger};

  $logger->warn("begin send on_stop to child session[$sname]...");
  unless($_[KERNEL]->post($poem->{session}->{$sname}->[1] => 'on_stop')) {
    $logger->error( "can not post on_stop to $sname");
    return undef;
  }

  rename "$upload/session/$sname",  "$upload/sessoin/$sname.del" if -d $upload;

  return 1;
}

#
# 
#  {
#     name   => 'xxx_session'
#     create => sub {
#               }
#  }
#
#
sub on_add_session {

  my $config = $_[ARG0];
  my $logger = $_[HEAP]{logger};

  my $name   = delete $config->{'name'};
  my $create = delete $config->{'create'};  # must have an on_stop state
  my $s = $create->();
  unless($s) {
    $logger->error("can not create session[$name]");
    return 1;
  } 
  $poem->{session}->{$name} = [$s->ID(), $s];

  $logger->debug("on_add_sesson created an session[$name]");
  return 1;
}

#
#
#
sub on_add_wheel {

  my $ses    = $_[SESSION];
  my $config = $_[ARG0];
  my $logger = $_[HEAP]{logger};

  my $states = $config->{'states'};
  my $wname  = $config->{'name'};
  my $wheel  = $config->{'wheel'};
  my $args   = $config->{'args'};
  my $heap   = $config->{'heap'};
  my $yield  = $config->{'yield'};

  my $errmsg;

  if ( exists $_[HEAP]{wheel}{$wname} ) {
    $errmsg = "wheel $wname already exists";
    goto FAIL;
  }

  #
  # check heap
  #
  if ($heap ) {
    my ($k, $v) = ($heap->{key}, $heap->{val}); 
    if ( exists $_[HEAP]{$k} ) {
      $errmsg = "can not set heap{$k}";
      goto FAIL;
    }
    $_[HEAP]{$k} = $v;
  }

  #
  # check states
  #
  my $st = $ses->[2];
  for (keys %$states) {
    if ( exists $st->{$_} ) {
      $errmsg = "state[$_] already exists";
      goto FAIL;
    }
  }

  #
  # install states
  #
  for (keys %$states) {
    unless($_[KERNEL]->state($_, $states->{$_})) {
      $errmsg = "install state[$_] failed: [$!]";
      # goto FAIL;
    }
  }
  my @installed = keys %$states;
  $logger->debug("now states:[" , keys %{$_[SESSION]->[2]} , "]");

  #
  # create wheel
  #
  my $w = $wheel->($args);
  unless($w){
    $errmsg = "wheel creation failed";
    goto FAIL;
  }
  $_[HEAP]{wheel}{$wname} = [$w, \@installed];

  if ($yield) {
    $logger->debug("begin yield to $yield->{'name'}...");
    $_[KERNEL]->yield($yield->{'name'}, $yield->{'args'});
  }

  return 1;
  
FAIL:
  $logger->error($errmsg);
 
  # uninstall states 
  for (keys %$states) {
    if ( exists $st->{$_} ) {
      $_[KERNEL]->state($_);
    }
  }
  return undef;

}

#
#
#
sub on_del_wheel {

  my $config = $_[ARG0];
  my $logger = $_[HEAP]{logger};

  my $name = $config->{'name'};
  my $heap = $config->{'heap'};

  my $w  = $_[HEAP]{wheel}{$name};
  my $st = $w->[1];

  #
  # uninstall states
  #
  for (@$st) {
    $_[KERNEL]->state($_);
  }
  $logger->debug("now states:[" , keys %{$_[SESSION]->[2]} , "]");

  delete $_[HEAP]{wheel}{$name};
  delete $_[HEAP]{$heap} if defined $heap;
  rename "$upload/wheel/$name",  "$upload/wheel/$name.del" if -d $upload;
  return 1;

}



1;

__END__

head1 NAME

=head1 SYNOPSIS


=head1 DESCRIPTION

=over 4

=back

