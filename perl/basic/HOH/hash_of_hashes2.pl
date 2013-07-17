#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

#Generation of a HASH OF HASHES
        # reading from file
        # flintstones: lead=fred pal=barney wife=wilma pet=dino
	my $file = "hash.txt";
	my %HoH=();
	my $who;
	my $key;
	my $value;
	my $field;
	open FN,$file or die "cannot open file:$!\n";
        #while ( <FN> ) {
        #    next unless s/^(.*?):\s*//;
        #    $who = $1;
        #    for $field ( split ) {
        #        ($key, $value) = split /=/, $field;
        #        $HoH{$who}{$key} = $value;
        #    }
	#print Data::Dumper->Dump([\%HoH]);
	#}

        # reading from file; more temps
	#my $rec;
        #while ( <FN> ) {
        #    next unless s/^(.*?):\s*//;
        #    $who = $1;
        #    $rec = {};
        #    $HoH{$who} = $rec;
        #    for $field ( split ) {
        #        ($key, $value) = split /=/, $field;
        #        $rec->{$key} = $value;
        #    }
        #}
	#print Data::Dumper->Dump([\%HoH]);

        # calling a function  that returns a key,value hash
	#暂时还没测试
        #for $group ( "simpsons", "jetsons", "flintstones" ) {
        #    $HoH{$group} = { get_family($group) };
        #}

        # likewise, but using temps
	#暂时还没测试
        #for $group ( "simpsons", "jetsons", "flintstones" ) {
        #    %members = get_family($group);
        #    $HoH{$group} = { %members };
        #}

        # append new members to an existing family
        my %new_folks = (
            wife => "wilma",
            pet  => "dino",
        );
	my $what;
        for $what (keys %new_folks) {
            $HoH{flintstones}{$what} = $new_folks{$what};
        }
	print Data::Dumper->Dump([\%HoH]);
