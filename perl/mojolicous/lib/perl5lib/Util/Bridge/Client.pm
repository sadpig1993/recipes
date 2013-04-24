package Util::Bridge::Client;

use strict;
use warnings;

use POE;
use Util::Bridge::Comet::DA;
use Util::Bridge::Adapter::Client;

#############################################################################################################
# args:                                                          #
# {                                                              #
#    logger     => $logger,                                      # 日志  
#    ipc        => 'pipe|queue',                                 # 模块通讯方式  
#    queue      => $mq,                                          # 如果模块通讯为queue(Util::IPC::MsgQ)
#    pid        => $pid,                                         # 本bridge client挂载的机构有哪些  
#    ins        => [ 'cups', 'icbc' ],                           #
#    server     => [                                             #
#      { remoteaddr => '192.168.1.29', remoteport => '8686' },   # bridge server 0
#      { remoteaddr => '192.168.1.29', remoteport => '8787' },   # bridge server 1
#    ],                                                          #
#    serializer => $serializer,                                  # 序列化对象  
# }                                                              #
##############################################################################################################
sub run {

  my $class   = shift;
  my $args    = shift;

  ##############################################
  # 配置资源 
  ##############################################
  my $logger     = $args->{logger};
  my $pid        = $args->{pid};
  my $top        = [$pid, $args->{ins}];
  my $ipc        = $args->{ipc};
  my $queue      = $args->{queue};
  my $server     = $args->{server};
  my $serializer = $args->{serializer};
  my $idx = 0;

  $logger->debug("Bridge::Client run with:\n" . Data::Dump->dump($args)) if $logger->{loglevel} > $logger->INFO();

  ##############################################
  # client采用Comet的思路，将server看做一个机构  
  # 启动到server.0 .. server.N的连接sesssion
  ##############################################
  $logger->info("begin spawn bridge-client ==> bridge-server sessions...");
  for my $line (@{$server} ) {
    my $logname = "bs.$idx.$line->{remoteaddr}-$line->{remoteport}.log";
    my $klogger = $logger->clone($logname);
    my $bc = Util::Bridge::DA->spawn(
      $klogger,
      {  
        remoteaddr => $line->{remoteaddr},
        remoteport => $line->{remoteport},
        name       => 'server',    #
        idx        => $idx,        #   attention: name.idx 为session alias
        codec      => 'ins 4',

        #---- 额外传入 
        pid        => $pid,        #   P平台的id
        top        => $top,        #   P平台上挂载的机构: [ 0, ['cups', 'icbc']]
        serializer => $serializer,
      }
    );
    unless($bc) {
      $logger->error("can not Util::Bridge::DA->new()");
      return undef;
    }
    $idx++;
  }
  
  ##############################################
  # adapter模块
  ##############################################
  my $send;
  $logger->info("begin spawn Adapter...");
  my $ad = Util::Bridge::Adapter::Client->spawn(
    logger     => $logger,
    serializer => $serializer,
    ipc        => $ipc,
    send       => $queue,
  );
  unless ($ad) {
    $logger->error("can not spawn Util::Bridge::Adapter::Client");
    return undef;
  }

  ##############################################
  # 运行
  ##############################################
  $logger->debug(">>>>>>>>>>>>>>>Bridge Client begin servicing...");
  $poe_kernel->run();

  return undef;
}

1;


__END__


=head1 NAME

  Util::Bridge::Client  - a simple 

=head1 SYNOPSIS

  #!/usr/bin/perl -w
  use strict;

  exit 0;


=head1 Author & Copyright

  zcman2005@gmail.com

=cut


