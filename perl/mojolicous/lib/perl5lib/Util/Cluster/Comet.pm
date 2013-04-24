package Util::Cluster::Comet;
use strict;
use warnings;

use Util::Cluster::SI;

sub spawn {

  my $class = shift;
  my $args  = { @_ };

  for (my $i = 0; $i < $max_id; ++$i) {
    next if $i == $node_id;
    Util::Cluster::SI->spawn($node_id, $i);
  }

}

