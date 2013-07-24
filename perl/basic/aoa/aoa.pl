#!/usr/bin/perl

use strict;
use warnings;

use Data::Dump;

=p 多行注释
array of arrays,means that the array's element
is arrays。数组的数组即二维数组
=cut

my @AoA = ( [ 2, 3 ], [ 4, 5, 7 ], [ 1 .. 6 ] );
print "$AoA[1][2]\n";    #打印出 [4,5,7]中的7
print @AoA, "\n";        #打印出数组元素的地址

#print @AoA[0],"\n";	#打印@AoA第一个元素的地址
#print @AoA[1],"\n";	#打印@AoA第二个元素的地址
#print @AoA[2],"\n";	#打印@AoA第三个元素的地址
#print "@{@AoA[0]}\n";
print "@{$AoA[0]}\n@{$AoA[1]}\n@{$AoA[2]}\n";

my $i;
my @array;

=p
#####1#####
for $i (1..10){
	@array = 0 .. $i;
	$AoA[$i] = [ @array];
	#print "$AoA[$i]\n" #打印出$AoA[$i]的地址
	print "@{$AoA[$i]}\n";
}
=cut

=p
#####2#####
for $i (1..10){
	@array = 0 .. $i;
	@{$AoA[$i]} = @array;
	#print "$AoA[$i]\n" #打印出$AoA[$i]的地址
	print "@{$AoA[$i]}\n";
}
=cut

#####3#####
for $i ( 1 .. 10 ) {
    @array   = 0 .. $i;
    $AoA[$i] = \@array;    #用到引用，数组的引用
                           #print "$AoA[$i]\n" 	#打印出$AoA[$i]的地址
    print "@{$AoA[$i]}\n";
}

##########another demo#####
#$aref为数组引用
my $aref = [
    [ "fred",   "barney", "pebbles", "bambam", "dino", ],
    [ "homer",  "bart",   "marge",   "maggie", ],
    [ "george", "jane",   "elroy",   "judy", ],
];

#print $aref[2][2];	    #wrong
#print $aref->[2][2];	#print elroy
#print $$aref[2][2];	#print elroy $$aref[2][2]先进行解引用,解引用后
#aref等同与二维数组，所以print $aref[2][2] ok
