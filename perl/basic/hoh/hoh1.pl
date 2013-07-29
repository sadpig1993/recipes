#!/usr/bin/perl

use strict;
use warnings;

use Data::Dump;

# Declaration of a HASH OF HASHES,means that this is a hash,and it's key/value is hash again
my %HoH = (
    
    flintstones => {
        lead => "fred",
        pal  => "barney",
    },

    jetsons => {
        lead      => "george",
        wife      => "jane",
        "his boy" => "elroy",
    },
    
    simpsons => {
        lead => "homer",
        wife => "marge",
        kid  => "bart",
    },
    
);

#print Data::Dumper->Dump([\%HoH]);
#print Data::Dumper->Dump([%HoH]);	#注意这个和上行的区别
print "%HoH\n";    #cannot print the key/value of %HoH

##########根据一个key得到该key对应的value
# $tmpH 是一个哈希引用
my $tmpH = $HoH{flintstones};
warn "-----哈希引用使用------";
print "$tmpH\n";
#Data::Dump->dump($tmpH);
print "$tmpH->{lead}\n";

##########根据多个key得到多个key对应的value list
# @tmpa 是一个引用数组
my @tmpa = @HoH{ "flintstones", "simpsons" };

warn "-----数组引用使用-------";
print "$tmpa[0]->{pal}\n";
print "$tmpa[1]->{wife}\n";

#print Data::Dumper->Dump([@tmpa]);
#print "@tmpa\n";
#print "$tmpa[0]\n"; #打印出来的是地址
#print "$tmpa[1]\n"; #打印出来的是地址

#Data::Dump->dump( [ $tmpa[0] ] );
#Data::Dump->dump( [ $tmpa[1] ] );
