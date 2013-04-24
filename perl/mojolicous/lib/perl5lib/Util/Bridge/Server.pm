package Util::Bridge::Server;
use strict;
use warnings;
use POE;
use Env qw/$TINO_HOME/;
use Util::Log;
use Util::IPC::MsgQ;
use Util::Bridge::Adapter::Server;

###################################################
# BridgeS将每个client.N看做一个机构
# 同时Util::Bridge::Adapter::Server将
# 1> 添加了LA wheel
# 2> 每当有一个client.N连接上来，就产生一个机构client.N
#    这个机构就一个线路session: Util::Bridge::Comet::FH
# 3> 机构线路session启动后先
#    _on_start:
#      b) 设置协商期间处理_on_connect:
#         设置on_remote_data到on_remote_data_nego
#    on_remote_data_nego:
#      a) remove所有的alias
#      b) 收到client.N的首次消息(topology), 从topology中
#         取出pid(P平台ID)后，alias_set("client-$pid.0"), 并且
#         post('adapter', 'on_session_join', [ "client-$pid", 0, $top ]);
#      c) 设置回原有的on_remote_data
# 4> Util:Bridge::Adapter::Server收到on_session_join事件后
#    a): 保存client.N的机构线路session alias
#    b): 将收到的toplogy合并到$_[HEAP]{top}中 
#    
###################################################

###################################################
# args:
# {
#   logger     => $logger
#   ipc        => 'pipe|queue',
#   queue      => $mq,
#   kid        => $kid
#   serializer => $serializer,
#   localaddr  => '192.168.1.29',
#   localport  => '8686',
# }
###################################################
sub run {
  
  my $class = shift;
  my $args  = shift;

  ##################################################
  # 配置资源  
  ##################################################
  my $logger     = $args->{logger};
  my $ipc        = $args->{ipc};
  my $queue      = $args->{queue};
  my $kid        = $args->{kid};
  my $serializer = $args->{serializer};
 
  ##################################################
  # Adapter session
  ##################################################
  my $ad = Util::Bridge::Adapter::Server->spawn(
    logger     => $logger,
    serializer => $serializer,
    ipc        => $ipc,
    send       => $queue,
    #-------------
    localaddr  => $args->{localaddr},
    localport  => $args->{localport},
  );
  unless($ad) {
    return undef;
  }
  
  # POE running
  $poe_kernel->run();
  $logger->error("internal error");
  return undef;
}

1;

__END__


=head1 NAME

  Util::Bridge::Server  - a simple 

=head1 SYNOPSIS

  #!/usr/bin/perl -w
  use strict;

  exit 0;


=head1 Author & Copyright

  zcman2005@gmail.com

=cut



