#!/usr/bin/perl
use strict;
use warnings;
use Util::Run -child => 1,
              -mwriter => 1;

#############################################################
#
#   -----------
#   |  Zmain |          
#   ----------- 
#       |
#       |               -----------------|
#       |               |                |       
#       |              \|/               |
#       |      --------------------      |
#       |------|      mwriter     |      |
#       |      --------------------      |
#       |       |       |        |       |
#       |       A       B        C       |
#       |       |       |        |       |
#       |      \|/     \|/      \|/      |
#       |     --------------------       |
#       |-----|      mreader     |-------|
#       |     -------------------- 
#############################################################
#  mwriter read from stdin, and  randomly dispatch it (A,B,C)
#############################################################
my $logger  = $run_kernel->{logger};
my $mwriter = $run_kernel->{mwriter};

my $size   = keys %$mwriter;
my @module = keys %$mwriter;

while(my $line = <STDIN>) {
    $line =~ s/\s+$//g;
	my $midx = int(rand($size));
	my $m    = $module[$midx];
	$logger->debug("got $line, and write to stdout and $m");
	$mwriter->{$m}->print("$line\n");
	sleep 1;
}


