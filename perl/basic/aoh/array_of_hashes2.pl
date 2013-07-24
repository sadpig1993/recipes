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
######打印哈希数组的每个元素,即哈希
for my $i (0 .. $#AoH){
#	print Data::Dumper->Dump([$AoH[$i]]);
	print Data::Dumper->Dump([$AoH[$i]]),"\n";
}
######打印哈希数组的每个哈希的key/value
print "44444444\n";
for my $i (0 .. $#AoH){
	foreach my $key ( keys %{$AoH[$i]}){
	#print Data::Dumper->Dump([$AoH[$i]]),"\n";
	print "$key => ${$AoH[$i]}{$key}\n";
	#print "$key\n";
	}
}

 # add key/value to an element
     # $AoH[0]{pet} = "dino";
     #  $AoH[2]{pet} = "santa's little helper";
	#for my $i (0 .. $#AoH){
	#	print Data::Dumper->Dump([$AoH[$i]]);
	#	print Data::Dumper->Dump([$AoH[$i]]),"\n";
	#}

 # Access and Printing of an ARRAY OF HASHES
        # one element
	print "1111111\n";
        $AoH[0]{lead} = "hello";
	print "$AoH[0]{lead}\n";

        # another element
	print "2222222\n";
        $AoH[1]{Lead} =~ s/(\w)/\u$1/;
	print "$AoH[1]{Lead}\n";

        # print the whole thing with refs
	print "3333333\n";
	my $href;
	my $role;
        for $href ( @AoH ) {
            print "{ ";
            for $role ( keys %$href ) {
                print "$role=$href->{$role} ";
            }
            print "}\n";
        }

	 # print the whole thing with indices
	print "555555555555\n";
        for my $i ( 0 .. $#AoH ) {
            print "$i is { ";
            for my $role ( keys %{ $AoH[$i] } ) {
                print "$role=$AoH[$i]{$role} ";
            }
            print "}\n";
        }

        # print the whole thing one at a time
	print "666666666666\n";
        for my $i ( 0 .. $#AoH ) {
            for my $role ( keys %{ $AoH[$i] } ) {
                print "elt $i $role is $AoH[$i]{$role}\n";
            }
        }

