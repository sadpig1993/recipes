#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

#  Declaration of a HASH OF ARRAYS
=p
hasf of arrays,means that this is a hash,and the values of it's key is arrays
=cut
my %HoA = (
           flintstones   => [ "fred", "barney" ],
           jetsons       => [ "george", "jane", "elroy" ],
           simpsons      => [ "homer", "marge", "bart" ],
);
print Data::Dumper->Dump([\%HoA]);
