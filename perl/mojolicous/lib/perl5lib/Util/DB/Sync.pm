package Util::DB::Sync;

use strict;
use warnings;

use POSIX qw/mktime/;
use Data::Dump;
use Time::HiRes qw/gettimeofday sleep tv_interval/;
use Util::DB::Timestamp qw/
ts_interval 
ts_add
ts_sub
ts_lt ts_ge
ts_gt ts_le
ts_ne ts_eq
/;

########################################
#  jrow   =>  tbl_dbsync_ctl's row
#  sdbc   =>  $sdb
#  ddbc   =>  $ddb
#  log    =>  $log
#  traced =>  '/trace/directory'
########################################
sub new {

  my $class = shift;
  my $self  = bless {}, $class;

  my $args        = { @_ };
  $self->{log}    = delete $args->{log};

  my $jrow        = delete $args->{jrow};
  my $sdbc        = delete $args->{sdbc};  # sdbc can be either of db_conf file or db object
  my $ddbc        = delete $args->{ddbc};
  my $traced      = delete $args->{traced};

  my $traceurl;
  unless( ref $sdbc ) {  
    ###############################
    # 连接源库 
    $traceurl = undef;
    $traceurl = "file://$traced/$jrow->{SRC_NAME}.dbtrace" if $traced;
    my $sdb = Util::DB->new(
      db_conf  => $sdbc,
      except   => { 
                    'tbl_dbsync_ctl'  => [ 'select_all' ],
                  },
      traceurl => $traceurl,
    );
    unless($sdb) {
      $self->{log}->error("can not create sdbc");
      exit 0;
    }
    $self->{log}->debug( "sdb created");
    $self->{sdb} = $sdb;
  } else {
    $self->{sdb} = $sdbc;
  }

  unless( ref $ddbc ) {
    ###############################
    # 连接目的库 
    $traceurl = undef;
    $traceurl = "file://$traced/$jrow->{DST_NAME}.dbtrace" if $traced;
    my $ddb = Util::DB->new(
      db_conf   => $ddbc,
      traceurl  => $traceurl,
    );
    unless($ddb) {
      $self->{log}->error("can not create ddbc");
      exit 0;
    }
    $self->{log}->debug( "ddb created");
    $self->{ddb} = $ddb;
  } else {
    $self->{ddb} = $ddbc;
  }

  $self->{job}->{gap} = $jrow->{GAP};

  ###############################
  # 加载日切模块 + 对象 
  if ( $jrow->{CUT}) {
    unless( $self->load_batcut($jrow->{CUT}) ) {
      $self->{log}->error("load batcut module end failed");
      return undef;
    }
  }

  ###############################
  # 进一步初始话 
  unless($self->_init($jrow)) {
    $self->{log}->error("can not _init");
    return undef;
  }

  $self->{log}->debug("sdb obj info:\n" .  Data::Dump->dump($self->{sdb}));
  $self->{log}->debug("ddb obj info:\n" .  Data::Dump->dump($self->{ddb}));

  return $self;

}

########################################
# job:  tbl_dbsync_ctl's row
# bc :  日切模块  
########################################
sub _init {

  my $self  = shift;
  my $jrow  = shift;

  my $sdb  = $self->{sdb};
  my $ddb  = $self->{ddb};
  my $log  = $self->{log};

  my $src_uts = delete $jrow->{SRC_UTS};

  $self->{job}->{beg} = $jrow->{BEGIN};
  my @primary = map { uc $_ } split ',', $jrow->{PRIMARY};  # 主键列表   

  my @updt_list;
  if ( $jrow->{UPDT_LIST}) {
    @updt_list = map { lc $_ } split ',', $jrow->{UPDAT_LIST};
  }

  $log->debug("begin load sdb and ddb config...");
  ###################
  # 此转移任务和日切相关  
  ###################
  if ( $self->{job}->{bc} ) {

    my $bci = $self->{job}->{bc}->load($sdb);
    unless($bci) {
      $log->error("can not get batcut info");
      return undef;
    }
    
    # 源库增加配置  
    my $bef_tbl = $bci->{'BEF_TABLE'};
    my $cur_tbl = $bci->{'CUR_TABLE'};
    unless ($sdb->add_config_sql(
      $cur_tbl => { select   => "select * from $cur_tbl where $src_uts >= ? and $src_uts < ?"},
      $bef_tbl => { select   => "select * from $bef_tbl where $src_uts >= ? and $src_uts < ?"}
    )) {
      $log->error("add_config_sql error:", $sdb->sqlcode);
      return undef;
    }
    $log->debug("sdb config[$cur_tbl => select ] added");
    $log->debug("sdb config[$bef_tbl => select ] added");

    # 目标库增加配置  
    unless($self->add_dbconfig_dst(\@updt_list, \@primary, undef, $bci)) {
      $log->error("add_dbconfig_dst error");
      return undef;
    }

    # job初始化完成, 日切相关， src dst需根据bc来确定 
    $self->{job}->{src} = $jrow->{SRC_NAME},
    $self->{job}->{int} = $jrow->{INTERVAL},
  } 
  ###################
  # 此转移任务和日切无关 
  ###################
  else {

    my $src = $jrow->{SRC_NAME};
    my $dst = $jrow->{DST_NAME};

    # 源库增加配置  
    unless ($sdb->add_config_sql(
      $src => { select => "select * from $src where $src_uts >= ? and $src_uts < ?" },
    )) {
      $log->error("add_config_sql error");
      return undef;
    }
    $log->debug("sdb config[$src => select] added");

    # 目标库增加配置  
    unless($self->add_dbconfig_dst(\@updt_list, \@primary, $dst, undef)) {
      $log->error("add_dbconfig_dst error");
      return undef;
    }

    # job初始化完成  
    $self->{job}->{src} = $jrow->{SRC_NAME},
    $self->{job}->{dst} = $jrow->{DST_NAME},
    $self->{job}->{int} = $jrow->{INTERVAL},
  }

  $log->debug("begin load filter...");
  ###################
  # 加载过滤器 
  ###################
  if ($jrow->{FILTER}) {

    my $fcb = $self->load_filter($jrow->{FILTER});
    unless($fcb) {
      $log->error("load_filter error");
      return undef;
    }
    $self->{job}->{fcb}  = $fcb;
    $log->debug("filter object loaded");
  }

  $self->{log}->info("Job information:\n", Data::Dump->dump($self->{job}));

  return $self;
}

#####################################
# 主调用入口 
#####################################
sub run {
  my $self = shift;
  my $job = $self->{job};

  if ($job->{bc}) {
    $self->{log}->debug("datecut-related data sync");
    return $self->run_bc();
  } else {
    $self->{log}->debug("datecut-less data sync");
    return $self->run_normal();
  }
}

#####################################
# 日切相关转移调用入口 
#####################################
sub run_bc {

  my $self = shift;
  my $sdb  = $self->{sdb};
  my $ddb  = $self->{ddb};
  my $job  = $self->{job};
  my $log  = $self->{log};

  my $delta_warn  = 2 < $job->{gap} / 2 ? 2 : $job->{gap}/2;

  # loop
  while(1) {
    RESTART:
    my $t_beg = [ gettimeofday ];

    #-----------------------------------------
    my $now   = $self->get_sdb_ts();
    my $delta = ts_interval($job->{beg}, $now);
    my $end;
    my $bci;

    my $cnt;
    my $cnt_all = 0;

    #######################################
    #  calculate the sync range
    #######################################
    if ( $delta <= $job->{gap} ) {
      if ($delta < $delta_warn) {   # delta over the warning timepoint
        $job->{beg} = ts_sub($job->{beg}, [ $delta * 2, 0]); 
      }
      sleep($job->{int} + $job->{gap} - $delta);
    }
    $end = ts_sub($now, [ $job->{gap}, 0 ]);

    $bci = $job->{bc}->load();
    unless($bci) {
      $log->error( "can not load bc info" );
      return undef;
    }
    $self->{bci} = $bci;
    my $cut_end = ts_add( $bci->{CUT_BEG}, [ $bci->{CUT_TIME}, 0]);

    $log->debug("slice information:\n" .
                "[\n".
                "  now   : $now\n" .
                "  beg   : $job->{beg}\n" .
                "  end   : $end\n" .
                "  delta : $delta\n" .
                "  range : " . ts_interval($job->{beg}, $end) . "\n" .
                "  --------------------\n" .
                "  BEF_DATE  => $bci->{BEF_DATE}\n" . 
                "  CUR_DATE  => $bci->{CUR_DATE}\n" .
                "  BEF_TABLE => $bci->{BEF_TABLE}\n" .
                "  CUR_TABLE => $bci->{CUR_TABLE}\n" .
                "  CUT_TIME  => $bci->{CUT_TIME}\n" .
                "  CUT_BEG   => $bci->{CUT_BEG}\n" .
                "  CUT_END   => $cut_end\n" . 
                "]");


    #--------------------------------------
    # 片段开始时间在日切窗口前 
    #--------------------------------------
    # if($job->{beg} <  $bci->{CUT_BEG}) {
    if( ts_lt($job->{beg}, $bci->{CUT_BEG}) ) {
      
      ################################
      # [ beg, end < CUT_BEG) 
      ################################
      if ( ts_le($end, $bci->{CUT_BEG}) ) {
        $self->{job}->{end} = $end;
        $log->debug("beg sync_bc_bef...");
        $cnt_all = $self->sync_bc_bef();
        unless(defined $cnt_all ) {
          $log->error("end sync_bc_bef error");
          return undef;
        }
        goto SUCCESS;
      }


      ######################
      #[ beg, cut_beg )
      $job->{end} = $bci->{CUT_BEG};
      $log->debug("beg sync_bc_bef...");
      $cnt = $self->sync_bc_bef();
      unless(defined $cnt) {
        $log->error("end sync_bc_bef error");
        return undef;
      }
      $cnt_all += $cnt;

      ################################
      #[ beg, cut_beg) + [ cut_beg, end) < cut_end
      ################################
      if ( ts_le($end, $cut_end) ) {
        ######################
        #[ cut_beg, end )
        $job->{end} = $end;
        $log->debug("beg sync_bc_range...");
        $cnt = $self->sync_bc_range();
        unless(defined $cnt ) {
          $log->error("end sync_bc_range error");
          return undef;
        }
        $cnt_all += $cnt;
        goto SUCCESS;
      } 

      ################################
      #[ beg, cut_beg) + [ cut_beg, cut_end) + [cut_end, end)
      ################################

      ######################
      # [ cut_beg, cut_end )
      $job->{end} = $cut_end;
      $log->debug("beg sync_bc_range...");
      $cnt = $self->sync_bc_range();
      unless( defined $cnt ) {
        $log->error("end sync_bc_range error");
        return undef;
      }
      $cnt_all += $cnt;

      ######################
      # [cut_end, end)
      $job->{end} = $end;
      $log->debug("beg sync_bc_aft...");
      $cnt = $self->sync_bc_aft();
      unless( defined $cnt ) {
        $log->error("end sync_bc_aft error");
        return undef;
      }
      $cnt_all += $cnt;

      goto SUCCESS;
    }

    #--------------------------------------
    # 片段开始时间在日切窗口中 
    #--------------------------------------
    # if ( $job->{beg} >= $bci->{CUT_BEG}  && $job->{beg} < $cut_end) {
    if ( ts_ge($job->{beg}, $bci->{CUT_BEG})  && 
         ts_lt($job->{beg}, $cut_end) ) {

      ####################################
      #  cut_beg < [beg, end) < cut_end
      ####################################
      # if ( $end <= $cut_end ) {
      if ( ts_le($end, $cut_end) ) {
        $job->{end} = $end;
        $log->debug("beg sync_bc_range...");
        $cnt = $self->sync_bc_range();
        unless(defined $cnt ) {
          $log->error("end sync_bc_range error");
          return undef;
        }
        $cnt_all += $cnt;
        goto SUCCESS;

      }

      ####################################
      #  [beg, cut_end) + [cut_end, end)
      ####################################
      $job->{end} = $cut_end;
      $log->debug("beg sync_bc_range...");
      $cnt = $self->sync_bc_range(); 
      unless(defined $cnt ) {
        $log->error("end sync_bc_range error");
        return undef;
      }
      $cnt_all += $cnt;

      $job->{end} = $end;
      $log->debug("beg sync_bc_aft...");
      $cnt = $self->sync_bc_aft();
      unless(defined $cnt ) {
        $log->error("end sync_bc_aft error");
        return undef;
      }
      $cnt_all += $cnt;
      goto SUCCESS;
    }

    #--------------------------------------
    # 片段开始时间在日切窗口后  
    #--------------------------------------
    $job->{end} = $end;
    $log->debug("beg sync_bc_aft...");
    $cnt = $self->sync_bc_aft();
    unless(defined $cnt ) {
      $log->error("end sync_bc_aft error");
      return undef;
    }
    $cnt_all += $cnt;

    SUCCESS:
    #-----------------------------------------
    ###############################
    # 目的数据库commit
    ###############################
    if( $cnt_all > 0 ) {
      unless($ddb->commit()) {
        $log->error("can not commit");
        return undef;
      }
    }

    ###############################
    # 更新控制信息 DB tbl_dbsync_ctl
    ###############################
    unless($sdb->execute('tbl_dbsync_ctl', 'update', $end, $job->{src})){
      $log->error("can not execute");
      return undef;
    }
    unless($sdb->commit()) {
      $log->error("can not commit");
      return undef;
    }
  
    ###############################
    # 等待下一次转移 
    ###############################
    my $elapse_all = tv_interval($t_beg, [ gettimeofday ]);
    my $delay =  $job->{int} - $elapse_all;
    $log->debug("elapse_all[$elapse_all] cnt_all[$cnt_all]");
    $log->debug("$job->{int} - $elapse_all = $delay seconds' later, sync restart\n\n\n");
    if ( $delay >= 0 ) {
      sleep($delay);
    }
    goto RESTART;
  }

}

######################################
# 转移区间落在日切中 
######################################
sub sync_bc_range {

  my $self = shift;


  my $bci  = $self->{bci};
  my $job  = $self->{job};
  my $bc   = $job->{bc};
  my $elapse = 0;
  my $cnt1;
  my $cnt2;
  my $e;


  my $beg = $job->{beg};
  $job->{src} = $bci->{BEF_TABLE};
  $job->{dst} = $bc->destination($bci->{BEF_TABLE});

  $cnt1 = $self->sync_table();
  unless (defined $cnt1) {
    $self->{log}->error("sync_table error");
    return undef;
  }

  $job->{beg} = $beg;
  $job->{src} = $bci->{CUR_TABLE};
  $job->{dst} = $bc->destination($bci->{CUR_TABLE});

  $self->{ddb}->do("create alias tbl_txn_log_pre for $job->{dst}");   # 切换tbl_txn_log_pre

  $cnt2 = $self->sync_table();
  unless(defined $cnt2) {
    $self->{log}->error("sync_table error");
    return undef;
  }

  $self->{flag} = 1;

  return $cnt1 + $cnt2;
}

######################################
# 转移区间落在日切前 
######################################
sub sync_bc_bef {

  my $self = shift;

  my $bci  = $self->{bci};
  my $job  = $self->{job};
  my $bc   = $job->{bc};
  my $elapse = 0;
  my $cnt;

  $job->{src} = $bci->{BEF_TABLE};
  $job->{dst} = $bc->destination($bci->{BEF_TABLE});
  $cnt = $self->sync_table();
  unless(defined $cnt) {
    $self->{log}->error("sync_table error");
    return undef;
  }

  return $cnt;
}

######################################
# 转移区间落在日切后  
######################################
sub sync_bc_aft {

  my $self = shift;

  my $bci  = $self->{bci};
  my $job  = $self->{job};
  my $bc   = $job->{bc};
  my $elapse = 0;
  my $cnt;

  $job->{src} = $bci->{CUR_TABLE};
  $job->{dst} = $bc->destination($bci->{CUR_TABLE});
  $cnt = $self->sync_table();
  unless( defined $cnt) {
    $self->{log}->error("sync_table error");
    return undef;
  }

  ###########################################
  if ($self->{flag}) {

     # 清空昨日表 
     my $y_tbl = $bc->destination($bci->{BEF_TABLE});
     system("db2 -tvf /data1/hary/dev/project/dbsync/sql/$y_tbl.sql");
     
     $self->{flag} = undef;
  }

  return $cnt;
}

sub reset_beg {

  my $self   = shift;
  my $elapse = shift;

  my @tv; 
  $elapse *= 1000000;
  if ($elapse >= 1000000) {
    use integer;
    push @tv, $elapse / 1000000, $elapse % 1000000;
  } 
  else {
    push @tv, 0, $elapse;
  }
  return ts_sub($self->{job}->{beg}, \@tv);
}

######################################
# 不涉及日切的数据转移 
######################################
sub run_normal {

  my $self = shift;
  my $sdb  = $self->{sdb};
  my $ddb  = $self->{ddb};
  my $job  = $self->{job};
  my $log  = $self->{log};


  my $elapse = 0;

  while(1) {

    my $t_beg = [ gettimeofday ];

    my $now   = $self->get_sdb_ts();             # 获取源数据库当前时间戳    
    my $slice = ts_interval($job->{beg}, $now);  # $job->{beg}是本次开始点，他应该总是小于$now
    my $end;
    my $cnt;

    ###############################
    # calculate the slice
    # 始终要保持要转移的片段距离现在时间 > gap
    ###############################
    if ( $slice <= $job->{gap} ) {   
      $elapse = tv_interval($t_beg);
      sleep($job->{int} + $job->{gap} - $slice);
      next;
    }

    $job->{beg} = $self->reset_beg($elapse);      # 设置重叠区域  
    $end = ts_sub($now, [$job->{gap}, 0]);
    $log->debug("slice information:\n"         .
                "[\n"                          .
                "  now   : $now\n"             . 
                "  beg   : $job->{beg}\n"      .
                "  end   : $end\n"             .
                "  elapse: $elapse\n"          . 
                "  slice : $slice\n"           .
                "  range : "                   . 
                ts_interval($job->{beg}, $end) . 
                "\n"                           .
                "]");


    ###############################
    # sync with range: [beg, $end)
    ###############################
    $job->{end} = $end;
    $cnt = $self->sync_table();
    unless( defined $cnt ) {
      $log->error("sync_table error");
      return undef;
    }
    if( $cnt > 0 ) {
      unless($ddb->commit()) {
        $log->error("con not commit");
        return undef;
      }
    }

    ###############################
    # update tbl_dbsync_ctl
    ###############################
    unless($self->{sdb}->execute('tbl_dbsync_ctl', 'update', $end, $job->{src})) {
      $log->error("can not execute");
      return undef;
    }
    unless($sdb->commit()) {
      $log->error("can not commit");
      return undef;
    }
    
    ###############################
    # delay util next sync time
    ###############################
    $elapse = tv_interval( $t_beg, [gettimeofday]);
    my $delay =  $job->{int} - $elapse;  # floating number
    $log->debug("$job->{int} - $elapse = $delay seconds later restart\n\n\n");
    if ( $delay > 0 ) {
      sleep($delay);
    }
  }
}

######################################
# $job:
#------------------------------------
# beg:
# end:
# src:
# dst:
######################################
sub sync_table {

  my $self = shift;
  my $job  = $self->{job};
  my $select;
 
  $self->{log}->debug( 
    "sync_table with \n" .
    "[\n" .
    "  src   : $job->{src}\n" .
    "  dst   : $job->{dst}\n" .
    "  beg   : $job->{beg}\n" .
    "  end   : $job->{end}\n" .
    "]");

  # 开始时间  (统计)
  my $t_beg = [ gettimeofday ];

  # execute...
  $select = $self->{sdb}->execute($job->{src}, 'select', $job->{beg}, $job->{end});
  unless($select) {
    $self->{log}->error( "can not execute"); 
    return undef;
  }

  my $update_cnt = 0; 
  my $insert_cnt = 0; 

  # fetch...
  while( 1 ) {
   
    my $row;
    my $sth;
    eval { $row = $select->fetchrow_arrayref() };   # attention  arrayref
    if ($@) {
      $self->{log}->error("fetchrow_hashref failed:\n", $@);
      return undef;
    }
    last unless $row;

    # 过滤器
    if ($job->{fcb}) {
      $row = $job->{fcb}->handle($row);
      unless($row) { 
        $self->{log}->error("can not filter the row");
        return undef;
      }
    }

    # 插入目的数据库
    $sth = $self->{ddb}->execute($job->{dst}, 'insert', @$row);
    unless($sth) { 
      $self->{log}->error("can not execute");
      return undef;
    }


    ##########################################
    ##########################################
    my $sqlcode = $self->{ddb}->sqlcode();
    if( $sqlcode ) {

      # 目的数据库主键重复, update....  
      if ( $sqlcode =~ /^-803$/ ) {
        $sth = $self->{ddb}->execute($job->{dst}, 'update', 
                                   @{$row}[@{$job->{updt}}], 
                                   @{$row}[@{$job->{primary}}]);
        unless($sth) { 
          $self->{log}->error("can not execute");
          return undef;
        
        }
        $update_cnt++;
      }
      # 不是主键重复错误  
      else {
        $self->{log}->error("sync_table failed, sqlcode[$sqlcode]");
        return undef;
      }
    } else {
      $insert_cnt++;
    }
  }
 
  # 转移记录条数, 消耗时间 (统计)
  my $elapse = ts_interval($t_beg, [gettimeofday]);  # floatting
  $self->{log}->trace("[$job->{beg} $job->{end}) (insert:$insert_cnt, update:$update_cnt, elapse:$elapse)");
  
  # 将下次开始时间设置为本次结束时间 
  $job->{beg} = $job->{end};

  # 返回本次
  return $update_cnt + $insert_cnt;
}

###############################
#  加载同步过滤器 
# name=FilterSocket&argstr=args
###############################
sub load_filter {

  my $self   = shift;
  my $filter = shift;

  my ($pkg, $argstr);
  for (split '&', $filter) {
    $pkg    = $1 if /module=(.*)/;
    $argstr = $1 if /argstr=(.*)/;
  }

  unless($pkg) {
    $self->{log}->error("invalid filter string[$filter]");
    return undef;
  }

  $self->{log}->debug("beg load module $pkg...");
  eval "use $pkg;";
  if($@) {
    $self->{log}->error( "end load module $pkg failed:\n", $@);  #lambda 
    return undef;
  }
  $self->{log}->debug("beg load module $pkg success");

  my $fcb = $pkg->new(sync => $self, argstr => $argstr);
  unless($fcb) {
    $self->{log}->error("can not $pkg->new");
    return undef;
  }

  return $fcb;
}

################################################
# 获取源数据库当前时间戳
################################################
sub get_sdb_ts {

  my $self = shift;
  my $sdb  = $self->{sdb};

  my $time_sth;
  unless($time_sth = $sdb->execute('tbl_dbsync_ctl', 'current_ts')) {
    $self->{log}->error("can not execute('tbl_dbsync_ctl', 'current_ts')");
    return undef;
  }
  my $src_ts;
  eval  { $src_ts = $time_sth->fetchrow_arrayref(); };
  if ($@) {
    $self->{log}->error("fetchrow_arrayref failed:\n",  $@);
    return undef;
  }
  unless($src_ts) {
    $self->{log}->error("can not fetchrow_arrayref('tbl_dbsync_ctl', 'current_ts')");
    return undef;
  }

  return $src_ts->[0];
}

################################################
#  primary : 主键列表 
#  dst_tbl : 目的表名称 
#  bci     : 日切信息  
################################################
sub add_dbconfig_dst {

  my $self      = shift;
  my $updt_list = shift;
  my $primary   = shift;
  my $dst_tbl   = shift;
  my $bci       = shift;

  my $ddb = $self->{ddb};
  my $log = $self->{log};

  my $cur_dst;
  my $bef_dst;

  my $insert_bstr;  # insert bind str: "?,?,?"
  my $update_bstr;  # update bind str: "xxx = ? , xxx = > ?" : 目前是除primary全部更新  
  my @updt_idx;     # (5 3 2 7)
  my @prim_idx;  #
  my $prim_con = join ' and ',  map { my $prim = lc $_;  "$prim = ?"; } @{$primary};  # primary conditoin

  ###################################
  # 日切相关, 从日切模块得到目的数据库表名  
  #
  if ($bci) {
    my $bc = $self->{job}->{bc};
    $bef_dst = $bc->destination($bci->{'BEF_TABLE'});
    $cur_dst = $bc->destination($bci->{'CUR_TABLE'});
    $dst_tbl = $bef_dst;
  }

  ###################################
  # prepare 获取statement handle 
  # 
  my $sth;
  eval { $sth = $self->{ddb}->{dbh}->prepare(qq/select * from $dst_tbl/); };
  if ($@) {
    $log->error("can not prepare:\n", $@);
    return undef;
  }
  my $nhash = $sth->{NAME_hash};

  ###################################
  # 获取 insert bind str
  #
  my $fcnt = keys %{$nhash};
  my @mark;
  push @mark, '?',  for 1..$fcnt;
  $insert_bstr = join ',', @mark;

  $log->debug("nhash   information:\n", Data::Dump->dump($nhash));
  $log->debug("primary information:\n", Data::Dump->dump($primary));

  ####################################
  # 获取updt_str
  # 获取updt_idx list
  # 获取prim_idx list
  #
  my @updt_name;    # update字段列表名称  
  if (@$updt_list) {
    $update_bstr = join ', ' ,  map { "$_ = ?" } @$updt_list;
    for my $updt_fld ( map { uc $_ } @$updt_list ) {
      push @updt_idx,  $nhash->{$updt_fld};
    }

    for my $prim_fld ( @$primary ) {
      push @prim_idx,  $nhash->{$prim_fld};
    }
  } 
  else {
    for my $fname ( keys %$nhash ) {
      unless ( $self->belong_primary($primary, $fname)) {
        push @updt_idx,  $nhash->{$fname};
        push @updt_name, lc $fname;
      }
    }
    for (@$primary) {
      push @prim_idx, $nhash->{$_};
    }
    $update_bstr = join ', ' ,  map { "$_ = ?" } @updt_name;
  }
  $self->{job}->{updt}    = \@updt_idx;
  $self->{job}->{primary} = \@prim_idx;

  #
  # debug
  # 
  $log->debug("update_bstr : $update_bstr");
  $log->debug("insert_bstr : $insert_bstr");
  $log->debug("updt_idx    : @updt_idx");
  $log->debug("primary_idx : @prim_idx");

  $sth->finish();

  ################################
  # 日切相关 
  #
  if( $bci) {
    unless ($ddb->add_config_sql(
      $bef_dst => { insert => "insert into $bef_dst values($insert_bstr)" ,
                    update => "update $bef_dst set $update_bstr where $prim_con"},

      $cur_dst => { insert => "insert into $cur_dst values($insert_bstr)",
                    update => "update $bef_dst set $update_bstr where $prim_con" })
    ) {
      return undef;
    }
  } 

  ################################
  # 日切无关 
  #
  else {

    unless ($ddb->add_config_sql(
      $dst_tbl => { insert => "insert into $dst_tbl values($insert_bstr)" ,
                    update => "update $dst_tbl set $update_bstr where $prim_con"} )
    ) {
      return undef;
    }
  }

  return $self;
}

####################################
# prim:  primary list
# fld:   fld name
####################################
sub belong_primary {
  
  my $self = shift;
  my $prim = shift;
  my $fld  = shift;
  
  for (@$prim) {
    if ($fld eq uc $_) {
      return 1;
    }
  }
  
  return 0;
}

###############################################
# 加载日切模块， 生成日切对象 
###############################################
sub load_batcut {

  my $self = shift; 
  my $bcm  = shift;
  my $log  = $self->{log};

  eval "use $bcm;";
  $log->debug("beg load module $bcm...");
  if($@) {
    $log->error("end load module $bcm error[$@]");
    return undef;
  }
  $log->debug("end load module $bcm success");

  ###############################################
  # $bc->load() return:
  #----------------------------
  # {
  #   bef_table => 'tbl_txn_log_a', 
  #   cur_table => 'tbl_txn_log_b',
  #   bef_date  => 20111212,      
  #   cur_date  => 20111211,     
  #   cut_time  => time_t,      
  #   cut_win   => 60          
  # }
  # $bc->destination($src_tbl) return:
  #----------------------------
  # tbl_destination_name
  ###############################################
  my $bc = $bcm->new($self->{sdb});
  unless($bc) {
    $log->error("can not $bcm->new");
    return undef;
  }

  $self->{job}->{bc} = $bc;
  return $self;

}


1;

__END__


=head1 NAME
  
  Util::DB::Sync - database sync in the application level


=head1 SYNOPSIS

  ------------------------------
  ------------------------------
  use Util::DB::Sync;
  my $sync = Util::DB::Sync->new (
    sdbc   => "$DBSYNC_HOME/conf/sdbc.conf",
    ddbc   => "$DBSYNC_HOME/conf/ddbc.conf"
    jrow   => $href,
    log    => $log,  
    traced => "$DBSYNC_HOME/log",
  );

  $sync->run();


=head1 Author & Copyright

  zcman2005@gmail.com

=cut

