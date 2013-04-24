package Util::HSM::Vendor::SLJ05;

use strict;
use warnings;
use IO::Socket::INET;
use IO::Handle;
use Util::Encode;

sub import {

  my $pkg = caller();
  no strict 'refs';
  *{ $pkg . '::KEY_TYPE_COMM'   } = \&KEY_TYPE_COMM;
  *{ $pkg . '::KEY_TYPE_PIN'    } = \&KEY_TYPE_PIN; 
  *{ $pkg . '::KEY_TYPE_MAC'    } = \&KEY_TYPE_MAC; 
  *{ $pkg . '::KEY_TYPE_DATA'   } = \&KEY_TYPE_DATA; 
  *{ $pkg . '::KEY_TYPE_CVV'    } = \&KEY_TYPE_CVV; 

  *{ $pkg . '::KEY_LEN_8'       } = \&KEY_LEN_8;
  *{ $pkg . '::KEY_LEN_16'      } = \&KEY_LEN_16; 
  *{ $pkg . '::KEY_LEN_24'      } = \&KEY_LEN_24; 

  *{ $pkg . '::MAC_ALGO_XOR'    } = \&MAC_ALGO_XOR;
  *{ $pkg . '::MAC_ALGO_ANSI99' } = \&MAC_ALGO_ANSI99; 
  *{ $pkg . '::MAC_ALGO_ANSI919'} = \&MAC_ALGO_ANSI919; 

  *{ $pkg . '::PIN_FORMAT_01'   } = \&PIN_FORMAT_01;
  *{ $pkg . '::PIN_FORMAT_02'   } = \&PIN_FORMAT_02; 
  *{ $pkg . '::PIN_FORMAT_03'   } = \&PIN_FORMAT_03; 
  *{ $pkg . '::PIN_FORMAT_04'   } = \&PIN_FORMAT_04; 
  *{ $pkg . '::PIN_FORMAT_05'   } = \&PIN_FORMAT_05; 
  *{ $pkg . '::PIN_FORMAT_06'   } = \&PIN_FORMAT_06; 

}


############################################################
# 密钥类型说明  
############################################################
sub KEY_TYPE_COMM    { "\x01" }   # 0x01: 通信主密钥   
sub KEY_TYPE_PIN     { "\x11" }   # 0x11: PIN加密密钥
sub KEY_TYPE_MAC     { "\x12" }   # 0x12: MAC计算密钥 
sub KEY_TYPE_DATA    { "\x13" }   # 0x13: 数据加密密钥 
sub KEY_TYPE_CVV     { "\x21" }   # 0x21: CVV计算密钥 

############################################################
# 密钥长度  
############################################################
sub KEY_LEN_8        { "\x08" }   # 长度8 
sub KEY_LEN_16       { "\x10" }   # 长度16 
sub KEY_LEN_24       { "\x18" }   # 长度24 

############################################################
# mac算法标示  
############################################################
sub MAC_ALGO_XOR     { "\x01" }   # xor
sub MAC_ALGO_ANSI99  { "\x02" }   # ansi9.1
sub MAC_ALGO_ANSI919 { "\x03" }   # ansi9.19

############################################################
# pin格式 
############################################################
sub PIN_FORMAT_01    { "\x01" }   # "00" + (pin:6)
sub PIN_FORMAT_02    { "\x02" }   # [pin_len:1] + [6个pin每个pin占4bit:3]  + [FFFFFFFFFF:4] ?????
sub PIN_FORMAT_03    { "\x03" }   # BULL格式:
sub PIN_FORMAT_04    { "\x04" }   # Interbold, ibm atm
sub PIN_FORMAT_05    { "\x05" }   # ncratm
sub PIN_FORMAT_06    { "\x06" }   #

############################################################
# logger   => $logger    # 日志  
# slj_ip   => $ip        # 加密机地址 
# slj_port => $port      # 加密机端口  
# timeout  => 2          # 访问加密机超时时间   
############################################################
sub new {

  my $class = shift;
  my $args  = { @_ };

  my $self = bless $args, $class;

  unless($self->connect()) {
    return undef;
  }

  return $self;
}

############################################################
# 连接加密机  
############################################################
sub connect {

  my $self = shift;

  # 连接加密机  
  my $slj = IO::Socket::INET->new("$self->{slj_ip}:$self->{slj_port}");
  unless($slj) {
    $self->{logger}->error("can not connect to slj[$self->{slj_ip}:$self->{slj_port}");
    return undef;
  }

  $slj->blocking(0);

  $self->{slj} = $slj;

  my $rin = '';
  my $win = '';
  my $ein = '';
  vec($rin, fileno($slj), 1) = 1;
  $ein = $rin | $win;
  $self->{rin} = $rin;
  $self->{win} = $win;
  $self->{ein} = $ein;

  return $self;
}

##################################################################
#
##################################################################
# 指令: 
#       D106(产生随机工作密钥) 
# 格式: 
#       [命令:2]
#       [密钥长度:1]         :  0x08, 0x10, 0x18
#       [密钥类型:1]         :  
# 输出:
#       [应答码:1]           :
#       [密钥长度:1]         :
#       [密钥:N]             :  N = 8/16/24
#       [校验码:8]           :
# 失败:
#       [应答码:1]
#       [错误码:1]
# 说明:
#       生成指定长度的随机工作密钥，并用加密机本地主密钥加密后返回其密文密钥和校验码  
##################################################################
# 函数参数:
#   klen   =>
#   ktype  =>   
##################################################################
sub gen_key_d106 {

  my $self  = shift;
  my $args  = { @_ };

  my $cmdstr = "\xD1\x06" . $args->{klen} . $args->{ktype};
  
  # 密钥类型 
  # 0x01: 通信主密钥;
  # 0x11: PIN加密密钥；
  # 0x12: MAC计算密钥；
  # 0x13: 数据加密密钥
  # 0x21: CVV计算密钥

  my $resp = $self->cmd_11n8(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    key    => $resp->[0],
    chkval => $resp->[1],
  };
  
}

##################################################################
#               
##################################################################
# 指令: 
#       D107(产生随机工作密钥) 
# 格式: 
#       [命令:2]
#       [密钥长度:1]         :  0x08, 0x10, 0x18
#       [密钥类型:1]         :  
#       [传输主密钥索引:2]   :
#       [传输主密钥长度:1]   :
#       [传输主密钥:N]       :  ZMK
# 输出:
#       [应答码:1]
#       [密钥长度:1]
#       [密钥:N]             :  N = 8/16/24  LMK加密的密钥  
#       [密钥:N]             :  N = 8/16/24  ZMK加密的密钥 
#       [校验码:8]
# 失败:
#       [应答码:1]
#       [错误码:1]
# 说明:
#       产生指定长度的随机工作密钥，并用LMK和指定传输主密钥加密后返回  
##################################################################
#  klen  =>
#  ktype =>
#  tk_index  =>
#  tk        =>
##################################################################
sub gen_key_d107 {

  my $self = shift;
  my $args = { @_ };

  my $cmdstr = "\xD1\x07"  . $args->{klen}  .
                             $args->{ktype} .
                             $args->{tk_index} .
                             num2bin(length $args->{tk}) .
                             $args->{tk};

  my $resp = $self->cmd_11nn8(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    key_a  => $resp->[0],
    key_b  => $resp->[1],
    chkval => $resp->[2],
  };

}




##################################################################
#                         导入密钥 
##################################################################
# 指令: 
#       D102(导入密钥) 
# 格式: 
#       [命令:2]            :  0xD102
#       [工作密钥长度:1]    :  0x08 | 0x10 | 0x18
#       [通信主密钥长度:1]  :  0x08 | 0x10 | 0x18
#       [索引号:2]          :  0xFFFF
#       [BMK:N]             :  索引号为0xFFFF时候存在， 为LMK加密过的BMK 
#       [工作密钥]          :  BMK加密的密文  
#       [校验值长度:1]      :  
#       [校验值:N]          :
# 输出:
#       [应答码:1]
#       [WK密钥长度:1]
#       [WK密钥:N]
#       [校验码:8]
# 失败: 
#       [应答码:1]
#       [错误码:1]
# 说明: 
#       将用区域主密钥加密的密钥转换为用本地主密钥加密 
##################################################################
# wk_len   =>
# ck_len   =>
# index    =>
# bmk      =>
# wk       =>
# chkval   =>
##################################################################
sub import_key_d102 {

  my $self   = shift;
  my $args   = { @_ };

  my $cmdstr = "\xD1\x02" . $args->{wk_len} . 
                            $args->{ck_len} . 
                            $args->{index} . 
                            $args->{bmk} . 
                            $args->{wk} .
                            num2bin(length $args->{chkval}) .
                            $args->{chkval};

  my $resp = $self->cmd_11n8(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    key    => $resp->[0],
    chkval => $resp->[1],
  };
}

##################################################################
#                         导出密钥 
##################################################################
# 指令: 
#       D104(导出密钥) 
# 格式: 
#       [命令:2]
#       [工作密钥长度:1]     :  0x08, 0x10, 0x18
#       [通信主密钥长度:1]   :  0x08, 0x10, 0x18 
#       [索引号:2]           :  0xFFFF
#       [密钥类型:1]         :  
#       [BMK:N]              :  索引号为0xFFFF时候存在， 为LMK加密过的BMK 
#       [工作密钥:N]         :
#       [校验值长度:1]       :
#       [校验值:N]           :
# 输出:
#       [应答码:1]
#       [WK密钥长度:1]
#       [WK密钥:N]             :  N = 8/16/24
#       [校验码:8]
# 失败:
#       [应答码:1]
#       [错误码:1]
# 说明:
#       将用本地主密钥加密的密钥转换为用区域主密钥加密 
##################################################################
# wk_len     =>
# ck_len     =>
# index      =>
# ktype      =>
# bmk        =>
# wk         =>
# chkval     =>
##################################################################
sub export_key_d104 {

  my $self = shift;
  my $args = { @_ };

  
  my $cmdstr = "\xD1\x04" . $args->{wk_len} . 
                            $args->{ck_len} . 
                            $args->{index} . 
                            $args->{ktype} . 
                            $args->{bmk} . 
                            $args->{wk} .
                            num2bin(length $args->{chkval})  .
                            $args->{chkval};

  my $resp = $self->cmd_11n8(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    key    => $resp->[0],
    chkval => $resp->[1],
  };
}




##################################################################
#
##################################################################
# 指令: 
#       D108(加密明文密钥) 
# 格式: 
#       [命令:2]
#       [密钥长度:1]         :  0x08, 0x10, 0x18
#       [密钥类型:1]         : 
#       [密钥:N]             :  N = 8/16/24
# 输出:
#       [应答码:1]
#       [密钥长度:1]
#       [密钥:N]             :  N = 8/16/24
#       [校验码:8]
# 失败:
#       [应答码:1]
#       [错误码:1]
# 说明:
#       输入指定长度的明文密钥，并用加密机本地主密钥加密后返回其密文密钥和校验码 
##################################################################
# ktype       =>
# plain_key   =>
##################################################################
sub enc_key_d108 {

  my $self = shift;
  my $args = { @_ };

  my $cmdstr = "\xD1\x08" . num2bin(length $args->{plain_key}) 
                          . $args->{ktype} 
                          . $args->{plain_key};

  my $resp = $self->cmd_11n8(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    key    => $resp->[0],
    chkval => $resp->[1],
  };
}

##################################################################
#
##################################################################
# 指令: D134(校验mac)
# 格式: 
#       [命令:2]
#       [算法标志:1]        :  01: xor, 02: ANSI9.9,  03:ANSI9.19
#       [MAK长度:1]         :  0x08, 0x10, 0x18
#       [MAK:N]             :  LMK加密的MAK
#       [初始向量:8]
#       [MAC:4]             :  要校验的MAC 
#       [数据长度:2]        :
#       [数据:N]            :
# 输出:
#       [应答码:1]
#       [MAC:8]
#    
# 失败:
#       [应答码:1]
#       [错误码:1]
##################################################################
# algo  =>
# mak   =>
# iv    =>
# mac   =>
# data  =>
##################################################################
sub ver_mac_d134 {

  my $self = shift;
  my $args = { @_ };

  my $cmdstr = "\xD1\x34" . $args->{algo} .
                           num2bin(length $args->{mak}) .
                           $args->{mak} .
                           $args->{iv} .
                           $args->{mac} .
                           num2bin(length $args->{data}) .
                           $args->{data};

  my $resp = $self->cmd_18(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    mac  => $resp->[0],
  };
}

##################################################################
#
##################################################################
# 指令: 
#       D132(计算mac)
# 格式: 
#       [命令:2]
#       [算法标志:1]         :
#       [MAK长度:1]          :
#       [MAK:N]              :
#       [初始向量:8]         :
#       [数据长度:2]         :
#       [数据:N]             :
# 输出:
#       [应答码:1]
#       [MAC:8]
# 失败:
#       [应答码:1]
#       [错误码:1]
# 说明:
#       读取LMK
#       计算LMK密钥变种
#       根据算法和MAK长度标志解密密钥和计算MAC
#       返回8字节MAC
##################################################################
#  algo   =>
#  mak    =>
#  iv     =>
#  data   =>
##################################################################
sub gen_mac_d132 {

  my $self = shift;
  my $args = { @_ };

  my $cmdstr = "\xD1\x32" . $args->{algo} . 
                           num2bin(length($args->{mak})) .
                           $args->{mak} . 
                           $args->{iv} . 
                           num2bin(length($args->{data})) .
                           $args->{data};

  my $resp = $self->cmd_18(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    mac => $resp->[0],
  };

}


##################################################################
#
##################################################################
# 指令:
#       D126(解密pin)
# 格式: 
#       [PIK长度:1]
#       [PIK:N]                   : N=8/16/24 LMK加密的PIK 
#       [PIN格式:1]               : 01/02/03/04/05/06
#       [PIN:8]                   : 密文PIN  
#       [主账号补位码:12--19]     
# 输出:
#       [应答码:1]
#       [PIN长度:1]
#       [PIN:N]                   : 明文PIN 
# 失败:
#       [应答码:1]
#       [错误码:1]
##################################################################
# pik     =>
# format  => 
# pin     =>
# padding =>
##################################################################
sub dec_pin_d126 {

  my $self = shift;
  my $args = { @_ };

  my $cmdstr = "\xD1\x26" . num2bin(length $args->{pik}) . 
                           $args->{pik} . 
                           $args->{format} . 
                           $args->{pin} .
                           $args->{padding};

  my $resp = $self->cmd_11n(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    pin => $resp->[0],
  };

}


##################################################################
#
##################################################################
# 指令:
#       D124(pin转换) 
# 格式: 
#       [PIK1长度:1]
#       [PIK1:N]                  : N=8/16/24 LMK加密的PIK 
#       [PIK2长度:1]
#       [PIK2:N]                  : N=8/16/24 LMK加密的PIK 
#       [PIN1格式:1]
#       [PIN2格式:1]
#       [PINBlock:8]
#       [转换前主账号补位码:12--19]     
#       [分隔符:1]
#       [转换后主账号补位码:12--19]     
# 输出:
#       [应答码:1]
#       [PIN:8]                   : 明文PIN 
# 失败:
#       [应答码:1]
#       [错误码:1]
##################################################################
#  pik1         =>
#  pik2         =>
#  format1      =>
#  format2      =>
#  pinblock     =>
#  padding_pre  =>
#  padding_post =>
#  seperator    =>
##################################################################
sub tran_pin_d124 {

  my $self = shift;
  my $args = { @_ };

  my $cmdstr = "\xD1\x24" . num2bin(length $args->{pik1}) . $args->{pik1}  .
                            num2bin(length $args->{pik2}) . $args->{pik2}  .
                            $args->{format1} .
                            $args->{format2} .
                            $args->{pinblock} . 
                            $args->{padding_pre} .
                            $args->{seperator} .
                            $args->{padding_post};

  my $resp = $self->cmd_18(\$cmdstr);
  unless($resp) {
    return undef;
  }

  return {
    pin => $resp->[0],
  };

}

##################################################################
#  undef system failed, problem restart  
#  0     失败
#  > 0   读到字节数  
##################################################################
sub recv {

  my $self = shift;
  my $dref = shift;
  my $logger = $self->{logger};

  my ($nfound, $timeout) = select($self->{rin}, $self->{win}, $self->{ein}, $self->{timeout});
  unless($nfound) {
    return undef;
  }

  my $len  = read($self->{slj}, $$dref, 8192);

  # 加密机关闭了连接  
  if ($len == 0 ) {
    $logger->error("hsm closed me");
    return undef;
  }
  $logger->debug("got [" . unpack("H*", $$dref) . "]");

  # 收到加密机的错误应答   
  if ($$dref =~ /^E/ ) {
    if ( $len == 2) {
      return 0;
    }
    elsif($len == 1)  {
      my ($nfound, $timeout) = select($self->{rin}, $self->{win}, $self->{ein}, $self->{timeout});
      unless($nfound) {
        return undef;
      }
      my $len = read($self->{slj}, $$dref, 1);
      unless($len) {
        return undef;
      }
      $logger->debug("got [" . unpack("H*", $$dref) . "]");
    }
    else {
      return undef;
    }
  }  

  return $len;
}

##################################################################
# 在指定时间内独到指定长度的数据  
##################################################################
sub read {

  my $self    = shift;
  my $dref    = shift;
  my $len     = shift;

  my $select  = $self->{select};
  my $timeout = $self->{timeout};
  my $slj     = $self->{slj};
  my $logger  = $self->{logger};

  my $data;
  my $nfound;
  my $left = $len;
  while(1) {

    ($nfound, $timeout) = select($self->{rin}, $self->{win}, $self->{ein}, $timeout);
    unless($nfound) {
      last;
    }

    my $tmp;
    my $tlen = read($slj, $tmp, $left);
    $logger->debug("got [" . unpack("H*", $tmp) ."]");
    $$dref .= $tmp;
    $left -= $tlen;
    if ($left == 0 ) {
      return $data;
    }
  }

  return undef;
}

##################################################################
#
##################################################################
sub cmd_18 {

  my $self = shift;
  my $cref = shift;

  my $logger = $self->{logger};
  my $slj    = $self->{slj};

  ###################################
  # 发送请求到加密机 
  $logger->debug("snd [" . unpack("H*", $$cref) . "]");
  unless( $slj->send($$cref) ) {
    $logger->error("snd [" . unpack("H*", $$cref) . "] error");
    return undef;
  }

  ###################################
  # 读加密机 
  # $logger->debug("begin recv...");
  my $resp;
  my $len = $self->recv(\$resp);
  unless(defined $len) {   # 发生系统错误  
    $logger->error("rcv error");
    return undef;
  }
  unless($len) {   # 收到机密机 'E'
    return 0;
  }
  if ($len < 9 ) {
    # $logger->debug("begin read...");
    my $data;
    unless( $self->read(\$data, 9 - $len) ) {
      return undef; 
    }
    $resp .= $data;
  }

  return [ substr($resp, 1, 8) ];
}

##################################################################
#
##################################################################
sub cmd_11n {

  my $self = shift;
  my $cref = shift;

  my $logger = $self->{logger};
  my $slj    = $self->{slj};

  ###################################
  # 发送请求到加密机 
  $logger->debug("snd [" . unpack("H*", $$cref) . "]");
  unless( $slj->send($$cref) ) {
    $logger->error("snd [" . unpack("H*", $$cref) . "] error");
    return undef;
  }

  ###################################
  # 读加密机 
  # $logger->debug("begin recv...");
  my $resp;
  my $len = $self->recv(\$resp);
  unless(defined $len) {   # 发生系统错误  
    $logger->error("rcv error");
    return undef;
  }
  unless($len) {   # 收到机密机 'E'
    return 0;
  }

  # 读长度位   
  if ($len < 2 ) {
    # $logger->debug("begin read...");
    my $data;
    my $len_2 = $self->read(\$data, 1);
    unless($len_2) {
      return undef; 
    }
    $resp .= $data;
  }

  ###################################
  # 加密机返回成功
  # 且读取的长度 >= 2
  ###################################
  my $klen_read = bin2num(substr($resp,1,1));
  $resp = substr($resp, 2);
  my $resp_len  = length $resp;
  my $rest_len  = $klen_read - $resp_len;
   
  if ($rest_len > 0 ) {
    my $data;
    $logger->debug("begin read...");
    unless($self->read(\$data, $rest_len)) {
      $self->connect();
      return undef;
    }
  }

  return [ $resp ];
}

##################################################################
#
##################################################################
sub cmd_11n8 {

  my $self = shift;
  my $cref = shift;

  my $logger = $self->{logger};
  my $slj    = $self->{slj};

  ###################################
  # 发送请求到加密机 
  $logger->debug("snd [" . unpack("H*", $$cref) . "]");
  unless( $slj->send($$cref) ) {
    $logger->error("snd [" . unpack("H*", $$cref) . "] error");
    return undef;
  }

  ###################################
  # 读加密机 
  # $logger->debug("begin recv...");
  my $resp;
  my $len = $self->recv(\$resp);
  unless(defined $len) {   # 发生系统错误  
    $logger->error("rcv error");
    return undef;
  }
  unless($len) {   # 收到机密机 'E'
    return 0;
  }

  if ($len < 2 ) {
    # $logger->debug("begin read...");
    my $data;
    my $len_2 = $self->read(\$data, 1);
    unless($len_2) {
      return undef; 
    }
    $resp .= $data;
  }

  ###################################
  # 加密机返回成功
  # 且读取的长度 >= 2
  ###################################
  my $klen_read = bin2num(substr($resp,1,1));
  $resp = substr($resp, 2);
  my $resp_len  = length $resp;
  my $rest_len  = $klen_read + 8 - $resp_len;
   
  if ($rest_len > 0 ) {
    my $data;
    $logger->debug("begin read...");
    unless($self->read(\$data, $rest_len)) {
      $self->connect();
      return undef;
    }
    $resp .= $data;
  } 

  return [ 
    substr($resp, 0, $klen_read),
    substr($resp, $klen_read)
  ];

}

##################################################################
#
##################################################################
sub cmd_11nn8 {

  my $self = shift;
  my $cref = shift;

  my $logger = $self->{logger};
  my $slj    = $self->{slj};

  ###################################
  # 发送请求到加密机 
  $logger->debug("snd [" . unpack("H*", $$cref) . "]");
  unless( $slj->send($$cref) ) {
    $logger->error("snd [" . unpack("H*", $$cref) . "] error");
    return undef;
  }

  ###################################
  # 读加密机 
  # $logger->debug("begin recv...");
  my $resp;
  my $len = $self->recv(\$resp);
  unless(defined $len) {   # 发生系统错误  
    $logger->error("rcv error");
    return undef;
  }
  unless($len) {   # 收到机密机 'E'
    return 0;
  }

  if ($len < 2 ) {
    # $logger->debug("begin read...");
    my $data;
    my $len_2 = $self->read(\$data, 1);
    unless($len_2) {
      return undef; 
    }
    $resp .= $data;
  }

  ###################################
  # 加密机返回成功
  # 且读取的长度 >= 2
  ###################################
  my $klen_read = bin2num(substr($resp,1,1));
  $resp = substr($resp, 2);
  my $resp_len  = length $resp;
  my $rest_len  = $klen_read * 2 + 8 - $resp_len;
   
  if ($rest_len > 0 ) {
    my $data;
    $logger->debug("begin read...");
    unless($self->read(\$data, $rest_len)) {
      $self->connect();
      return undef;
    }
    $resp .= $data;
  } 

  return [ 
    substr($resp, 0, $klen_read),               # N
    substr($resp, $klen_read, $klen_read),      # N
    substr($resp, $klen_read * 2 ),             # 8
  ];

}


1;


__END__

=head1 NAME
  
  Util::HSM::SLJ05 - SLJ05 API
  
=head1 SYNOPSIS
  
  #!/usr/bin/perl -w
  use strict;
  
  use Util::HSM::SLJ05;
  
  my $slj = Util::HSM::SLJ05->new(
    slj_ip   => '192.168.1.16',
    slj_port => 6666,
  );
  
  $slj->import_key_d102(...);
  $slj->export_key_d104(...);
  $slj->gen_key_d106(...);
  $slj->gen_key_d107(...);
  $slj->gen_mac_d132(...);
  $slj->ver_mac_d134(...);
  $slj->enc_key_d108(...);
  $slj->dec_pin_d126(...);
  $slj->tran_pin_d124(...);
  
=head1 DESCRIPTION
  
  Util::HSM::SLJ05 implemented the following instructions:
  
  D102  import key           11N8
  D104  export key           11N8
  D106  generate key         11N8
  D107  generate key         11NN8
  D108  encrypt plain key    11N8
  D124  pin transform        18
  D126  decrypt pin          11N
  D132  calculate mac        18
  D134  verify mac           18
  
=head1 key type constant
  
  KEY_TYPE_COMM    : "\x01"   # communication master key
  KEY_TYPE_PIN     : "\x02"   # pin encryption key
  KEY_TYPE_MAC     : "\x03"   # mac generation key
  KEY_TYPE_DATA    : "\x04"   # data encryption key
  KEY_TYPE_CVV     : "\x05"   # cvv calculation key
  
  
=head1 key length constant
  
  KEY_LEN_8        : "\x08"   # 8
  KEY_LEN_16       : "\x10"   # 16
  KEY_LEN_24       : "\x18"   # 24
  
=head1 MAC algorithm sign
  
  MAC_ALGO_XOR     : "\x01"   # xor
  MAC_ALGO_ANSI99  : "\x02"   # ansi9.1
  MAC_ALGO_ANSI919 : "\x03"   # ansi9.19
  
=head1 pin format
  
  PIN_FORMAT_01    : "\x01"   # "00" + (pin:6)
  PIN_FORMAT_02    : "\x02"   # [pin_len:1] + [pin:3]  + [FFFFFFFFFF:4] ?????
  PIN_FORMAT_03    : "\x03"   # BULL
  PIN_FORMAT_04    : "\x04"   # Interbold, ibm atm
  PIN_FORMAT_05    : "\x05"   # ncratm
  PIN_FORMAT_06    : "\x06"   # ???
  
=head1 API description
  
  import_key_d102
  export_key_d104
  gen_key_d106
  gen_key_d107
  enc_key_d108
  gen_mac_d132
  ver_mac_d134
  tran_pin_d124
  dec_pin_d126
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 import_key_d102
  
  wk_len       :  work key length
  ck_len       :  communication key length
  index        :  index 
  bmk          :  exists if index equal 0xFFFF, this is an LMK-encrypted bmk
  wk           :  this is bmk-encrypted work key
  chkval       :  check value
  
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 export_key_d104
  
  wk_len       :  work key length
  ck_len       :  communication key length
  index        :  index 
  ktype        :
  bmk          :  exists if index equal 0xFFFF, this is an LMK-encrypted bmk
  wk           :  this is bmk-encrypted work key
  chkval       :  check value
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 gen_key_d106
  
  klen         :  key length
  ktype        :  key type
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 gen_key_d107
  
  klen         :  key length
  ktype        :  key type
  tk_index     :  transfer key index
  tk           :  transfer master key
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 enc_key_d108
  
  ktyep        :  key type
  pkey         :  plain key value
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 gen_mac_d132
  
  algo         :  algorithm sign    :  MAC_ALGO_XOR, MAC_ALFO_ANSI99, MAC_ALGO_ANSI919
  mak          :  mac key
  iv           :  intialized vector
  data         :  input data
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 ver_mac_d134
  
  algo         :  algorithm sign    :  MAC_ALGO_XOR, MAC_ALFO_ANSI99, MAC_ALGO_ANSI919
  mak          :  mac key
  iv           :  intialized vector
  mac          :  mac to be verified
  data         :  input data
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 dec_pin_d126
  
  pik          :  LMK-encrypted PIK
  format       :  pin format: 01/02/03/04/05/06
  pin          :  encrypted pin
  padding      :  primary account number paddding symbol, length(12--19)
  
  
=head2 ---------------------------------------------------------------------------------------------
  
=head2 tran_pin_d124
  
  pik1         :  LMK-encrypted PIK 
  pik2         :  LMK-encrypted PIK 
  format1      :  pin format
  format2      :  pin format
  pinblock     :  pin block
  padding_pre  :  pre-transformation padding
  padding_post :  post-transformation padding
  seperator    :  seperator
  
=head1 AUTHORS & COPYRIGHTS
  
  zcman2005@gmail.com 
  
=cut
  
