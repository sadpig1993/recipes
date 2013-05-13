#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

# Declaration of a HASH OF HASHES,means that this is a hash,and it's key/value is hash again
my %HoH = (
	flintstones => {
		lead      => "fred",
		pal       => "barney",
	},
	jetsons     => {
		lead      => "george",
		wife      => "jane",
		"his boy" => "elroy",
	},
	simpsons    => {
		lead      => "homer",
		wife      => "marge",
		kid       => "bart",
	},
);
#print Data::Dumper->Dump([\%HoH]);
#print Data::Dumper->Dump([%HoH]);	#注意这个和上行的区别
print "%HoH\n";	#cannot print the key/value of %HoH

##########根据一个key得到该key对应的value
my $tmpH = $HoH{flintstones} ;
#print Data::Dumper->Dump([$tmpH]);
print "$tmpH\n";

##########根据多个key得到多个key对应的value list
my @tmpa = @HoH{"flintstones","simpsons"};
#print Data::Dumper->Dump([@tmpa]);
#print "@tmpa\n";
#print "$tmpa[0]\n"; #打印出来的是地址
#print "$tmpa[1]\n"; #打印出来的是地址
print Data::Dumper->Dump([$tmpa[0]]);
print Data::Dumper->Dump([$tmpa[1]]);
