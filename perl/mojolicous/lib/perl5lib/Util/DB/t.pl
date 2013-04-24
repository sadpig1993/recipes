#!/usr/bin/perl

use Time::HiRes qw/gettimeofday tv_interval sleep/;

my $beg = [gettimeofday];
sleep(2.00000001);
my $end = [gettimeofday];

my $elapse = tv_interval($beg, $end);

warn "$elapse\n";

my $int = $elapse * 1000000;

my $high;
my $low;
{
  use integer;
  warn "$int\n";

  if ($int >= 1000000){
    $high = $int / 1000000; 
    $low  = $int % 1000000;
  } else {
    $high = 0;
    $low = $int;
  }

}

warn "high[$high] low[$low]";


