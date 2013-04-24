package Util::DB::Sync::Filter;

use strict;
use warnings;
use Util::Run;

################################
#  argstr  => "ip:port"
#  job     => $job    | Util::DB::Sync::Job
################################
sub new {

  my $class = shift;
  my $arg = { @_ };

  my $job    = $arg->{job};
  my $argstr = $arg->{argstr};

  my $self = bless { job => $job, argstr => $argstr }, $class;

  $run_kernel->add_channel();

  my $svr = IO::Socket::INET->new($argstr);
  unless($svr) {
    #$job->{log}->debug("can not connect to server");
  }
  $self->{socket} = $svr;

  return $self;

}

#
#
sub handle {

  my $self = shift;
  my $row  = shift;   # [ ]

  #$self->{log}->debug("filter got row[@$row]");
  return $row;

}

1;

