package Util::Bridge::Adapter::Client;
use strict;
use warnings;

use base qw/Util::Comet::Adapter/;

use POE;
use List::MoreUtils qw/uniq/;

#################################################################
#         ---------------------
# pack <==| client ==>  server| <== switch
#         ---------------------
# -------------------
# |client <== server| 是个透明盒子
# -------------------
#
# client.on_remote_data到client.on_remote_data数据:
# {
#   src    => client.N,
#   packet => '^Storable|||hex|adfajfafjasfsafdafa',
# }
# 其中: 
# packet为
# {
#   from => 'switch',
#   dst  => 'cups',
#   swt  => $swt,
# } 的打包 
#
# on_remote_data重写
#################################################################
sub on_remote_data {
  $_[HEAP]{send}->put($_[ARG0]->{packet});
}

#################################################################
# 重写原因:
#         ---------------------
# pack ==>| client ==>  server| ==> switch
#         ---------------------
# -------------------
# |client ==> server| 是个透明盒子
# -------------------
# 相当于pack==> switch
#
# pack 给client.on_adapter_data的数据为:
# '^Storable|Hex|||adfafafafafafaf'
# 
# client.on_adapter_data需要发送给client.N线路session的on_adapter_data
# {
#    dst    => 'server'
#    packet => '^Storable|Hex|||adfafafafafafaf' ,
# }
#################################################################
sub on_adapter_data {

  my $logger = $_[HEAP]{logger};
  $logger->debug("on_adapter_data got[$_[ARG0]]");

  # 准备数据 
  my $data = {
    packet => $_[ARG0],
    dst    => 'server', 
  };

  # 看发送给server机构的那条线路  
  my $alias = $_[HEAP]{class}->get_line_session($_[HEAP], $data->{dst});
  unless($alias) {
    $logger->error("$data->{dst}, no bridge server line available");
    return 1;
  }
  $logger->debug("post to [$alias]:\n" .  Data::Dump->dump($data)) if $logger->{loglevel} > $logger->INFO();
  $_[KERNEL]->post($alias, 'on_adapter_data', $data);
}

1;

