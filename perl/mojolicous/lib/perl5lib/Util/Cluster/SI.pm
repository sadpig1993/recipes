package Util::Cluster::SI;
use strict;
use warnings;

use base qw/Util::Comet::SI/;

sub _on_start {

}

sub _on_connect {

  my $class  = shift;
  my $heap   = shift;
  my $kernel = shift;

  $heap->{logger}->debug("_on_connect is called");
  $kernel->post('adapter', 'on_line_leave', $heap->{config}->{name} . "." .  $heap->{config}->{idx});
   
  my $svr = $heap->{out}->get_input_handle();
  my $sip = $svr->peerhost();

}

sub _on_accept {
}


1;
