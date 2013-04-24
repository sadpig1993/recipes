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
# ��Կ����˵��  
############################################################
sub KEY_TYPE_COMM    { "\x01" }   # 0x01: ͨ������Կ   
sub KEY_TYPE_PIN     { "\x11" }   # 0x11: PIN������Կ
sub KEY_TYPE_MAC     { "\x12" }   # 0x12: MAC������Կ 
sub KEY_TYPE_DATA    { "\x13" }   # 0x13: ���ݼ�����Կ 
sub KEY_TYPE_CVV     { "\x21" }   # 0x21: CVV������Կ 

############################################################
# ��Կ����  
############################################################
sub KEY_LEN_8        { "\x08" }   # ����8 
sub KEY_LEN_16       { "\x10" }   # ����16 
sub KEY_LEN_24       { "\x18" }   # ����24 

############################################################
# mac�㷨��ʾ  
############################################################
sub MAC_ALGO_XOR     { "\x01" }   # xor
sub MAC_ALGO_ANSI99  { "\x02" }   # ansi9.1
sub MAC_ALGO_ANSI919 { "\x03" }   # ansi9.19

############################################################
# pin��ʽ 
############################################################
sub PIN_FORMAT_01    { "\x01" }   # "00" + (pin:6)
sub PIN_FORMAT_02    { "\x02" }   # [pin_len:1] + [6��pinÿ��pinռ4bit:3]  + [FFFFFFFFFF:4] ?????
sub PIN_FORMAT_03    { "\x03" }   # BULL��ʽ:
sub PIN_FORMAT_04    { "\x04" }   # Interbold, ibm atm
sub PIN_FORMAT_05    { "\x05" }   # ncratm
sub PIN_FORMAT_06    { "\x06" }   #

############################################################
# logger   => $logger    # ��־  
# slj_ip   => $ip        # ���ܻ���ַ 
# slj_port => $port      # ���ܻ��˿�  
# timeout  => 2          # ���ʼ��ܻ���ʱʱ��   
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
# ���Ӽ��ܻ�  
############################################################
sub connect {

  my $self = shift;

  # ���Ӽ��ܻ�  
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
# ָ��: 
#       D106(�������������Կ) 
# ��ʽ: 
#       [����:2]
#       [��Կ����:1]         :  0x08, 0x10, 0x18
#       [��Կ����:1]         :  
# ���:
#       [Ӧ����:1]           :
#       [��Կ����:1]         :
#       [��Կ:N]             :  N = 8/16/24
#       [У����:8]           :
# ʧ��:
#       [Ӧ����:1]
#       [������:1]
# ˵��:
#       ����ָ�����ȵ����������Կ�����ü��ܻ���������Կ���ܺ󷵻���������Կ��У����  
##################################################################
# ��������:
#   klen   =>
#   ktype  =>   
##################################################################
sub gen_key_d106 {

  my $self  = shift;
  my $args  = { @_ };

  my $cmdstr = "\xD1\x06" . $args->{klen} . $args->{ktype};
  
  # ��Կ���� 
  # 0x01: ͨ������Կ;
  # 0x11: PIN������Կ��
  # 0x12: MAC������Կ��
  # 0x13: ���ݼ�����Կ
  # 0x21: CVV������Կ

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
# ָ��: 
#       D107(�������������Կ) 
# ��ʽ: 
#       [����:2]
#       [��Կ����:1]         :  0x08, 0x10, 0x18
#       [��Կ����:1]         :  
#       [��������Կ����:2]   :
#       [��������Կ����:1]   :
#       [��������Կ:N]       :  ZMK
# ���:
#       [Ӧ����:1]
#       [��Կ����:1]
#       [��Կ:N]             :  N = 8/16/24  LMK���ܵ���Կ  
#       [��Կ:N]             :  N = 8/16/24  ZMK���ܵ���Կ 
#       [У����:8]
# ʧ��:
#       [Ӧ����:1]
#       [������:1]
# ˵��:
#       ����ָ�����ȵ����������Կ������LMK��ָ����������Կ���ܺ󷵻�  
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
#                         ������Կ 
##################################################################
# ָ��: 
#       D102(������Կ) 
# ��ʽ: 
#       [����:2]            :  0xD102
#       [������Կ����:1]    :  0x08 | 0x10 | 0x18
#       [ͨ������Կ����:1]  :  0x08 | 0x10 | 0x18
#       [������:2]          :  0xFFFF
#       [BMK:N]             :  ������Ϊ0xFFFFʱ����ڣ� ΪLMK���ܹ���BMK 
#       [������Կ]          :  BMK���ܵ�����  
#       [У��ֵ����:1]      :  
#       [У��ֵ:N]          :
# ���:
#       [Ӧ����:1]
#       [WK��Կ����:1]
#       [WK��Կ:N]
#       [У����:8]
# ʧ��: 
#       [Ӧ����:1]
#       [������:1]
# ˵��: 
#       ������������Կ���ܵ���Կת��Ϊ�ñ�������Կ���� 
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
#                         ������Կ 
##################################################################
# ָ��: 
#       D104(������Կ) 
# ��ʽ: 
#       [����:2]
#       [������Կ����:1]     :  0x08, 0x10, 0x18
#       [ͨ������Կ����:1]   :  0x08, 0x10, 0x18 
#       [������:2]           :  0xFFFF
#       [��Կ����:1]         :  
#       [BMK:N]              :  ������Ϊ0xFFFFʱ����ڣ� ΪLMK���ܹ���BMK 
#       [������Կ:N]         :
#       [У��ֵ����:1]       :
#       [У��ֵ:N]           :
# ���:
#       [Ӧ����:1]
#       [WK��Կ����:1]
#       [WK��Կ:N]             :  N = 8/16/24
#       [У����:8]
# ʧ��:
#       [Ӧ����:1]
#       [������:1]
# ˵��:
#       ���ñ�������Կ���ܵ���Կת��Ϊ����������Կ���� 
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
# ָ��: 
#       D108(����������Կ) 
# ��ʽ: 
#       [����:2]
#       [��Կ����:1]         :  0x08, 0x10, 0x18
#       [��Կ����:1]         : 
#       [��Կ:N]             :  N = 8/16/24
# ���:
#       [Ӧ����:1]
#       [��Կ����:1]
#       [��Կ:N]             :  N = 8/16/24
#       [У����:8]
# ʧ��:
#       [Ӧ����:1]
#       [������:1]
# ˵��:
#       ����ָ�����ȵ�������Կ�����ü��ܻ���������Կ���ܺ󷵻���������Կ��У���� 
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
# ָ��: D134(У��mac)
# ��ʽ: 
#       [����:2]
#       [�㷨��־:1]        :  01: xor, 02: ANSI9.9,  03:ANSI9.19
#       [MAK����:1]         :  0x08, 0x10, 0x18
#       [MAK:N]             :  LMK���ܵ�MAK
#       [��ʼ����:8]
#       [MAC:4]             :  ҪУ���MAC 
#       [���ݳ���:2]        :
#       [����:N]            :
# ���:
#       [Ӧ����:1]
#       [MAC:8]
#    
# ʧ��:
#       [Ӧ����:1]
#       [������:1]
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
# ָ��: 
#       D132(����mac)
# ��ʽ: 
#       [����:2]
#       [�㷨��־:1]         :
#       [MAK����:1]          :
#       [MAK:N]              :
#       [��ʼ����:8]         :
#       [���ݳ���:2]         :
#       [����:N]             :
# ���:
#       [Ӧ����:1]
#       [MAC:8]
# ʧ��:
#       [Ӧ����:1]
#       [������:1]
# ˵��:
#       ��ȡLMK
#       ����LMK��Կ����
#       �����㷨��MAK���ȱ�־������Կ�ͼ���MAC
#       ����8�ֽ�MAC
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
# ָ��:
#       D126(����pin)
# ��ʽ: 
#       [PIK����:1]
#       [PIK:N]                   : N=8/16/24 LMK���ܵ�PIK 
#       [PIN��ʽ:1]               : 01/02/03/04/05/06
#       [PIN:8]                   : ����PIN  
#       [���˺Ų�λ��:12--19]     
# ���:
#       [Ӧ����:1]
#       [PIN����:1]
#       [PIN:N]                   : ����PIN 
# ʧ��:
#       [Ӧ����:1]
#       [������:1]
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
# ָ��:
#       D124(pinת��) 
# ��ʽ: 
#       [PIK1����:1]
#       [PIK1:N]                  : N=8/16/24 LMK���ܵ�PIK 
#       [PIK2����:1]
#       [PIK2:N]                  : N=8/16/24 LMK���ܵ�PIK 
#       [PIN1��ʽ:1]
#       [PIN2��ʽ:1]
#       [PINBlock:8]
#       [ת��ǰ���˺Ų�λ��:12--19]     
#       [�ָ���:1]
#       [ת�������˺Ų�λ��:12--19]     
# ���:
#       [Ӧ����:1]
#       [PIN:8]                   : ����PIN 
# ʧ��:
#       [Ӧ����:1]
#       [������:1]
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
#  0     ʧ��
#  > 0   �����ֽ���  
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

  # ���ܻ��ر�������  
  if ($len == 0 ) {
    $logger->error("hsm closed me");
    return undef;
  }
  $logger->debug("got [" . unpack("H*", $$dref) . "]");

  # �յ����ܻ��Ĵ���Ӧ��   
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
# ��ָ��ʱ���ڶ���ָ�����ȵ�����  
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
  # �������󵽼��ܻ� 
  $logger->debug("snd [" . unpack("H*", $$cref) . "]");
  unless( $slj->send($$cref) ) {
    $logger->error("snd [" . unpack("H*", $$cref) . "] error");
    return undef;
  }

  ###################################
  # �����ܻ� 
  # $logger->debug("begin recv...");
  my $resp;
  my $len = $self->recv(\$resp);
  unless(defined $len) {   # ����ϵͳ����  
    $logger->error("rcv error");
    return undef;
  }
  unless($len) {   # �յ����ܻ� 'E'
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
  # �������󵽼��ܻ� 
  $logger->debug("snd [" . unpack("H*", $$cref) . "]");
  unless( $slj->send($$cref) ) {
    $logger->error("snd [" . unpack("H*", $$cref) . "] error");
    return undef;
  }

  ###################################
  # �����ܻ� 
  # $logger->debug("begin recv...");
  my $resp;
  my $len = $self->recv(\$resp);
  unless(defined $len) {   # ����ϵͳ����  
    $logger->error("rcv error");
    return undef;
  }
  unless($len) {   # �յ����ܻ� 'E'
    return 0;
  }

  # ������λ   
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
  # ���ܻ����سɹ�
  # �Ҷ�ȡ�ĳ��� >= 2
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
  # �������󵽼��ܻ� 
  $logger->debug("snd [" . unpack("H*", $$cref) . "]");
  unless( $slj->send($$cref) ) {
    $logger->error("snd [" . unpack("H*", $$cref) . "] error");
    return undef;
  }

  ###################################
  # �����ܻ� 
  # $logger->debug("begin recv...");
  my $resp;
  my $len = $self->recv(\$resp);
  unless(defined $len) {   # ����ϵͳ����  
    $logger->error("rcv error");
    return undef;
  }
  unless($len) {   # �յ����ܻ� 'E'
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
  # ���ܻ����سɹ�
  # �Ҷ�ȡ�ĳ��� >= 2
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
  # �������󵽼��ܻ� 
  $logger->debug("snd [" . unpack("H*", $$cref) . "]");
  unless( $slj->send($$cref) ) {
    $logger->error("snd [" . unpack("H*", $$cref) . "] error");
    return undef;
  }

  ###################################
  # �����ܻ� 
  # $logger->debug("begin recv...");
  my $resp;
  my $len = $self->recv(\$resp);
  unless(defined $len) {   # ����ϵͳ����  
    $logger->error("rcv error");
    return undef;
  }
  unless($len) {   # �յ����ܻ� 'E'
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
  # ���ܻ����سɹ�
  # �Ҷ�ȡ�ĳ��� >= 2
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
  
