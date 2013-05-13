#!/usr/bin/perl

use strict;
use warnings;

=p
my %h = ( a => 7, b => 8, c => 9 );

my @l = qw(a b c);

my @a = @h{ @l
  }; # -- when put array in hash's iterator and put the '@' at ahead of the hash varaible，it means produce a array from hash：naming hash slice"
print @a, "\n";
=cut

#example1====

my %hash = (
    'one' => {
        'first'  => 1,
        'second' => 2,
    },
    'two' => {
        'third'  => 3,
        'fourth' => 4,
    }
);

my $key = 'one';
my @list = ( 'first', 'second' );

## 用到hash slice
print $_, "\n" for @{ $hash{$key} }{@list};    #print 1
                                               #      2

#example2====

=p
my %foo = ( a => 4, b => 5, c => 6 );
my $href = \%foo;
print @foo{ 'a', 'b' }, "\n";                  # print 45
my %bar = ( foo => $href );                    # foo is now a reference in %bar
print @{ $bar{foo} }{ 'a', 'b' }, "\n";
print ${ $bar{foo} }{'a'}, "\n";
print ${ $bar{foo} }{'b'}, "\n";
###通过引用和箭头来访问数据
print $bar{foo}->{'a'}, "\n";
print $bar{foo}->{'b'}, "\n";
=cut
