package Util::Bridge::FH;

use strict;
use warnings;

use base qw/Util::Comet::FH/;

use POE;

#
# 设置serializer
#
sub _on_start {

  my $class  = shift;
  my $heap   = shift;
  my $kernel = shift;

  # $heap->{logger}->debug("_on_start called, heap:\n". Data::Dump->dump($heap));

  # serializer
  $heap->{serializer} = delete $heap->{config}->{serializer};

  return 1;
}

#
# 协商处理 
#
sub _on_negotiation {
	
  my $class  = shift;
  my $heap   = shift;
  my $kernel = shift;

  $heap->{logger}->debug("_on_negotiation is called");
  #
  # 协商期间的on_remote_data 将收到的topology, 并发送给Adapter
  #
  $kernel->state('on_remote_data', \&on_remote_data_nego);

  # return值注意：
  #   undef :  _on_negotiation处理失败
  #   1     :  由子类负责通知adapter on_session_join
  #   0     :  由父类负责通知adapter on_session_join
  # 这里必须由子类通知，因为通知时，需要带上topology
  return 1;  
}

#
# 协商期间的on_remote_data
#
sub on_remote_data_nego {

  $_[HEAP]{logger}->debug("on_remote_data_nego got[$_[ARG0]]");

  ######################################
  # top:
  # [  
  #    $pid,
  #    ['pos',  'icbc']
  # ];
  ######################################
  my $top = $_[HEAP]{serializer}->thaw($_[ARG0]);
  $_[HEAP]{logger}->debug("got topology:\n" . Data::Dump->dump($top));

  # 从$top中得到client的ID, reset机构名称 
  my $pid = $top->[0];
  $_[HEAP]{pid} = $pid;
  $_[HEAP]{logger}->debug("ins name is reset from",  $_[HEAP]{config}->{name},  "to client-$pid");
  $_[HEAP]{config}->{name} = "client-$pid";
  $_[HEAP]{config}->{idx}  = $pid;

  # 为机构client.$pid 打开日志文件 
  $_[HEAP]{logger} = $_[HEAP]{logger}->clone("bc.$pid.log");
  
  
  # 删除原有的alias 
  for ($_[KERNEL]->alias_list()) {
    $_[HEAP]{logger}->debug("_on_start begin remove alias[$_]");
    $_[KERNEL]->alias_remove($_);
  }
  
  # 重新设置alias
  $_[KERNEL]->alias_set("client-$pid.0");   # attention
  $_[HEAP]{logger}->debug("alias client-$pid.0 is set");

  # 将topology 发送给adapter, adapter收到toplogy后， 将增加一个client.$pid的alias  
  $_[KERNEL]->post('adapter', 'on_session_join', [ "client-$pid", 0, $top]);
  $_[HEAP]{logger}->debug("topology is send to adapter");

  # 置回on_remote_data处理  
  $_[KERNEL]->state('on_remote_data', 'Util::Comet::FH', 'on_remote_data');
  $_[HEAP]{logger}->debug("on_remote_data is reset to normal");

  # 发送ok给client.N 
  $_[HEAP]{fh}->put($_[HEAP]{serializer}->serialize({ status => 'OK'}));
  $_[HEAP]{logger}->debug("negotiation response is sent");

  return 1;
}

sub _on_destroy {
  my $class  = shift;
  my $heap   = shift;
  my $kernel = shift;
  # $heap->{logger}->debug("_on_destroy called, heap:\n" . Data::Dump->dump($heap));
  $kernel->post('adapter', 'on_session_leave', [$heap->{config}->{name},  $heap->{config}->{idx}]);
  return 1;   #!!!!!!!!!!, 这样父类就不会 post on_session_leave到 adapter
}

1;


