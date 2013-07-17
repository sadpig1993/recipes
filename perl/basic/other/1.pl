#!/usr/bin/env perl

use strict;
use warnings;

my $href = {
    fa => [ 1, 2, 3, undef, '', 6 ],
    fb => [ 1, 2, 3, undef, '', 6 ],
    fc => [ 1, 2, 3, undef, '', 6 ]
};

# 打印出哈希%{$href}的所有key
#my @hkey = keys %{$href};
#print @hkey, "\n";

# 打印出数组 @{ $href->{fa} } 的所有元素
print @{ $href->{fa} }, "\n";

for ( my $tmp = 0 ; $tmp < @{ $href->{fa} } ; $tmp++ ) {
    #my @records;
    #ush @records, ${ $href->{fa} }[$tmp], ${ $href->{fb} }[$tmp],
    # ${ $href->{fc} }[$tmp];
    #rint @records, "\n";

    print ${$href->{fa}}[$tmp],${$href->{fb}}[$tmp],${$href->{fc}}[$tmp],"\n";
}

