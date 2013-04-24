#!/usr/bin/perl
use strict;
use warnings;
use Util::Run -child   => 1,
              -mreader => 1;

use POE;
use POE::Wheel::ReadWrite;

my $logger = $run_kernel->{logger};
my $mreader = $run_kernel->{mreader};

POE::Session->create(
  inline_states => {
     _start   => \&on_start,
     on_init  => \&on_init,
     on_data  => \&on_data,
  },

);
$poe_kernel->run();

sub on_start {

  STDIN->blocking(0);
  $mreader->{stdin} = \*STDIN;
  for my $module (keys %$mreader) {
	   $mreader->{$module}->blocking(0);
       my $module_w = POE::Wheel::ReadWrite->new(
	     Handle     => $mreader->{$module},
	     InputEvent => 'on_data',
	     Filter     => POE::Filter::Line->new(),
      );
       $_[HEAP]{in}{$module_w->ID()} = [ $module_w, $module ];
  }

}

sub on_data {

  my ($input, $wid) = @_[ARG0, ARG1];
  my $wheel  = $_[HEAP]{in}{$wid}->[0];
  my $module = $_[HEAP]{in}{$wid}->[1];

  $logger->debug("got data[$input] from module[$module]");
}


