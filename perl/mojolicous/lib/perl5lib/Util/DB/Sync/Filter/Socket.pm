package Util::DB::Sync::Filter::Socket;

use strict;
use warnings;

use IO::Socket::INET;

################################
#  argstr  => "ip:port"
#  job     => $job    | Util::DB::Sync::Job
################################
sub new {

  my $class = shift;
  my $arg = { @_ };

  my $sync   = $arg->{sync};
  my $argstr = $arg->{argstr};

  my $self = bless { 
    sync   => $sync, 
    argstr => $argstr,
  }, $class;

  my $svr = IO::Socket::INET->new($argstr);
  unless($svr) {
    $sync->{log}->debug("can not connect to server");
  }
  $self->{socket} = $svr;

  return $self;

}

#
# 发送记录到其他机器 
#
sub handle {

  my $self = shift;
  my $row  = shift;   # [ ]

  my $log = $self->{sync}->{log};
  $log->debug("filter got row[@$row]");
  my $line = "@$row";
  unless( $self->{socket}->print("$line\n") ) {
    $log->debug("send to socket faild, reconnect to $self->{argstr}");
    $self->{socket} = IO::Socket::INET->new($self->{argstr});
    $self->{socket}->print("$line\n");
  }
  return $row;

}

1;

