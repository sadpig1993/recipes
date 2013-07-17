#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dump;

my @arr = qw/1 2 3 4 5 6 10 11 9/;
Data::Dump->dump(@arr);

## 数组中元素正向排序 以数字顺序sort
@arr = sort { $a <=> $b } @arr ;
Data::Dump->dump(@arr);

## 数组中元素反向排序 
@arr = sort { $b <=> $a } @arr ;
Data::Dump->dump(@arr);

## 以ASCII顺序（非字典顺序）sort
@arr = qw/away baby copy hello bye/;
Data::Dump->dump(@arr);

## 以ASCII顺序（非字典顺序）sort 正向
@arr = sort { $a cmp $b } @arr ;
Data::Dump->dump(@arr);
## 反向
@arr = sort { $b cmp $a } @arr ;
Data::Dump->dump(@arr);