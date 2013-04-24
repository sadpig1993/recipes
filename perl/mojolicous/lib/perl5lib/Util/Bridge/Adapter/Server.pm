package Util::Bridge::Adapter::Server;

use strict;
use warnings;

use POE;
use IO::Socket::INET;
use IO::Handle;
use POE::Wheel::ListenAccept;
use Util::Bridge::Comet::FH;
use List::MoreUtils qw/uniq/;

use base qw/Util::Comet::Adapter/;

#########################################################
#         ---------------------
# pack ==>| client ==>  server| ==> switch
#         ---------------------
# -------------------
# |client ==> server| 是个透明盒子  
# -------------------
#
# server收到client数据后, 
# Util::Comet::Adapter的on_remote_data会先freeze再put to swith
#
# 由于需要透明传输, 我们的on_remoete_data不需要freeze了
#
# adapter.on_remote_data:
# {
#   src    => client.N,
#   packet => $packet,   # freeze好的数据(freeze是pack完成的) 
# }
#
# 发送给switch为 $packet
#########################################################
sub on_remote_data {
  $_[HEAP]{logger}->debug("on_remote_data is called, send:\n" . Data::Dump->dump($_[HEAP]{send}));
  $_[HEAP]{send}->put($_[ARG0]->{packet});
}

#########################################################
# BridgeS从switch收到数据:
# {
#    from  => 'switch',
#    swt   => $swt,
#    dst   => 'icbc',
# }
# 依据topology, 看发送给哪个client.N
# 发送
# {
#   packet => $packet,
#   dst    => 'client.N,
# } 
# 其中$packet为
# {
#     from  => 'switch',
#     swt   => $swt,
#     dst   => 'icbc',
# }的打包 
# 
# on_adapter_data没有重写， 而是重写_adapter_filter
# 因为，都是需要thaw.
# 这里_adapter_filter需要业务数据(目标机构) 来决定发送
# 给哪个client, 决定方式是， 查询topology
#########################################################
sub _adapter_filter {

  my $class = shift;
  my $heap  = shift;
  my $ad    = shift;

  my $logger = $heap->{logger};
  my $top    = $heap->{top}->{$ad->{dst}};

  unless($top) {
    $logger->error("can not decide which bridge client to send, not topology for $ad->{dst}");
    return undef;
  } 
  $logger->debug("_adapter_filter called, $ad->{dst} can be send to bc[@$top]");

  ################################
  # 计算发给哪个client, 
  ################################
  my $cnt = @$top;
  my $client_id;
  if ($cnt == 0 ) {
    $logger->error("no bc for $ad->{dst}");
    return undef;
  }
  elsif ($cnt == 1) {
    $client_id = $top->[0];
  } else {
    $client_id = $top->[int(rand($cnt))];
  }

  return {
    packet  => $heap->{serializer}->freeze($ad),
    dst     => "client-$client_id",
  };

}

#
# 通讯sesssion收到BridgeC发送的topology后，发送给on_client_join
#
sub _on_session_join {

  my $class  = shift;
  my $heap   = shift;
  my $kernel = shift;
  my $top    = shift;

  $heap->{logger}->info("_on_session_join called with:\n" . Data::Dump->dump($top));
  ######################################
  # top:
  # [
  #   $client_id =>  [ 'pos',  'icbc' ],
  # ];
  ######################################
  my $client_id = $top->[0];

  #
  # 合并机构topology 
  # {
  #   icbc => [ 0, 1 ],
  #   pos  => [ 0, 1 ],
  # }
  #
  for my $iname (@{$top->[1]}) {
    my $itop = delete $heap->{top}->{$iname};
    push @{$itop}, $client_id;
    $heap->{top}->{$iname} = [ uniq @$itop ];
  }

  #
  # 通讯session管理   
  #
  $heap->{logger}->info("adapter topology  now is:\n" . Data::Dump->dump($heap->{top}));

  return 1;
}

##############################################################
# 添加事件: on_setup
# 添加事件 'on_client_join'
# 添加事件 'on_accept'
# 添加事件 'on_la_error'
# 添加事件 'on_child'
##############################################################
sub _on_start {

  my $class  = shift;
  my $heap   = shift;
  my $kernel = shift;
  my $args   = shift;

  my $logger = $heap->{logger};

  # $logger->debug("_on_start called with:\n" . Data::Dump->dump($args));
  ###############################################
  # 添加事件 'on_setup'
  # 添加事件 'on_client_join'
  # 添加事件 'on_accept'
  # 添加事件 'on_la_error'
  # 添加事件 'on_child'
  ###############################################
  $kernel->state('on_setup'        => \&on_setup);
  $kernel->state('on_client_join'  => \&on_client_join);
  $kernel->state('on_client_leave' => \&on_client_leave);
  $kernel->state('on_accept'       => \&on_accept);
  $kernel->state('on_la_error'     => \&on_la_error);
  $kernel->state('_child'          => \&on_child);

  # 交给setup处理 
  $kernel->yield('on_setup' => $args);

  return 1;
}

#
# 建立wheel la
#
sub on_setup {

  my $args = $_[ARG0];
  my $logger = $_[HEAP]{logger};

  delete $_[HEAP]{la};

  ###############################################
  # listen accept wheel setup
  ###############################################
  my $la_socket = IO::Socket::INET->new(
    LocalAddr => $args->{localaddr},
    LocalPort => $args->{localport},
    Listen    => 5,
    ReuseAddr => 1,
  );
  unless($la_socket) {
    $logger->error("can not create LA socket[$args->{localaddr}:$args->{localport}]");
    $_[KERNEL]->delay('on_setup' => 4);
    return;
  }
  my $la = POE::Wheel::ListenAccept->new(
    Handle      => $la_socket,
    AcceptEvent => 'on_accept',
    ErrorEvent  => 'on_la_error',
  );
  unless ($la) {
    $logger->error("can not create la wheel");
    $_[KERNEL]->delay('on_setup' => 4);
    return;
  }
  $_[HEAP]{la} = $la;

  return 1;
}

#
# 收到一个连接就生成一个client sesssion
#
sub on_accept {

  $_[HEAP]{logger}->debug("begin create client session with fh");
  my $client = Util::Bridge::FH->spawn(
    $_[HEAP]{logger},
    {
      fh         => $_[ARG0],
      name       => 'client',  # mock
      idx        => '0',       # mock 
      codec      => 'ins 4',
      serializer => $_[HEAP]{serializer},
    }
  );
  unless($client) {
    $_[HEAP]{logger}->warn("can not Util::Bridge::FH->spawn()");
    return undef;
  }
  return 1;
}


###########################################################
# _child event:
#   child session management
###########################################################
sub on_child {
  my ($reason, $child) = @_[ARG0, ARG1];
  my $sid = $child->ID();
  $_[HEAP]{logger}->debug("session[$sid] action[$reason]");
  return 1;
}

1;

