#!/usr/bin/perl
use strict;
use warnings;
use Util::Run -child => 1,
              -mwriter => 1,

my $logger = $run_kernel->{logger};
my $mwriter = $run_kernel->{mwriter};

my $size   = keys %$mwriter;
my @module = keys %$mwriter;

while(<STDIN>) {
    chomp;
	my $midx = int(rand($size));
	my $m    = $module[$midx];
	$logger->debug("got $_, and write to stdout and $m");
	STDOUT->print("$_\n");
	$mwriter->{$m}->print($_);
}
