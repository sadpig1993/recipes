#!/usr/bin/perl

use Data::Dump;
use Util::Hash::Add;

my $h1 = {
  a => {
     b => {
        c => [ 1 , 2 ],
     }
  }
};

my $h2 = {
  a => {
     b => {
        c => [ 1 , 2 ],
     },
     bx => {
        bxj => [1, 2],
     }
  }
};

my $h = hash_add($h1, $h2);

Data::Dump->dump($h);

while(<>) {
  warn $_;
}

__DATA__
asdfa
adf
asdf
asdf
asdf
asdf

