package Util::Box;

use strict;
use warnings;

use POE;
use POE::Wheel::ReadWrite;

sub new {
  my $class = shift;
  my $self  = bless {}, $class;
  unless($self->_init(@_)) {
    return undef;
  }
}

sub _init {
  return shift;
}

sub _process {
  return shift;
}

sub poe_run {
  my $self = shift;
  while(1) {
    unless($self->_process()) {
      return undef;
    }
  }
}

sub loop_run {
  my $self = shift;
  POE::Session->create(
    package_states => [
      _start   => \&_on_start,
    ],
    args => [ $self ],
  );
  $poe_kernel->run();
}

sub _on_start {
}


1;
