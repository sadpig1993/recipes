#!/usr/bin/env perl

#
# perl split.pl test/aa
#
#
use strict;
use warnings;
use Data::Dump;

while(<>){

    my $row = [ split '\|' ] ;
     
    foreach my $a ( @$row ) {
        if ( defined $a ) {
            printf "$a is defined\n";
        }
    }
    Data::Dump->dump( $row ) ; 
}
