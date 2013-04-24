#!/usr/bin/perl
use strict;
use warnings;

use POE;
use POE::Wheel::ListenAccept;
use POE::Wheel::ReadWrite;
use POE::Filter::Reference;

#
# 服务列表  
#
my %service_list;

POE::Session->create(
  'inline_state' => {
    '_start'    => \&on_start,

    'on_agentd_error'  => \&on_agentd_error,
    'on_agentd_accept' => \&on_agentd_accept,

    'on_agent_input'   => \&on_agent_input,
    'on_agent_error'   => \&on_agent_error,

    'on_server_error'  => \&on_server_error,
    'on_server_accept' => \&on_server_accept,

    'on_client_input'  => \&on_client_input,
    'on_client_error'  => \&on_client_error,
    'on_client_flush'  => \&on_client_flush,
  },
);

sub on_start {

  $_{HEAP}->{'agent'} = POE::Wheel::ListenAccept->new(
    AcceptEvent => "on_agent_accept",
    ErrorEvent  => "on_agent_error",
    Handle      => IO::Socket::INET->new(
        LocalPort => 9898,
        Listen    => 5,
        ReuseAddr => 1,
      ),
  );

  $_{HEAP}->{'server'} = POE::Wheel::ListenAccept->new(
    AcceptEvent => "on_client_accept",
    ErrorEvent  => "on_server_error",
    Handle      => IO::Socket::INET->new(
        LocalPort => 8484,
        Listen    => 5,
        ReuseAddr => 1,
      ),
  );

}

sub on_agentd_accept {

  my $client_socket = $_[ARG0];
  my $w = POE::Wheel::ReadWrite->new(
    Handle       => $client_socket,
    InputEvent   => "on_agent_input",
    ErrorEvent   => "on_agentt_error",
    InputFilter  => POE::Filter::Reference->new(),
    OutputFilter => POE::Filter::Reference->new(),
  );
  $_[HEAP]{'agent'}{$w->ID()} = $w;
  
  #
  #  agent register service....
  #
}

sub on_agentd_error {
}

#
# protocol design needed...
#
sub on_agent_input {
  my ($input, $wid) = @_[ARG0, ARG1];
  if ($input->{'op'}) {
  }
}

#
#
#
sub on_agent_error {
}

############################################
sub on_server_accept {

  my $client_socket = $_[ARG0];
  my $w = POE::Wheel::ReadWrite->new(
    Handle       => $client_socket,
    InputEvent   => "on_client_input",
    ErrorEvent   => "on_client_error",
    FlushedEvent => "on_client_flush",
    InputFilter  => POE::Filter::Line->new(),
  );
  $_[HEAP]{client}{$w->ID()} = $w;
}

sub on_server_error {
}





