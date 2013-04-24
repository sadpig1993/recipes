package Util::Job::Client::PoCo;

use strict;
use warnings;

use POE;
use POE::Wheel::ReadWrite;
use POE::Filter::Reference;


my %poco_data;

sub spawn {
  POE:::Session->create(
    'inline_states' => {
    },
  );
}

#
#  svr_node1 =>  '192.168.1.29:4341'
#  svr_node2 =>  '192.168.1.29:4341'
#
#
sub new {
  my $class = shift;
  my $args  = { @_ };
  my $self = bless {}, $class;
  return $self->_init($args);
}

sub _init {

  my $self = shift;
  my $args = shift;

  my %nodes;

  for my $svr (keys %{$args}) {

    $nodes{$svr}->[0] = $args->{$svr};
    $nodes{$svr}->[1] = IO::Socket::INET->new($args->{$svr});
    unless($nodes{$svr}->[1]) {
      warn "connect ", $args->{$svr}, " error";
      return undef;
    }
  }
  $self->{'_svr_node'} = \%nodes;
  return $self;

}


#
#
#
sub add_server {
  my $self = shift;
  my $node = shift;
  my $addr = shift;

  if ( exists $self->{_svr_node}->{$node} ) {
    warn "exists node";
    return undef;
  }

  $self->{'_svr_node'}->{$svr}->[0] = $node;
  $self->{'_svr_node'}->{$svr}->[1] = IO::Socket::INET->new($addr);
  unless( $self->{'_svr_node'}->{$svr}->[1] ) {
    warn "connect ", $addr, " error";
    return undef;
  }

  return $self;
}

1;

