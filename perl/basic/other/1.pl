#!/usr/bin/env perl

use strict;
use warnings;

# $href 是hash引用
my $href = {
    fa => [ 1, 2, 3, 4, 5, 6 ],
    fb => [ 1, 2, 3, 7, 8, 6 ],
    fc => [ 1, 2, 3, 5, 9, 6 ],
};

# 打印出哈希%{$href}的所有key
my @hkey = sort { $a cmp $b } keys %{$href};
print @hkey, "\n";

# 打印出数组 @{ $href->{fa} } 的所有元素
print @{ $href->{fa} }, "\n";

for ( my $tmp = 0 ; $tmp < @{ $href->{fa} } ; $tmp++ ) {
    #my @records;
    #ush @records, ${ $href->{fa} }[$tmp], ${ $href->{fb} }[$tmp],
    # ${ $href->{fc} }[$tmp];
    #rint @records, "\n";

    print ${$href->{fa}}[$tmp],${$href->{fb}}[$tmp],${$href->{fc}}[$tmp],"\n";
}

