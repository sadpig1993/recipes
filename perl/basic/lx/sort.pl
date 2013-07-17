#!/usr/bin/perl

use strict;
use warnings;

my @files ;
@files = qw/hello ha boy/;
my @articles ;
 # sort lexically
@articles = sort @files;
print "@articles\n" ;

# same thing, but with explicit sort routine
@articles = sort {$a cmp $b} @files;
print "@articles\n";

 # now case-insensitively
@articles = sort {uc($a) cmp uc($b)} @files;
print "@articles\n";

# same thing in reversed order
@articles = sort {$b cmp $a} @files ;
print "@articles\n";


@files = qw/11 12 9 8/ ;
# sort numerically ascending	对数字递增排序	
@articles = sort {$a <=> $b} @files;
print "@articles\n";

# sort numerically descending	对数字递减排序
@articles = sort {$b <=> $a} @files;
print "@articles\n";
