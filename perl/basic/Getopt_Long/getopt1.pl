#!/usr/bin/perl -w
use strict;

use Data::Dump;
use Getopt::Long;

#########################################
# declare default values for variables
#########################################

my $data    = '';
my $length  = '';
my $verbose = '';
my $result  = GetOptions(
    "length=i" => \$length,    # numeric
    "file=s"   => \$data,      # string
    "verbose+" => \$verbose    # flag
);

&usage unless ( $length && $data );

#Data::Dump->dump($result);
if ($result) {
#################################################################
    # test perl getopt1.pl --length 10 --data dat --verbose 2
    # test perl getopt1.pl -length 10 -data dat -verbose 2
#################################################################
    print <<EOF;
length:		$length
file:		$data
verbose:	$verbose
EOF
}

sub usage {
    print <<EOF;
usage : getop1.pl -length num -file filename
EOF
    exit -1;
}
