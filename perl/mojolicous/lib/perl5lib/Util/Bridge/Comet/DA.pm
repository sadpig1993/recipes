package Util::Bridge::DA;

use strict;
use warnings;
use base qw/Util::Comet::DA/;
use POE;

#
# 定制初始化，得到P平台ID, toplogy
#
sub _on_start {

  my $class  = shift;
  my $heap   = shift;
  my $kernel = shift;

  #--------额外传入参数
  $heap->{pid}        = delete $heap->{config}->{pid};
  $heap->{top}        = delete $heap->{config}->{top};
  $heap->{serializer} = delete $heap->{config}->{serializer}; 

  # $heap->{logger}->debug("_on_start called, heap now:\n" . Data::Dump->dump($heap));
  return 1;
}

#
#
sub _on_connect {
  
  my $class  = shift;
  my $heap   = shift;
  my $kernel = shift;

  $heap->{logger}->debug("_on_connect is called");

  # 告知adpater, 线路断开
  $kernel->post('adapter', 'on_line_leave', $heap->{config}->{name} . "." .  $heap->{config}->{idx});

  ##################################
  # 发送给BridgeS 的topology数据结构  
  #---------------------------------
  #[
  #  $pid,
  #  {
  #    'pos'  => [0],    
  #    'icbc' => [0],
  #  }
  #];
  ##################################

  #
  # 协商期间的on_remote_data 
  #
  $heap->{logger}->debug("set on_remote_data");
  $heap->{logger}->debug("set on_nego_timeout");
  $kernel->state('on_remote_data',  \&on_remote_data_nego);
  $kernel->state('on_nego_timeout', \&on_nego_timeout);

  # 发送拓扑结构  
  $heap->{logger}->debug("send topology to BridgeS:\n" . Data::Dump->dump($heap->{top}));
  $heap->{da}->put($heap->{serializer}->serialize($heap->{top}));

  # 设置协商超时 
  $heap->{logger}->debug("alarm set for negotiation timeout");
  $heap->{nego_id} = $kernel->alarm_set('on_nego_timeout' => 3 + time());

  #
  # attention, important!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # return 0 means: 父类会调用post('adapter', 'on_session_join', [$name, $idx])
  #
  return 0;  

}

#
# 协商期间on_remote_data
#
sub on_remote_data_nego {

  my $response = $_[HEAP]{serializer}->deserialize($_[ARG0]);
  $_[HEAP]{logger}->debug("got topology response:\n" . Data::Dump->dump($response));
  $_[KERNEL]->alarm_remove(delete $_[HEAP]{nego_id});  # 解除协商超时  
  $_[KERNEL]->state('on_remote_data', 'Util::Comet::DA', 'on_remote_data');  # 设置回原处理 
  $_[KERNEL]->post('adapter', 'on_line_join', $_[HEAP]{config}->{name} . "." . $_[HEAP]{config}->{idx} );
  return 1;

}

#
# 协商超时处理: 还原on_remote_data 
#
sub on_nego_timeout {
  $_[HEAP]{logger}->warn("negotiation timeout");
  $_[KERNEL]->alarm_remove(delete $_[HEAP]{nego_id});
  $_[KERNEL]->state('on_remote_data','Util::Comet::DA', 'on_remote_data'); 
  $_[KERNEL]->yield('on_connect');
}

1;

