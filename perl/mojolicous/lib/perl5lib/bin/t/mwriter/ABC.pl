#!/usr/bin/perl
use strict;
use warnings;
use Util::Run -child => 1,
              -mreader => 1;

my $logger  = $run_kernel->{logger};
my $mreader = $run_kernel->{mreader};
my $reader  = (values %$mreader)[0];
while(<$reader>) {
    chomp;
	$logger->debug("got $_");
	STDOUT->print("$_\n");
}
