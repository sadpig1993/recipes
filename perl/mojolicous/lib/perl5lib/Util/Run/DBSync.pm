package Util::Run::DBSync;

use strict;
use warnings;

use Util::Run;
use Util::DB;
use Util::DB::Sync;

#########################################################
# Util::Run 工作对象  
#########################################################
# tbl_dbsync_ctl 记录的任务包含以下字段 
#------------------------------------------
#   SRC_NAME  -- 源表名称 
#   dst_name  -- 目标表名称 
#   start     -- YYYYMMDD HH:MM:SS
#   interval  -- 转移片段大小 间隔 
#   filter    -- 同步记录过滤器:  Filter::Module|arg_str
#   src_uts   -- 源表update timestamp 字段名称 
#   cut       -- 日切模块名称  
#   primary   -- 主键列表     : a, b, c
#   updt      -- 更新字段列表 : f1,f2,f3
#########################################################

#########################################################
# logdir
# src_name
#########################################################
sub new {

  my $class     = shift;

  my $logdir    = shift;
  my $src_name  = shift;

  my $self = bless {}, $class;

  # 运行日志 
  my $logger = Util::Log->new( 
   logurl   => "file://$logdir/$src_name.log", 
   loglevel => $run_kernel->logger()->loglevel()
  );
  unless($logger) {
    warn "can not Util::Log->new";
    return undef;
  }

  $self->{logger} =$logger;

  return $self;

}


######################################################
# run的工作对象处理函数  
# args 是一个hash ref
# {
#    sdbc   =>
#    ddbc   =>
#    jrow   =>
#    logdir =>
# }
######################################################
sub run {

  my $self = shift;
  my $args = shift;

  my $logger = $self->{logger};
  my $traced = $args->{logdir} if $logger->loglevel() > $logger->INFO();

  # 转移对象
  my $syncer = Util::DB::Sync->new(
    sdbc   => $args->{sdbc},
    ddbc   => $args->{ddbc},
    jrow   => $args->{jrow},
    traced => $traced,
    log    => $self->{logger},
  );
  unless($syncer) {
    $self->{logger}->error("can not Util::DB::Sync->new");
    exit 0;
  }

  ###############################
  # 转移loop
  ###############################
  $syncer->run();
  $self->{logger}->error("unexpected exception");
  exit 0;
}

#################################
# 提交工作, 
# sdbc    =>
# ddbc    =>
# logdir  =>  
#################################
sub submit_all {

  my $class = shift;
  my $args  = { @_ };

  my $logger = $run_kernel->{logger};

  ###############################
  # 连接源库 
  my $sdb = Util::DB->new(
    db_conf => $args->{sdbc},
    use     => { 'tbl_dbsync_ctl'  => [ 'select_all' ] },
    logger  => $logger,
  );
  unless($sdb) {
    $logger->error("can not create sdbc with " . Data::Dump->dump($args) . "\n");
    exit 0;
  }

  ###############################
  # 读出所有转移记录 
  my $sth = $sdb->execute('tbl_dbsync_ctl', 'select_all') or die "can not execute";
  my @rows;
  while(1) {
    my $row;
    eval { $row = $sth->fetchrow_hashref() };
    if ($@) {
      $logger->error("fetchall_hashref failed:\n", $@);
      exit 0;
    }
    last unless $row; 
    push @rows, $row;
  }
  $sth->finish();
  $sdb->disconnect();

  ###############################
  # 提交子进程模块
  for my $row (@rows) {
    $logger->info("submit jrow[$row->{SRC_NAME}] beg...");
    my $module = {
      code  => __PACKAGE__ . " run|$args->{logdir} $row->{SRC_NAME}",
      para  => {
        sdbc   => $args->{sdbc},
        ddbc   => $args->{ddbc},
        jrow   => $row,
        logdir => $args->{logdir},
      },
      reap  => 1,  # 可回收 
    };
    $logger->debug("begin submit module[$row->{SRC_NAME}]");
    unless($run_kernel->submit("Z" . $row->{SRC_NAME}, $module)) {
      $logger->error("submit $row->{SRC_NAME} error");
      exit 0;
    }
    $logger->info("submit job[$row->{SRC_NAME}] end successfully");
  }

  return 1;
}

#################################
# 提交工作  
# tbl   => tbl_mcht_inf
# cache => 1|0
#################################
sub submit {

  my $class = shift;

  my $args  = { @_ };

  my $logger = $run_kernel->{logger};

  ###############################
  # 连接源库 
  my $sdb = Util::DB->new(
    db_conf => $args->{sdbc},
    use     => { 'tbl_dbsync_ctl'  => [ 'select_all' ] },
    logger  => $logger,
  );
  unless($sdb) {
    $logger->error("can not create sdbc");
     exit 0;
  }

  my $sth = $sdb->execute('tbl_dbsync_ctl', 'select', $args->{tbl}) or die "can not execute";
  my $row = $sth->fetchrow_hashref();
  $sth->finish();
  $sdb->disconnect();
  
  # 提交子进程模块
  my $module = {
    para  => {
      jrow   => $row,
      sdbc   => $args->{sdbc},
      ddbc   => $args->{ddbc},
      cache  => $args->{cache},
    },
    code  => \&{__PACKAGE__ . "::run"},
    reap  => 1,  # 可回收 
  };
  unless($run_kernel->submit("Z" . $row->{SRC_NAME}, $module)) {
    $logger->error("submit $row->{SRC_NAME} error");
    exit 0;
  }

  $logger->info("submit job[$row->{SRC_NAME}] end successfully");
  return 1;

}

1;

