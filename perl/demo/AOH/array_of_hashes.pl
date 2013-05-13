#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
# Declaration of an ARRAY OF HASHES
# array of hashes,means that this is a array,and it's element is hash.
my  @AoH = (
               {
                   Lead     => "fred",
                   Friend   => "barney",
               },
               {
                   Lead     => "george",
                   Wife     => "jane",
                   Son      => "elroy",
               },
               {
                   Lead     => "homer",
                   Wife     => "marge",
                   Son      => "bart",
               }
         );

print "@AoH\n";
for my $i (0 .. $#AoH){
#	print Data::Dumper->Dump([$AoH[$i]]);
	print Data::Dumper->Dump([$AoH[$i]]),"\n";
}
