package Util::Upgrade::Server;

use strict;
use warnings;

use POE;
use POE::Wheel::ListenAccept;
use POE::Wheel::ReadWrite;
use POE::Filter::Reference;
use IO::File;
use Util::Run;
use File::Copy;
use File::Path qw/mkpath/;
use File::Basename;

#######################################################################
# args:
#   localaddr      => 192.168.1.29
#   localport      => 5454
#   vscan_interval => 10,
#
#   app_home       => /home/hary/mcenter/
#                     /home/hary/mcenter/conf
#                     /home/hary/mcenter/etc
#                     /home/hary/mcenter/bin
#                     /home/hary/mcenter/libexec
#                     /home/hary/mcenter/log
#
#   upgrade_home   => /home/hary/mcenter/version/                   # 应用的主目录 
#                     /home/hary/mcenter/version/version.txt        # 待更新版本号    
#                     /home/hary/mcenter/version/0.1                # 版本目录  
#                     /home/hary/mcenter/version/0.1/list.txt       # 列表  
#                     /home/hary/mcenter/version/0.1/libexec/ma.pl  # 文件 
#                     /home/hary/mcenter/version/0.1/libexec/mb.pl
#                     /home/hary/mcenter/version/0.1/conf/server.conf
#                     /home/hary/mcenter/version/0.1/conf/client.conf
#                     ...
#                     ...
#######################################################################
sub spawn {

  my $class  = shift;
  my $args   = { @_ };

  my $self = bless $args, $class;

  # 日志
  my $logger = $run_kernel->{logger}->clone("$0.server.log");
  $self->{logger} = $logger;
  $logger->debug("$0 spawn with:\n" . Data::Dump->dump($self));

  # 读取版本文件 $upgrade_home/version.txt
  unless($self->get_version_list()) {
    $logger->error("can not get verion list");
    return undef;
  }
  
  # POE session
  POE::Session->create(
    object_states => [
      $self => {
        '_start'           => 'on_start',              # 
        'on_accept'        => 'on_accept',             #
        'on_socket_error'  => 'on_socket_error',       # socket错误 
        'on_request'       => 'on_request',            # 收到客户端请求  
        'on_upgrade_list'  => 'on_upgrade_list',       # 请求更新列表
        'on_request_file'  => 'on_request_file',       # 请求文件
        'on_upgrade_check' => 'on_upgrade_check',      # 升级检查
        'on_version_scan'  => 'on_version_scan',       # 检查是否自身需要更新  
      },
    ],
    args => [],
  );
}

###########################################
# 初始化 
###########################################
sub on_start {
  
  my $self = $_[OBJECT];
  my $logger = $self->{logger};
  
  my $sock = IO::Socket::INET->new(
    LocalAddr => $self->{localaddr},
    LocalPort => $self->{localport},
    ReuseAddr => 1,
    Listen    => 5,
  );
  unless($sock) {
    $logger->error("can not start LA on[$self->{localaddr}:$self->{localport}]");
    $_[KERNEL]->delay('on_start'  => 2 );
    return 1;
  }
  
  my $la = POE::Wheel::ListenAccept->new(
    Handle      => $sock,
    AcceptEvent => "on_accept",
    ErrorEvent  => "on_socket_error",
  );
  unless($la) {
    $logger->error("can not create LA wheel");
    $_[KERNEL]->delay('on_start'  => 2 );
    return 1;
  }
  $_[HEAP]{la} = $la;

  $_[KERNEL]->yield("on_version_scan");
  
  return 1;
}

###########################################
# 定期扫描版本更新  
###########################################
sub on_version_scan {

  my $self = $_[OBJECT] ;

  $self->{logger}->debug("begin check...");

  my $fstat = [ stat "$self->{upgrade_home}/version.txt" ];
  unless($fstat) {
    $_[KERNEL]->delay('on_version_scan' => $self->{vscan_interval});
    return 1;
  }

  # version.txt文件更新了  
  if ($fstat->[9] > $self->{mtime}) {

    # 读取version.txt
    $self->{logger}->debug("version.txt modified, begin self-upgrade");
    unless($self->get_version_list()) {
      $self->{logger}->error("can not get_version_list");
      $_[KERNEL]->delay('on_version_scan' => $self->{vscan_interval});
      return 1;
    }
    $self->{logger}->debug("get version list[@{$self->{vhist}}]");

    # 获取最后版本号  
    my $vlast = $self->{vhist}->[-1];
    my $ldir = "$self->{upgrade_home}/$vlast";
    my $lfh  = IO::File->new("<$ldir/list.txt");
    unless($lfh) {
      $self->{logger}->error("can not open[$ldir/list.txt]");
      $_[KERNEL]->delay('on_version_scan' => $self->{vscan_interval});
      return 1;
    }

    # 读取最新版本升级的list文件 
    my @filenames;
    while(<$lfh>) {
      chomp;
      push @filenames, $_;
    };

    # 更新文件部署  
    my $err = 0; 
    for (@filenames) {
      $self->{logger}->info("begin install $_...");
      unless(copy("$ldir/$_",  "$self->{app_home}/$_")) {
        $self->{logger}->error("can not copy($ldir/$_,  $self->{app_home}/$_)");
        $err++;
      }
    }
    if ($err) {
      $_[KERNEL]->delay('on_version_scan' => $self->{vscan_interval});
      return 1;
    }

    # 重启 
    $self->restart();
  }
  
  $_[KERNEL]->delay('on_version_scan' => $self->{vscan_interval});
}

###########################################
# 客户端连接
###########################################
sub on_accept {
  my $self   = $_[OBJECT];
  my $socket = $_[ARG0];
  my $logger = $self->{logger};

  my $client = POE::Wheel::ReadWrite->new(
    Handle       => $socket,
    Filter       => POE::Filter::Reference->new(),
    InputEvent   => 'on_request',
    FlushedEvent => 'on_flush',
  );
  unless($client) {
    $logger->error("can not creat wheel for client",  $socket->peeraddr());
    return 1;
  }

  $_[HEAP]{client}{$client->ID} = $client;
}

###########################################
# 通讯错误
###########################################
sub on_socket_error {
  my $self = $_[OBJECT];
  my $logger = $self->{logger};
  $logger->error("on_socket_error: op[$_[ARG0]] errno[$_[ARG1]] errstr[$_[ARG2]] id[$_[ARG3]]");
  delete $_[HEAP]{client}{$_[ARG3]};
  $_[KERNEL]->yield('on_start');
}

###########################################
# 
###########################################
sub on_flush {
  delete $_[HEAP]{client}{$_[ARG0]};
}

###########################################
# 收到客户端发起升级检查
# req:
#   {
#      action   => 'upgrade_check',
#      version  => 0.1, 
#   }
###########################################
sub on_upgrade_check {
  
  my $self   = $_[OBJECT];
  my $logger = $self->{logger};
  my $req    = $_[ARG0];
  my $client = $_[HEAP]{client}{$_[ARG1]};

  # 查看版本历史  
  my $vhist = $self->{vhist};
  my $idx;
  for ($idx = 0; $idx < @$vhist; ++$idx) {
    last if $req->{version} == $vhist->[$idx];
  }
  if ($idx == @$vhist) {
    $req->{status} = 2;
    $req->{errmsg} = "server nerver published version $req->{version}";
    goto ENDING;
    return 1;
  }
  
  # 已经是最新版本
  if ($idx == @$vhist - 1) {
    $req->{status} = 0;
    goto ENDING;
  }
  
  # 需要更新
  $req->{version} = $vhist->[$idx+1];
  $req->{status}  = 0;

ENDING:
  $logger->debug("resposne:\n" . Data::Dump->dump($req));
  $client->put($req);
  return 1;
  
}


###########################################
# 收到 客户端发起获取更新列表
# req:
#   {
#     action  => 'upgrade_list',
#     version => 0.4,
#   }
###########################################
sub on_upgrade_list {
  
  my $self   = $_[OBJECT];
  my $logger = $self->{logger};
  my $req    = $_[ARG0];
  my $client = $_[HEAP]{client}{$_[ARG1]};
  
  my $lfile = $self->{upgrade_home} . "/$req->{version}/list.txt";
  unless( -f $lfile) {
    $logger->error("file $lfile does not exist");
    $req->{status} = 1;
    $req->{errmsg} = "500 server error";
    goto ENDING;
  }
  
  # 读取更新文件列表
  my $lfh = IO::File->new("<$lfile");
  unless($lfh) {
    $logger->error("can not open file $lfile");
    $req->{status} = 1;
    $req->{errmsg} = "500 server error";
    goto ENDING;
  }
  my @list;
  while(<$lfh>) {
    chomp;
    push @list, $_;
  }
  
  # 响应请求
  $req->{status} = 0;
  $req->{list}   = \@list;
 
ENDING:
  $logger->debug("resposne:\n" . Data::Dump->dump($req));
  $client->put($req);
   
  return 1;
}


###########################################
# 客户端发起请求文件
# req:
#   {
#     version  => 0.4,
#     filename => "libexec/monitor.pl",
#   }
###########################################
sub on_request_file {
  
  my $self   = $_[OBJECT];
  my $logger = $self->{logger};
  my $req    = $_[ARG0];
  my $client = $_[HEAP]{client}{$_[ARG1]};
  
  my $file = $self->{upgrade_home} . "/$req->{version}/$req->{filename}";
  unless(-f $file) {
    $logger->error();
    $req->{status} = 1;
    $req->{errmsg} = "file $file does not exist";
    goto ENDING;
  }
  my $fh = IO::File->new("<$file");
  unless($fh) {
    $logger->error();
    $req->{status} = 1;
    $req->{errmsg} = "$file can not be opened";
    goto ENDING;
  }
  local $/;
  $req->{content} = <$fh>;
  $req->{status}  = 0;

ENDING:
  $logger->debug("resposne:\n" . Data::Dump->dump($req));
  $client->put($req);
  
  return 1;
}

###########################################
# 收到客户端请求
###########################################
sub on_request {
  my $self   = $_[OBJECT];
  my $logger = $self->{logger};
  my ($req, $id) = @_[ARG0,ARG1];
  
  $logger->debug("request:\n" . Data::Dump->dump($req));

  if ( $req->{action} =~ /upgrade_check/ ) {
    $_[KERNEL]->yield('on_upgrade_check', $req, $id);
    return 1;
  }
  
  if ( $req->{action} =~ /upgrade_list/ ) {
    $_[KERNEL]->yield('on_upgrade_list', $req, $id);
    return 1;
  }
  
  if ( $req->{action} =~ /request_file/ ) {
    $_[KERNEL]->yield('on_request_file', $req, $id);
    return 1;
  }
  
  if ($req->{action} =~ /end/) {
    delete $_[HEAP]{client}{$id};
    $logger->info("");
    return 1;
  }
  
  my $client = $_[HEAP]{client}{$id};
  $logger->warn("unrecognized request from:\n" . Data::Dump->dump($req));
  delete $_[HEAP]{client}{$id};
  return 1;
}

###########################################
# 读取版本更新历史
###########################################
sub get_version_list {

  my $self  = shift;

  my $old_version = $self->{version};
  my $old_mtime   = $self->{mtime};

  my $vfile = "$self->{upgrade_home}/version.txt";
  my $vfh   = IO::File->new("<$vfile");
  unless($vfh) {
    $self->{logger}->error("can not open file $vfile");
    return undef;
  }
  my @version;
  while(<$vfh>) {
    chomp;
    # warn "got version $_";
    push @version, $_;
  }

  my $fstat = [stat $vfh];
  unless($fstat) {
    $self->{logger}->error("can not stat $vfile");
    return undef;
  }


  $self->{vhist} = \@version;
  $self->{mtime} = $fstat->[9];

  return $self;
}


###########################################
# 重启系统
###########################################
sub restart {

  my $self = shift;
  my $logger = $self->{logger};

  local $SIG{HUP} = 'IGNORE';

  $logger->warn(">>>>>>>>>>>>>>>>Restarting...");

  my $leader = getppid;
  kill -1, $leader;  # send hup to process group execept myself
  unless (POSIX::setsid( )) {
    $logger->error("Couldn't start a new session: $!");
    exit 0;
  }

  my $cmdline = $run_kernel->{cmdline};
  unless (exec $run_kernel->{cmdline}) {
    $logger->error("can not restart with[$cmdline]");
  }

  exit 0;
}


1;
