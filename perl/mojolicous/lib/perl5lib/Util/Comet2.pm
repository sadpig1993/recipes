package Util::Comet;

use strict;
use warnings;

use Carp qw/cluck/;

use POE::Session;
use Util::IniParse qw/ini_parse/;
use Util::Comet::SI;          # simplex, 单工双链  
use Util::Comet::DA;          # duplex active, 双工主动 
use Util::Comet::DR;          # duplex reactive, 双工被动 
use Util::Comet::TC;          # tcp短连接客户端
use Util::Comet::TC::HTTP;    # http客户端
use Util::Comet::TS;          # tcp短连接服务器端 
use Util::Comet::TS::HTTP;    # http服务器端 

#####################################################
# 机构通讯服务器 
#----------------------------------------------------
#  session A       <==>  机构A
#  session B       <==>  机构B
#  session C       <==>  机构C
#  session D       <==>  机构D
#  session E       <==>  机构E
#  session Adapter <==>  pack/unpack
#----------------------------------------------------
# 1> session A 从机构A收到机构数据$packet发送给unpack 
#----------------------------------------------------
#    1) 一般机构:
#      $data = {
#        src    => 机构A 
#        packet => $packet,
#      }
#      post('adapter', 'on_remote_data', $data);
#    2) 对于HS/TS,
#      $data = {
#        src    => 机构A
#        packet => $packet,
#        sid    => 'HS/TS wheel ID',
#      }
#      post('adapter', 'on_remote_data', $data);
#----------------------------------------------------
# 2> adapter 从pack收到数据   
#----------------------------------------------------
#    {
#      packet  => $packet,
#      dst     => 机构xxx,
#      skey    => 'TC/HC 同步session key' 可选  
#    }
#    1) post('机构xxx', 'on_adapter_data', $packet);
#    2) 机构xxx将$packet发送给机构
#    3) 对于TC/HC, 机构响应时候要将skey带回给adapter
######################################################


###############################################################
# logger     => $logger,                  # 日志对象 
# ins|conf   => \%ins|/conf/file,         # 从参数,或者从配置文件读取
# adapter    => 'queue|pipe|My::Adapter'  #
# ad_args    => [ ] | {}
###############################################################
sub spawn {

  my $class = shift;
  my $args  = { @_ };

  my $logger  = delete $args->{logger};
  unless($logger) {
    cluck "logger must be provided";
    return undef;
  }

  #################################
  # 机构配置参数检查  
  #################################
  my $iconfig = delete $args->{ins};
  unless ( $iconfig ) {
    my $cfile = delete $args->{conf};
    unless( -f $cfile) {
      cluck "institute configuration list/file must be provided";
      return undef;
    }
    $iconfig = ini_parse($cfile);
    unless($iconfig) {
      $logger->error("can not parse file $cfile");
      return undef;
    }
  } 
  unless($iconfig) {
    cluck "institute configuration list must be provided";
    return undef;
  }
  
  # 检查机构线路参数  
  for my $iname ( keys %{$iconfig}) {
    unless(&iconfig_check($iname, $iconfig->{$iname})) {
      $logger->error("check config for $iname failed");
      return undef;
    }
  }
  #################################
  # adapter配置参数经检查 
  #################################
  my $ad_name = $args->{adapter};
  my @ad_args;
  my $arg_ref = ref $args->{ad_args};

  ##############################################################
  # iconfig 配置格式: 
  # [ins_name]
  # mode     = si
  # lines    = ip:addr<=>ip:addr
  # interval = 20
  # timeout  = 30
  # codec    = 'ins_enc ins_dec'
  ##############################################################
  for my $ins (keys %{$iconfig}) {

    my $ins_config = delete $iconfig->{$ins};

    $ins_config->{name} = $ins; 
    my $mode = lc delete $ins_config->{mode};
    my $is;

    my @lines_cfg = split '\s+', delete $ins_config->{lines};
    my @lines; 

    ###################################
    #  单工双链, 多对线路  
    ###################################
    if ($mode =~ /^si$/) {
      my $idx = 0;
      $logger->debug("beg create session[SI] for $ins.$idx");
      for my $line (@lines_cfg) {
        my $lsconfig = { %$ins_config };
        my($localaddr, $localport, $remoteaddr, $remoteport) = ($line =~ /(.*):(.*)\<=\>(.*):(.*)/);
        # $logger->debug("$localaddr, $localport, $remoteaddr, $remoteport");
        unless(defined $localaddr) {
          return undef;
        }
        $lsconfig->{name}       = $lsconfig->{name};
        $lsconfig->{idx}        = $idx;
        $lsconfig->{localaddr}  = $localaddr;
        $lsconfig->{localport}  = $localport;
        $lsconfig->{remoteaddr} = $remoteaddr;
        $lsconfig->{remoteport} = $remoteport;
        # 每条线路都用自己的日志 
        my $logname = $lsconfig->{name}       . "." . 
                      $lsconfig->{idx}        . "." . 
                      $lsconfig->{remoteaddr} . "-" . 
                      $lsconfig->{remoteport} . "." . 
                      "$mode.log";
        my $newlog = $logger->clone($logname);
        # $logger->debug("begin spawn new session for $lsconfig->{name}" );
        my $ls = Util::Comet::SI->spawn($newlog, $lsconfig);
        push @lines, $ls;
        $idx++;
      }
    }
    #################################################
    # 双工被动        : dr
    # 双工主动        : da
    # tcp短连接客户端 : tc
    # tcp短连接服务端 : ts 
    # http客户端      : hc
    # http服务端      : hs 
    #################################################
    elsif ($mode =~ /^(dr|da|tc|ts|hc|hs).*/) {

      my $uc_mode = uc $mode;
      my $pkg;
      if ($mode =~ /^hc/) {
        $pkg = 'Util::Comet::TC::HTTP';
      } elsif ($mode =~ /hs/ ) {
        $pkg = 'Util::Comet::TS::HTTP';
      } else {
        $pkg = 'Util::Comet::' . $uc_mode;
      }

      my $idx = 0;
      for my $line (@lines_cfg) {
        my ($addr, $port) = ( $line =~ /(.*):(.*)/);
        my $lsconfig = { %$ins_config };

        $logger->debug("beg create session[$uc_mode] for $ins.$idx");
        my $addr_name;
        my $port_name;
        #
        # da tc hc  为客户端， 需要remote
        #
        if ($mode =~ /^(da|tc|hc)/) {
          $addr_name = "remoteaddr";
          $port_name = "remoteport";
        } 
        #
        # dr ts hs  为服务端， 需要local
        #
        else {
          $addr_name = "localaddr";
          $port_name = "localport";
        }

        $lsconfig->{name}       = $lsconfig->{name};
        $lsconfig->{idx}        = $idx;
        $lsconfig->{$addr_name} = $addr;
        $lsconfig->{$port_name} = $port;

        # 每条线路都用自己的日志 
        my $logname = $lsconfig->{name}       . "." . 
                      $lsconfig->{idx}        . "." . 
                      $lsconfig->{$addr_name} . "-" . 
                      $lsconfig->{$port_name} . "." . 
                      "$mode.log";
        my $newlog = $logger->clone($logname);

        # 启动线路session 
        $logger->debug("spawn $pkg with:\n" . Data::Dump->dump($lsconfig));
        my $ls = $pkg->spawn($newlog, $lsconfig);
        push @lines, $ls;
        $idx++;
      }

    }
    #############################
    # 定制化配置  
    #############################
    elsif($mode =~ /cust\s+(.*)\s*/) {

      # 加载指定的模块 
      my $pkg = $1;
      eval "use $pkg;";
      if ($@) {
        $logger->error("can not load package $pkg"); 
        return undef;
      }

      my $idx = 0;
      for my $line (@lines_cfg) {
        warn "$line";
        my $lsconfig = { %$ins_config };
        $lsconfig->{line} = $line;
        $lsconfig->{name} = $lsconfig->{name} . "." . "$idx";

        $logger->debug("begin spawn new session for $lsconfig->{name}" ); 
        my $newlog = $logger->clone($lsconfig->{name} . "." . $lsconfig->{idx} . "cust.log");
        my $ls = $pkg->spawn($newlog, $ins_config);
        push @lines, $ls;
        $idx++;
      }
    }
    else {
      $logger->error("unrecognizable mode[$mode] institute[$ins]" );
      return undef;
    }
  }

  ############################
  #  adapter 模块  
  ############################
  if ('HASH' eq $arg_ref) {
    @ad_args = %{$args->{ad_args}}; 
  }
  elsif( 'ARRAY' eq $arg_ref) {
    @ad_args = @{$args->{ad_args}}; 
  } 
  else {
    $logger->error("ad_args must be either of hashref or arrayref");
    return undef;
  }

  eval "use $ad_name;";
  if ($@) {
    $logger->error("can not load $ad_name\[$@]");
    return undef;
  }
  $logger->debug("begin spawn adapter[$ad_name] with args:\n" . Data::Dump->dump(\@ad_args));
  my $ad = $ad_name->spawn(
     logger   => $logger,
     @ad_args,
  );
  unless($ad) {
    $logger->error("can not create Adapter::Pipe");
    return undef;
  }
  # $logger->debug("normal Comet Sessions:\n" . Data::Dump->dump(\%sessions));
  return 1;

}

##############################################################
# iconfig 格式: 
# [ins_name]
# mode     = si
# lines    = ip:addr<=>ip:addr ip:addr<=>ip:addr 
# interval = 20
# timeout  = 30
# codec    = 'ins_enc ins_dec'
##############################################################
sub iconfig_check {
  my $iname   =  shift;
  my $iconfig =  shift;
 
  # mode
  unless( $iconfig->{mode}) {
    cluck "$iname mode does not configured:\n" . Data::Dump->dump($iconfig);
    return undef;
  }

  # codec
  if ($iconfig->{mode} =~ /^(da|dr|si|tc|ts)/) {
    unless ($iconfig->{codec}) {
      cluck "$iname mode[da|dr|si|tc|ts], codec must be provided";
      return undef;
    }
  }

  # lines
  unless( $iconfig->{lines} ) {
    cluck "$iname lines does not configured";
    return undef;
  }
  if ($iconfig->{mode} =~ /si/) {
    unless( $iconfig->{lines} =~ /(.*):(.*)<=>(.*):(.*)/ ) {
      cluck "invalid format for $iname si lines configuration[$iconfig->{lines}]";
      return undef;
    }
  }

  return 1;
}


1;

__END__


=head1 NAME

Util::Comet  - a communication framework for multi-institute switch

  Common Switch Senario:

  unpack :  module used for transforming incoming packet to inner swith data 
  pack   :  module used for transforming inner swith data to out-going packet
  switch :  module used for loggging txn, routing etc...

              ---------
  ------     \|       |                               |------|
  | DA |------|       |                               |      |
  ------     /|       |             ------------      |      |
              |       |             |  unpack  |------|      |
              |       |             ------------      |      |
  ------/     |       |             /                 |      |
  | DR |------|       |            /                  |      |
  ------\     |       |________   /                   |      |
              |       |        | /                    |      |
              |       |        |/                     |      |
  ------/    \| Comet | Adapter|                      |Switch|
  | SI |------|       |        |\                     |      |
  ------\    /|       |        | \                    |      |
              |       |________|  \                   |      |
              |       |            \                  |      |
  ------     \|       |             \                 |      |
  | TC |------|       |             ------------      |      |
  ------     /|       |             |  pack    |------|      |
              |       |             ------------      |      |
              |       |                               |      | 
  ------/     |       |                               |------|
  | TS |------|       |
  ------\     |       |
              ---------

=head1 SYNOPSIS

  #!/usr/bin/perl -w
  use strict;
  
  my $comet = Util::Comet->spawn(
    logger  => $logger,
    ins     => \%ins,
    adapter => 'Tino::Comet::Adapter::Container',
    ad_args => \%ad_args,
  ); 


  $comet->run();


=head1 Component

  Util::Comet::DA         : Duplex Active Long Connection
  Util::Comet::DR         : Duplex Reactive Long Connection 
  Util::Comet::SI         : Simplex
  Util::Comet::TC         : TCP  Client
  Util::Comet::TC::HTTP   : HTTP Client
  Util::Comet::TS         : TCP  Server
  Util::Comet::TS::HTTP   : HTTP Server
  Util::Comet::Adapter    : Adapter between institute and inner modules


=head2 Util::Comet::DA

  Duplex Active

=head3 Subclass API

  _on_start    : customizable configuration
  _on_connect  : after connected to remote, you can do some negotiation in it
  _packet      : recieved packet from remote, change it
  _adapter     : recieved data from adapter, change it

=head3 _on_start($class, $heap, $kernel, $args)

=head3 _on_connect($class, $heap, $kernel)

=head3 _packet($class, $heap, $remote_data)

=head3 _adapter($class, $heap, $adapter_data)


=head2 Util::Comet::DR

  Duplex Reactive

=head3 Subclass API

  _on_start    : customizable configuration
  _on_accept   : after got a client, you can do some negotiation with the client
  _packet      : recieved packet from remote, change it
  _adapter     : recieved data from adapter, change it

=head3 _on_start($class, $heap, $kernel, $args)

=head3 _on_accept($class, $heap, $kernel)

=head3 _packet($class, $heap, $remote_data)

=head3 _adapter($class, $heap, $adapter_data)


=head2 Util::Comet::SI

  Simplex  

=head3 Subclass API

  _on_start    : customizable configuration
  _on_connect  : after connected to remote, you can do some negotiation in it
  _on_accept   : after got a client, you can do some negotiation with the client
  _packet      : recieved packet from remote, change it
  _adapter     : recieved data from adapter, change it

=head3 _on_start($class, $heap, $kernel, $args)

=head3 _on_connect($class, $heap, $kernel)

=head3 _on_accept($class, $heap, $kernel)

=head3 _packet($class, $heap, $remote_data)

=head3 _adapter($class, $heap, $adapter_data)


=head2 Util::Comet::TC

  TCP Client

=head3 Subclass API

  _on_start
  _request
  _packet 

=head3 _on_start

=head3 _request

=head3 _adapter


=head2 Util::Comet::TS

  TCP Server

=head3 Subclass API

  _on_start
  _request
  _packet 

=head3 _on_start

=head3 _response

=head3 _packet


=head2 Util::Comet::Adapter

  Adatper

=head3 Subclass API

  _on_start          : customizable configuration
  _recv_wheel        : how to recieve data from other module
  _send_wheel        : hot to send data to other module
  _remote_filter     : after recieve data from institute, change it
  _adapter_filter    : after recieve data from inner module, change it
  _on_session_join   : institute line negotiated, the line session will notify adapter
  _on_session_leave  : institute line lost, the line session will notify adapter

=head3 _on_start($class,$heap,$kernel,$args)

=head3 _recv_wheel($class,$heap,$recv_arg)

=head3 _send_wheel($class,$heap,$send_arg)

=head3 _remote_filter($class,$heap,$remote_data)

=head3 _adapter_filter($class,$heap,$adapter_data)

=head3 _on_session_join($heap,$kernel,$cookie)

=head3 _on_session_leave($heap,$kernek,$cookie)


=head1 Author

  zcman2005@gmail.com

=cut



