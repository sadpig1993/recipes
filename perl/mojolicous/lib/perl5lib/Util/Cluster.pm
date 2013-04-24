package Util::Cluster;

use strict;
use warnings;
use Util::Cluster::Comet;
use Util::Cluster::Adapter;
use POE;
use Carp qw/cluck/;

sub run {
  my $class = shift;
  my $args  = { @_ };

  my $ad = Util::Custer::Adapter->spawn();
  my $co = Util::Custer::Comet->spawn();

  $poe_kernel->run();

}



1;
