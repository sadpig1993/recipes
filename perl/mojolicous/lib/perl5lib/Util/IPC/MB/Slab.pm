package Util::IPC::MB::Slab;
use strict;
use warnings;
use Carp qw/cluck/;
use Config;
use Util::IPC::SEM;
use Util::IPC::SHM;

use constant {
  SLAB_OFFSET_CNT   => 0,                                           # 多少块 
  SLAB_OFFSET_USED  => $Config{intsize},                            # 使用了多少块  
  SLAB_OFFSET_LAST  => $Config{intsize} * 2,                        # 最后分配的块id 
  SLAB_OFFSET_SIZE  => $Config{intsize} * 3,                        # 每块大小
  SLAB_OFFSET_MAP   => $Config{intsize} * 4,                        # 块使用映射   
};

#############################################################
# slab结构:
# [blkcnt:int] + 
# [used:int] + 
# [last:int] + 
# [blksize:int]
# [mapping:long * blkcnt]
# [blk.0] + [blk.1] + ... + [blk.N]
#############################################################

#############################################################
# args: 
# {
#   blksize  => 8k
#   blkcnt   => 1024
#   mkey     => 88880001
#   skey     => 88880001
# }
#############################################################
sub init {

  my $class = shift;
  my $args  = { @_ };

  my $mng_size  = $Config{intsize} *  4 + $args->{blkcnt} * $Config{longsize};
  my $slab_size = $args->{blksize} * $args->{blkcnt} + $mng_size;

  # 检查  
  unless( $args->{blksize} && $args->{blkcnt} && $args->{mkey} && $args->{skey}) {
    cluck "can not init with:\n" . Data::Dump->dump($args);
    return undef; 
  }

  # 申请共享内存 
  my $shm = Util::IPC::SHM->new($args->{mkey}, $slab_size);
  unless($shm) {
    cluck "can not Util::IPC::SHM->new()";
    return undef;
  }

  # 初始化共享内存
  my $init = "\0" x $slab_size;
  $shm->write(\$init, 0,$slab_size);
  
  # 连接信号灯 
  my $sem = Util::IPC::SEM->init($args->{skey});
  unless($sem) {
    cluck "can not Util::IPC::SEM->new";
    return undef;
  }

  # 对象 
  my $self = bless {
    shm     => $shm,
    sem     => $sem,
    blkcnt  => $args->{blkcnt},
    blksize => $args->{blksize},
  }, $class;

  # 写入管理数据 
  $self->cnt($args->{blkcnt});
  $self->size($args->{blksize});

  $self->{SLAB_OFFSET_DATA} = SLAB_OFFSET_MAP + $Config{longsize} * $args->{blkcnt};

  return $self;

}


#
#  mkey  => $mkey
#  skey  => $skey
#
sub new {

  my $class = shift;
  my $args  = { @_ };

  unless($args->{skey} && $args->{mkey}) {
    cluck "can not new with:\n" . Data::Dump->dump($args);
    return undef;
  }

  # 连接共享内存 
  my $shm = Util::IPC::SHM->attach($args->{mkey});
  unless($shm) {
    cluck "can not Util::IPC::SHM->attach";
    return undef;
  }

  # 连接信号灯  
  my $sem = Util::IPC::SEM->new($args->{skey});
  unless($sem) {
    cluck "can not Util::IPC::SEM->new";
    return undef;
  }

  my $self = bless {
    shm     => $shm,
    sem     => $sem,
  }, $class;
  $self->{blkcnt}  = $self->cnt();
  $self->{blksize} = $self->size();

  $self->{SLAB_OFFSET_DATA} = SLAB_OFFSET_MAP + $Config{longsize} * $self->{blkcnt};

  return $self;
}

##############################################
# 从指定的blk读取数据  
# bid   :  blk_id
# dref  :  data reference
# size  :  data size
##############################################
sub read {

  my $self = shift;
  my ($bid, $dref, $size) = @_;

  unless($self->map($bid)) {
    cluck "bid[$bid] has no valid data";
    return undef;
  }

  ##############################
  # 读数据  
  ##############################
  my $offset = $self->{SLAB_OFFSET_DATA} + $self->{blksize} * $bid;
  unless($self->{shm}->read($dref, $offset, $size)) {
    cluck "can not read bid[$bid]";
    return undef;
  }

  return $self;
}

##############################################
# dref  :  data reference
# size  :  data size
# bid   :
# --------------------------------------------
# 返回值:
#  undef : no block available 
#  0..N  : bid
##############################################
sub write {

  my $self = shift;
  my $dref = shift;
  my $size = shift;
  my $bid  = shift;

  ################################
  # 往空闲块写数据,
  # 失败则释放刚申请的空闲块
  ################################
  my $shm = $self->{shm};
  my $offset = $self->{SLAB_OFFSET_DATA} + $self->{blksize} * $bid;
  unless($self->{shm}->write($dref, $offset, $size)) {
    cluck "shm->wirte failed";
    $self->free($bid);
    return undef;
  }

  return $self;
}

##############################################
# 获取空闲块 
##############################################
sub alloc {

  my $self = shift;
  my $attr = shift;
  my $bid;


  ################################
  # 加锁 
  ################################
  unless($self->{sem}->lock()) {
    cluck "lock error"; 
    return undef;
  }

  ################################
  # 空闲块为0 
  ################################
  if ($self->used() == $self->{blkcnt} ) {
    goto FAIL;
  }

  ################################
  # 从last位置开始查找空闲块
  ################################
  $bid = $self->last();
  my $i;
  for ($i = 0; $i < $self->{blkcnt}; ++$i) {
    last if $self->map($bid) == 0;
    $bid = ($bid+1) % $self->{blkcnt};
  }
  if ($i >= $self->{blkcnt}) {
    goto FAIL;
  }

  ################################
  # 管理操作:
  # used     += 1
  # map[$bid] = time()
  # 必须原子
  ################################
  # 更改map空闲flag为占用  
  unless( $self->map($bid, time() + $attr->{timeout}) ) {
    cluck "can not map($bid,1)";
    goto FAIL;
  }
  # 已分配数增加 
  unless( $self->used(1) ) {
    cluck "can not used(1)";
    $self->map($bid,0);
    goto FAIL;
  }
  # 登记最近分配记录序号 
  unless( $self->last($bid) ) {
    cluck "can not last($bid)";
    goto FAIL;
  }

  ################################
  # 解锁  
  ################################
  unless($self->{sem}->unlock()) {
    cluck "unlock error";
    goto FAIL;
  }

  return $bid;

FAIL:
  unless($self->{sem}->unlock()) {
    cluck "unlock error";
  }

  return undef;
}

##############################################
# 释放数据块  
##############################################
sub free {

  my $self = shift;
  my $bid  = shift;

  ##############################
  # 加锁 
  ##############################
  unless($self->{sem}->lock()) {
    cluck "lock error"; 
    return undef;
  }

  ##############################
  # 管理操作 
  # map[$bid]  = 0
  # used      -= 1
  # 必须原子
  ##############################
  # 释放空间   
  unless( $self->map($bid, 0) ) {
    cluck "map($bid,0) failed";
    goto FAIL;
  }

  # 分配数减1  
  unless( $self->used(-1) ) {
    cluck "used(-1) failed";
    goto FAIL;
  }

  ##############################
  # 解锁 && 返回成功 
  ##############################
  unless($self->{sem}->unlock()) {
    cluck "unlock error"; 
    return undef;
  }
  return $self;

FAIL:
  unless($self->{sem}->unlock()) {
    cluck "unlock error"; 
  }
  return undef;

}

##############################################
# 当前使用的多少块 
# 写入/读取  
##############################################
sub used {

  my $self  = shift;
  my $opcnt = shift;
  my $old;

  $self->{shm}->read(\$old, SLAB_OFFSET_USED, $Config{intsize});
  $old = unpack('i!', $old); 


  # 读操作 
  unless(defined $opcnt) {
    return $old;
  }

  # 写操作 
  my $new = $old + $opcnt;
  $new = pack('i!', $new);
  $self->{shm}->write(\$new, SLAB_OFFSET_USED, $Config{intsize});

  return $self;
}

##############################################
# 指定的data block是否被使用/置其为使用中,空闲中  
# bid   : blk_id
# op    : undef | 0 | 1
##############################################
sub map {
  my $self = shift;
  my $bid  = shift;
  my $op   = shift;
 
  # 写操作  
  if (defined $op) {
    my $map = pack('i!', $op); 
    $self->{shm}->write(\$map, SLAB_OFFSET_MAP + $Config{intsize} * $bid, $Config{intsize});
    return $self;
  }

  # 读操作 
  my $map;
  $self->{shm}->read(\$map, SLAB_OFFSET_MAP + $Config{intsize} * $bid, $Config{intsize});
  return unpack('i!', $map);
}

##############################################
# op: 
#   undef => 读操作 
#   0,1,2 => 写操作 
##############################################
sub last {

  my $self = shift;
  my $op   = shift;
 
  # 写操作  
  if (defined $op) {
    my $last = pack('i!', $op);
    $self->{shm}->write(\$last, SLAB_OFFSET_LAST, $Config{intsize});
    return $self; 
  }

  # 读操作
  my $last;
  $self->{shm}->read(\$last, SLAB_OFFSET_LAST, $Config{intsize});
  return unpack('i!', $last);

}

#
# 读取或写入cnt
#
sub cnt {

  my $self = shift;
  my $op   = shift;
 
  # 写操作  
  if (defined $op) {
    my $cnt = pack('i!', $op);
    $self->{shm}->write(\$cnt, SLAB_OFFSET_CNT, $Config{intsize});
    return $self; 
  }

  # 读操作
  my $cnt;
  $self->{shm}->read(\$cnt, SLAB_OFFSET_CNT, $Config{intsize});
  return unpack('i!', $cnt);

}

#
# 读取或写入blksize
#
sub size {

  my $self = shift;
  my $op   = shift;
 
  # 写操作  
  if (defined $op) {
    my $size = pack('i!', $op);
    $self->{shm}->write(\$size, SLAB_OFFSET_SIZE, $Config{intsize});
    return $self; 
  }

  # 读操作
  my $size;
  $self->{shm}->read(\$size, SLAB_OFFSET_SIZE, $Config{intsize});
  return unpack('i!', $size);

}

#
# 垃圾块回收 
#
sub gc {

  my $self = shift;

  my $now = time;
  my $map;
  my $op = 0;
  my $cnt = 0;

  $self->{sem}->lock();

  $self->{shm}->read(\$map, SLAB_OFFSET_MAP, $Config{longsize} * $self->{blkcnt});

  my @map = unpack("l$self->{blkcnt}", $map);
  for (my $i = 0; $i < $self->{blkcnt}; ++$i) {
    next unless $map[$i];

    # 回收  
    if ( $map[$i] < $now) {
      $map[$i] = 0;
      $op--;
      $cnt++;
    }
  }
  $map = pack("l$self->{blkcnt}", @map);
  $self->{shm}->write(\$map, SLAB_OFFSET_MAP, $Config{longsize} * $self->{blkcnt} );
  $self->used($op);

  $self->{sem}->unlock();

  return $cnt;
  
}


1;

