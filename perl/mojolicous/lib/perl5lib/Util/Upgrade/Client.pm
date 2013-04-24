package Util::Upgrade::Client;

use strict;
use warnings;
use IO::Socket::INET;
use IO::File;
use Util::Run;
use POE;
use POE::Wheel::ReadWrite;
use POE::Filter::Reference;
use File::Copy;
use File::Path qw/mkpath/;
use File::Basename;

#######################################################################
# args:
#   remoteaddr     => 192.168.1.29
#   remoteport     => 5454
#   chk_interval   => $chk_interval  # 检查更新周期
#   app_home       => /home/hary/app
#                     /home/hary/app/.version
#   upgrade_home   => /home/hary/app/version
#                     /home/hary/app/version/version.txt
#                     /home/hary/app/version/0.1
#                     /home/hary/app/version/0.1/list.txt
#                     /home/hary/app/version/0.1/conf
#                     /home/hary/app/version/0.1/etc
#                     /home/hary/app/version/0.1/libexec
#######################################################################
sub spawn {

  my $class  = shift;
  my $args   = { @_ };
  
  my $self = bless $args, $class;
  
  # 日志
  my $logger = $run_kernel->{logger}->clone("$0.client.log");
  $self->{logger} = $logger;

  # 版本文件检查
  my $vfile = "$self->{app_home}/.version";
  unless( -f $vfile ) {
    $logger->error("$vfile does not exists");
    return undef;
  }
  
  # 读取当前版本信息
  my $vfh = IO::File->new("< $self->{app_home}/.version");
  unless($vfh) {
    $logger->error("can not read version file[$vfile");
    return undef;
  }
  $self->{version} = <$vfh>;
  chomp $self->{version};
  
  # POE session
  POE::Session->create(
    object_states => [
      $self => {
        '_start'               => 'on_start',              #
        'on_socket_error'      => 'on_socket_error',       # socket错误 
        'on_response'          => 'on_response',           # 响应
        'on_upgrade_list'      => 'on_upgrade_list',       # 请求更新列表
        'on_upgrade_list_res'  => 'on_upgrade_list_res',   # 请求更新列表响应
        'on_request_file'      => 'on_request_file',       # 请求文件
        'on_request_file_res'  => 'on_request_file_res',   # 请求文件响应
        'on_upgrade_check'     => 'on_upgrade_check',      # 升级检查
        'on_upgrade_check_res' => 'on_upgrade_check_res',  # 升级检查响应
        'on_restart'           => 'on_restart',            # 重启
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
  
  # 开始定时检查更新
  $_[KERNEL]->yield('on_upgrade_check');
  
  return 1;
}

###########################################
# 通讯错误
###########################################
sub on_socket_error {

  my $self = $_[OBJECT];
  my $logger = $self->{logger};
  
  delete $self->{server};
  $logger->error("on_socket_error: op[$_[ARG0]] errno[$_[ARG1]] errstr[$_[ARG2]] id[$_[ARG3]]");
  $_[KERNEL]->delay('on_upgrade_check' => $self->{chk_interval});
  return 1;
  
}

###########################################
# 升级检查
# req:
#   {
#      action   => 'upgrade_check',
#      version  => 0.1, 
#   }
###########################################
sub on_upgrade_check {
  
  my $self = $_[OBJECT];
  my $logger = $self->{logger};
  
  # 连接服务器
  my $svr = IO::Socket::INET->new("$self->{remoteaddr}:$self->{remoteport}");
  unless($svr) {
    $logger->error("can not connect to $self->{remoteaddr}:$self->{remoteport}");
    $_[KERNEL]->delay('on_upgrade_check' => $self->{chk_interval});
    return 1;
  }
  
  my $wheel = POE::Wheel::ReadWrite->new(
    Handle     => $svr,
    Filter     => POE::Filter::Reference->new(),
    InputEvent => 'on_response',
    ErrorEvent => 'on_socket_error',
  );
  unless($wheel) {
    $logger->error("can not create wheel");
    $_[KERNEL]->delay('on_upgrade_check' => $self->{chk_interval});
    return 1;
  }
  $self->{server} = $wheel;
  
  # 发送升级申请
  my $req =  {
    action  => 'upgrade_check',
    version => $self->{version},
  };
  $logger->debug("request:\n" . Data::Dump->dump($req));
  $wheel->put($req);
    
  return 1;
}

###########################################
# 升级检查响应
###########################################
sub on_upgrade_check_res {
  
  my $self   = $_[OBJECT];
  my $args   = $_[ARG0];
  my $logger = $self->{logger};

    
  # 需要更新
  if ( $args->{version} ne $self->{version}) {

    $logger->info("begin upgrade from version[$self->{version}] to version[$args->{version}]");

    $self->{new_version} = $args->{version};
    $_[KERNEL]->yield('on_upgrade_list');
    mkpath("$self->{upgrade_home}/$args->{version}", { verbose => 0, mode => 0711} );

    return 1;
  } 
  
  # 本次检查不需要更新, 则定期再发送更新申请...
  $_[KERNEL]->delay('on_upgrade_check' => $self->{chk_interval});
  
  return 1;
}

###########################################
# 获取更新列表
# req:
#   {
#     action  => 'upgrade_list',
#     version => 0.4,
#   }
###########################################
sub on_upgrade_list {
  
  my $self   = $_[OBJECT];
  my $logger = $self->{logger};

  my $req = {
      action  => 'upgrade_list',
      version => $self->{new_version},
  };
  $logger->debug("request:\n" . Data::Dump->dump($req));  
  $self->{server}->put($req);
  
  return 1;
}

sub on_upgrade_list_res {

  my $self   = $_[OBJECT];
  my $args   = $_[ARG0];
  my $logger = $self->{logger};
  
  my $list    = $_[ARG0]->{list};

  # 记录还有哪些文件没下载完
  my %progress;
  for (@$list) {
    $progress{$_} = 1;
  }
  $self->{progress} = \%progress;

  # 保存list文件
  my $lfile = "$self->{upgrade_home}/$self->{new_version}/list.txt";
  my $lfh   = IO::File->new(">$lfile");
  unless($lfh) {
    $logger->error("can not save $lfile");
    $_[KERNEL]->delay('on_upgrade_check' => $self->{chk_interva});
    return 1;
  }
  
  for (@$list) {
    $_[KERNEL]->yield('on_request_file' => $_ );
  }
  return 1;
}

###########################################
# 请求文件
# req:
#   {
#     version  => 0.4,
#     filename => "libexec/monitor.pl",
#   }
###########################################
sub on_request_file {

  my $self   = $_[OBJECT];
  my $logger = $self->{logger};
  my $args   = $_[ARG0];
  
  my $req =  {
    action   => 'request_file',
    version  => $self->{new_version},
    filename => $_[ARG0],
  };
  $logger->debug("request:\n" . Data::Dump->dump($req));
  $self->{server}->put($req);
  
  return 1;
}

sub on_request_file_res {
  
  my $self   = $_[OBJECT];
  my $logger = $self->{logger};
  my $args   = $_[ARG0];
  
  unless ($args->{status} == 0) {
    $logger->error("request_file failed");
    $_[KERNEL]->yield('on_upgrade_check' => $self->{chk_interval});
    return 1;
  }
  
  # 保存下载文件 
  my $fdir = dirname($args->{filename});
  mkpath("$self->{upgrade_home}/$self->{new_version}/$fdir", { verbose => 0, mode => 0711} );
  mkpath("$self->{app_home}/$fdir", { verbose => 0, mode => 0711} );
  my $fh = IO::File->new("> $self->{upgrade_home}/$self->{new_version}/$args->{filename}");
  unless($fh) {
    $logger->error("can not open $self->{upgrade_home}/$self->{new_version}/$args->{filename}");
    $_[KERNEL]->yield('on_upgrade_check' => $self->{chk_interval});
    return 1;
  }
  unless ( $fh->print($args->{content}) ) {
    $logger->error("save content to $self->{upgrade_home}/$self->{new_version}/$args->{filename} error");
    $_[KERNEL]->yield('on_upgrade_check' => $self->{chk_interval});
    return 1;
  }

  delete $self->{progress}->{$args->{filename}};  
  push @{$self->{download}}, $args->{filename};
  
  # 所有文件都下载成功, 通知server下载完成， 开始部署重启
  unless(%{$self->{progress}}) {
    $self->{server}->put({ action => 'end'});
    $_[KERNEL]->yield('on_restart');
  }
  
  return 1;
}

###########################################
# 重启
###########################################
sub on_restart {
  
  my $self     = $_[OBJECT];
  my $logger   = $self->{logger};
  my $download = delete $self->{download};
  
  # 实施更新部署  
  for (@$download) {
    $logger->info("begin install $_");
    copy("$self->{upgrade_home}/$self->{new_version}/$_", "$self->{app_home}/$_");
  }
  
  # 写入版本号到版本文件
  my $vfh = IO::File->new("> $self->{app_home}/.version");
  unless($vfh) {
    $logger->error("can not open(> $self->{app_home}/.version)" );
    return 1;
  }
  $vfh->print($self->{new_version});
  $vfh->close();

  # 将版本号加入 $upgrade_home/version.txt文件 
  $vfh = IO::File->new(">> $self->{upgrade_home}/version.txt");
  unless($vfh) {
    $logger->error("can not open $self->{upgrade_home}/version.txt");
    return 1;
  }
  $vfh->print($self->{new_version}, "\n");
  $vfh->close();
  
  # 重启系统
  $self->restart();
  return 1;
}

###########################################
# 得到服务器响应 
###########################################
sub on_response {
  my $self   = $_[OBJECT];
  my $logger = $self->{logger};
  
  $logger->debug("response:\n" . Data::Dump->dump($_[ARG0]));

  my $action = $_[ARG0]->{action};
  my $status = $_[ARG0]->{status};
  
  unless ($status == 0 ) {
    $logger->error("on_response got failed response:\n" . Data::Dump->dump($_[ARG0]));
    $_[KERNEL]->yield('on_start');
    return 1;
  }
  
  $_[KERNEL]->yield("on_${action}_res"  => $_[ARG0]);
  
  return 1;
}


###########################################
# 重启系统
###########################################
sub restart {

  my $self = shift;
  my $logger = $self->{logger};

  local $SIG{HUP} = 'IGNORE';

  $logger->warn(">>>>>>>>>>>>>>>Restarting...");

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
