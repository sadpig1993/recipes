#!/usr/bin/perl

use strict;
use warnings;

my @arr = qw/hello world/;
print "the array is @arr\n";
print "the array is " . join($",@arr) . "\n";
