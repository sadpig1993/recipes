#!/usr/bin/perl
use strict;
use warnings;

# this is comment
print("hello world!\n");


print('hello world!\n');
print 42;
print "\n";


########################scalars######################
my $animal = "camel";
my $answer = 40;
print $animal;
print "\nThe animal is $animal\n";
print "The square of $answer is ", $answer * $answer ,"\n";
#print;	#prints contents of $_ by default

########################arrays########################
my @animals = ("camel","ama","owl");
my @numbers = (23, 42, 69);
my @mixed =("camel",42, 1.23);
print $animals[0];	# start with $ get just a single value out of the array
print "\t";
print $numbers[0];
print "\t";
print $mixed[$#mixed];	# $#array tells last index element of array
print "\n";
print @animals[0,1];	# get multiple values from an array 
print "\n";
print @animals[0..2];
print "\n";
print @animals[1..$#animals];
print "\n";

#######################hashes##########################
#my %fruit_color =("apple","red","banana","yellow"); 
my %fruit_color =(
	apple => "red",
	banana => "yellow"
	); 
print $fruit_color{"apple"};	# gives "red"
#print $fruit_color("apple");	# ( ) in there is not valid
print "\n";
my @fruits = keys %fruit_color;	# @fruits is "applebanana"
my @colors = values %fruit_color;	# @colors is "redyellow"
print @fruits[0..$#fruits];	# gives the value of @fruits
print "\n";
print @colors[0..$#colors];	# gives the value of @colors
print "\n";

#######################reference########################
my $variables = {
	scalar => {
		description => "single item",
		sigil => '$',
		}, 

	array => {
		description => "ordered list of items",
		sigil => '@',
		},

	hash  => {
		description => "key/value pairs",
		sigil => '%',
		},
	};
print "Scalars begin with a $variables->{'scalar'}->{'sigil'}\n";
print "array begin with a $variables->{'array'}->{'sigil'}\n";
print "hash begin with a $variables->{'hash'}->{'sigil'}\n";
#######################conditional and looping constructs##################
my $cond=1;
if ($cond){
	print "this is true\n";
}

$cond=0;
unless ($cond){		#### unless (condition) equals to if (!condition)
	print "I have bananas\n";
}

#while (1){
#print "LA LA LA\n";
#}

#until ($cond){		#### until (condition) equals to while (!condition)
#print "LA LA LA\n";
#}

foreach my $ele (@animals){
	print "This element is $ele\n";
}
foreach my $key (keys %fruit_color){
	print "The value of $key is $fruit_color{$key}\n";
}

##########################Builtin operators and functions#####################
###########Arithmetic#############
my $a = 1000,$b=100;
my $c = $a + $b ;
print "$a + $b = $c\n";
$c = $a - $b ;
print "$a - $b = $c\n";
$c = $a * $b ;
print "$a * $b = $c\n";
$c = $a / $b ;
print "$a / $b = $c\n";
############numeric comparison#########
if($a > $b){ 
	print "$a greater than $b\n"; 
}

if($a != $b){ 
	print "$a inequality $b\n"; 
}
if($b <= $a){ 
	print "$b less than or equal $a\n"; 
}
###########string comparison###########
my $str1 = 'hello world.';
my $str2 = 'hello wow';
if ($str1 le $str2){
	print "$str1 less than or equal $str2\n";
}
else{
	print "$str1 greater than or equal $str2\n";
}
