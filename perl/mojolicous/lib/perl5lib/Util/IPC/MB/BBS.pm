package Util::IPC::MB::BBS;
use strict;
use warnings;
use Carp qw/cluck/;
use Config;
use Util::IPC::SHM;
use Util::IPC::SEM;
use Util::IPC::MsgQ;
use File::Path qw/mkpath/;
use IO::File;
use POSIX qw/mkfifo/;

use constant {
  BBS_OFFSET_SKEY   => 0,
  BBS_OFFSET_QKEY   => $Config{longsize},
  BBS_OFFSET_MBMAX  => $Config{longsize} * 2,
  BBS_OFFSET_SLAB   => $Config{longsize} * 2 + $Config{intsize},
  BBS_OFFSET_BSIZE  => $Config{longsize} * 2 + $Config{intsize} * 2,
  BBS_OFFSET_EXPIRE => $Config{longsize} * 2 + $Config{intsize} * 3,
  BBS_OFFSET_USED   => $Config{longsize} * 2 + $Config{intsize} * 4,
  BBS_OFFSET_LAST   => $Config{longsize} * 2 + $Config{intsize} * 5,
  BBS_OFFSET_ENTRY  => $Config{longsize} * 2 + $Config{intsize} * 6,
  MBOX_NAME_MAX     => 8,
};

#################################################################
# bss结构:
# 1> 头部区  
# {
#   skey  : long => semaphore key      readonly
#   qkey  : long => queue key          readonly
#   mbmax : int  => mbox max cnt       readonly
#   slab  : int  => slab count         readonly
#   bsize : int  => blk count per slab readonly
#   expire: int  => expiration time    readonly 
#   used  : int  => used mbox entry  r/w
#   last  : int  => last entry       r/w
# }
# 2> 邮箱登记区
# [使用标志] + [队列id ] + [邮箱超时属性] + [ 邮箱名称 ]
# [flag:int] + [qid:int] + [timeout:int ] + [ mb3:8Byte]
# [flag:int] + [qid:int] + [timeout:int ] + [ mb3:8Byte]
# [flag:int] + [qid:int] + [timeout:int ] + [ mb3:8Byte]
#################################################################

#################################################################
# args:
# {
#   mkey  => $mkey,
#   skey  => $skey,
#   qkey  => $qkey,
#   slab  => $slab,
#   bsize => $bsize
#   mbmax => $mbmax,
# }
#################################################################
sub init {
  my $class = shift;
  my $args  = { @_ };

  unless($args->{skey}  &&
         $args->{mkey}  &&
         $args->{qkey}  &&
         $args->{mbmax} &&
         $args->{slab}  &&
         $args->{bsize} &&
         $args->{expire}) {
    cluck "can not init with:\n" . Data::Dump->dump($args);
    return undef;
  }

  # 计算bbs大小  
  my $size = $Config{longsize} * 3 + $Config{intsize} * 3 +  (16+$Config{intsize}*2) * $args->{mbmax};

  # 申请共享内存 
  my $shm  = Util::IPC::SHM->new($args->{mkey}, $size);
  unless($shm) {
    cluck "can not Util::IPC::SHM->new";
    return undef;
  }

  # 初始化共享内存
  $shm->write(\("\0" x $size), 0, $size);
  $shm->write(\(pack('l', $args->{skey})),   BBS_OFFSET_SKEY,  $Config{longsize});  # skey
  $shm->write(\(pack('l', $args->{qkey})),   BBS_OFFSET_QKEY,  $Config{longsize});  # qkey
  $shm->write(\(pack('i', $args->{mbmax})),  BBS_OFFSET_MBMAX, $Config{intsize});   # mbmax
  $shm->write(\(pack('i', $args->{slab})),   BBS_OFFSET_SLAB,  $Config{intsize});   # slab
  $shm->write(\(pack('i', $args->{bsize})),  BBS_OFFSET_BSIZE, $Config{intsize});   # bsize
  $shm->write(\(pack('i', $args->{expire})), BBS_OFFSET_EXPIRE,$Config{intsize});   # expire

  # 初始化信号灯  
  my $sem = Util::IPC::SEM->init($args->{skey});
  unless($sem) {
    cluck "can not Util::IPC::SEM->new($args->{skey})";
    return undef;
  }

  # 返回对象 
  bless {
    shm     => $shm,
    sem     => $sem,
    mkey    => $args->{mkey},
    skey    => $args->{skey},
    qkey    => $args->{qkey},
    mbmax   => $args->{mbmax},
    slab    => $args->{slab},
    bsize   => $args->{bsize},
    expire  => $args->{expire},
    esize   => $Config{intsize} * 3 + MBOX_NAME_MAX,
  }, $class;
}

#################################################################
# 新建bbs对象  
# $class->new() 
#################################################################
sub new {

  my $class = shift;

  # 获取mb_key
  eval 'use Env qw/$MB_KEY/;';
  if ($@) {
    cluck "env \$mb_key is not set";
    return undef;
  }
  my $mkey = eval '$MB_KEY';
  unless(defined $mkey) {
    cluck "env \$mb_key is not set";
    return undef;
  }

  # 连接bbs共享内存
  my $shm = Util::IPC::SHM->attach($mkey);
  unless($shm) {
    cluck "can Util::IPC::SHM->attach($mkey)";
    return undef;
  }

  #########################################################
  # 读取 readonly configuration
  #########################################################
  my $skey; 
  my $qkey; 
  my $mbmax; 
  my $slab; 
  my $bsize;
  my $expire;

  # 读取skey
  unless($shm->read(\$skey, BBS_OFFSET_SKEY, $Config{longsize})) {
    cluck "can not read skey";
    return undef;
  }
  $skey = unpack('l', $skey);

  # 读取qkey 
  unless($shm->read(\$qkey, BBS_OFFSET_QKEY, $Config{longsize})) {
    cluck "can not read qkey";
    return undef;
  }
  $qkey = unpack('l', $qkey);

  # 读取mbmax
  unless($shm->read(\$mbmax, BBS_OFFSET_MBMAX, $Config{intsize})) {
    cluck "can not read mbmax";
    return undef;
  }
  $mbmax = unpack('i', $mbmax);

  # 读取slab
  unless($shm->read(\$slab, BBS_OFFSET_SLAB, $Config{intsize})) {
    cluck "can not read slab";
    return undef;
  }
  $slab = unpack('i', $slab);

  # 读取bsize
  unless($shm->read(\$bsize, BBS_OFFSET_BSIZE, $Config{intsize})) {
    cluck "can not read bsize";
    return undef;
  }
  $bsize = unpack('i', $bsize);

  # 读取expire
  unless($shm->read(\$expire, BBS_OFFSET_EXPIRE, $Config{intsize})) {
    cluck "can not read expire";
    return undef;
  }
  $expire = unpack('i', $expire);

  # 连接信号灯 
  my $sem = Util::IPC::SEM->new($skey);
  unless($shm) {
    cluck "can Util::IPC::SEM->new($skey)";
    return undef;
  }

  # bbs对象 
  my $self = bless {
    mkey    => $mkey,
    skey    => $skey,
    qkey    => $qkey,
    shm     => $shm,
    sem     => $sem,
    mbmax   => $mbmax,
    slab    => $slab,
    bsize   => $bsize,
    expire  => $expire,
    esize   => $Config{intsize} * 3 + MBOX_NAME_MAX,
  }, $class;

  return $self;
}

#################################################################
# 增加mbox条目 
# $bbs->create("mb_pack", \%attr);
#################################################################
sub create {

  my $self  = shift;
  my $name  = shift;
  my $attr  = shift;

  ###############################
  # 名称检查 
  ###############################
  unless ( defined $name) {
    cluck "mbox name needed";
    return undef;
  }
  if ( length $name > MBOX_NAME_MAX) {
    cluck "mbox name length must be less than 16";
    return undef;
  }

  ###############################
  # 已经存在的mb 
  ###############################
  for (my $i = 0; $i < $self->{mbmax}; ++$i) {

    my $entry = $self->entry($i);
    if ($entry->{name} eq $name) {
      if ( -p "/tmp/mb/$name") {
        my $fh = IO::File->new("+> /tmp/mb/$name");
        unless($fh) {  
          cluck "IO::File->new failed";
          return undef;
        }
        $fh->autoflush(1);
        $fh->blocking(1);
        $attr->{mode} = 'fifo';
        $attr->{timeout} = $entry->{timeout};
        return $fh;
      }
      else {
        my $mq = Util::IPC::MsgQ->new($self->{qkey} + $i + 1);
        unless($mq) {  
          cluck "Util::IPC::MsgQ->new failed";
          return undef;
        }
        $attr->{mode}    = 'queue';
        $attr->{timeout} = $entry->{timeout};
        return $mq;
      }
      return undef;
    }
  }


  ###############################
  # mbox entry满  
  ###############################
  my $used = $self->used();
  if ($self->used() == $self->{mbmax}) {
    cluck "mb entry is full, used[$used] mbmax[$self->{mbmax}]";
    return  undef;
  }

  ###############################
  # 加锁 
  ###############################
  cluck "can not lock" && return undef unless $self->{sem}->lock();

  ###############################
  # 从last位置开始查找空闲entry 
  ###############################
  my $eid = $self->last();
  for (my $i = 0; $i < $self->{mbmax}; ++$i) {
    $eid = ($eid+1) % $self->{mbmax};
    my $entry = $self->entry($eid); 
    last unless $entry->{flag};
  }
  if ($eid  >= $self->{mbmax}) {
    cluck "no empty entry available";
    goto FAIL;
  }

  ###############################
  # 找到可用的entry
  ###############################
  my $rtn;
  my $nentry = {
    name    => $name,
    qid     => -1,
    flag    => 1,
    timeout => $attr->{timeout} || $self->{expire},
  };
  if ($attr->{mode} =~ /queue/) {
    my $qkey = $self->{qkey} + $eid + 1;
    $rtn = Util::IPC::MsgQ->new($qkey);
    unless($rtn) {
      cluck "cant not Util::IPC::MsgQ->new($qkey)";
      goto FAIL;
    }

    $nentry->{qid} = $$rtn;
  } 
  elsif ($attr->{mode} =~ /fifo/) {
    unless( -d "/tmp/mb") {
      mkpath("/tmp/mb", {verbose => 0, mode => 0711});
    }
    unless( -p "/tmp/mb/$name") {
      unless(mkfifo("/tmp/mb/$name", 0700)) {
        cluck "can not mkfifo /tmp/mb/$name";
        goto FAIL;
      }
    }
    $rtn = IO::File->new("+> /tmp/mb/$name");
    unless($rtn) {
      cluck "can not new(+> /tmp/mb/$name)";
      goto FAIL;
    }
    $rtn->autoflush(1);
    $rtn->blocking(1);
  } 
  else {
    cluck "unsupported mode $attr->{mode}";
    goto FAIL;
  }

  # entry写入bbs 
  unless ($self->entry( $eid,$nentry)) {
    cluck "can not \$self->entry";
    goto FAIL;
  }

  ###############################
  # 管理 
  ###############################
  $self->used(+1);
  $self->last($eid);

  ###############################
  # 解锁 && 返回
  ###############################
  unless($self->{sem}->unlock()) {
    cluck "can not unlock";
    return undef;
  }
  return $rtn;

FAIL:
  cluck "can not unlock" unless $self->{sem}->unlock();
  return undef;
}

#################################################################
# 删除mbox条目 
#################################################################
sub delete {

  my $self  = shift;
  my $name  = shift;

  $self->{sem}->lock();

  my $i;
  my $entry;
  for ($i = 0; $i < $self->{mbmax}; ++$i) {
    $entry = $self->entry($i);
    if ($entry->{name} eq $name) {
      last;
    }
  }
  if ($i >= $self->{mbmax}) {
    cluck "there is no mbox named $name";
    return $self;
  }

  $entry->{flag} = 0;
  $self->entry($i, $entry);
  if ( -p "/tmp/mb/$name") {
    unlink "/tmp/mb/$name"; 
  }
  else {
    Util::IPC::MsgQ->delete($entry->{id});
  }
  $self->used(-1);

  $self->{sem}->unlock();

  return $self;
}

#################################################################
# 读取used
# 写入used
# $self->used()
# $self->used(-1);
# $self->used(+1);
#################################################################
sub used {
  my $self = shift;
  my $op   = shift;
  my $used;

  # 写入 
  if ($op) {
    $self->{shm}->read(\$used, BBS_OFFSET_USED, $Config{intsize});
    $used  = unpack('i', $used);
    $used += $op;
    $used  = pack('i', $used);
    $self->{shm}->write(\$used, BBS_OFFSET_USED, $Config{intsize});
    return $self;
  }

  # 读取  
  $self->{shm}->read(\$used, BBS_OFFSET_USED, $Config{intsize});
  return unpack('i', $used);
}

#################################################################
# 读取last
# 写入last
# $self->last();
# $self->last(10);
#################################################################
sub last {

  my $self = shift;
  my $id   = shift;

  # 写入 
  if ($id) {
    my $last  = pack('i', $id);
    $self->{shm}->write(\$last, BBS_OFFSET_LAST, $Config{intsize});
    return $self;
  }

  # 读取  
  my $last;
  $self->{shm}->read(\$last, BBS_OFFSET_LAST, $Config{intsize});
  return unpack('i', $last);
}

#################################################################
# 读取mb条目 
# 写入条目  
# $self->entry(10);
# $self->entry({ flag => 1/0, name => $name, qid => $qid);
#################################################################
sub entry {
  my $self = shift;
  my $id   = shift;
  my $data = shift;

  my $offset = BBS_OFFSET_ENTRY + $self->{esize} * $id;

  # 读取条目 : [flag:int] + [qid:int] + [name:16]
  unless($data) {
    my $entry;
    unless($self->{shm}->read(\$entry, $offset, $self->{esize} )) {
      cluck "can not read entry[$id]";
      return undef;
    }
    my ($flag, $qid, $timeout, $name) = unpack('iiia' . MBOX_NAME_MAX, $entry);
    $name =~ s/\0{1,}//g;
    return {
      name    => $name,
      qid     => $qid,
      timeout => $timeout,
      flag    => $flag,
    };
  }

  # 写入条目 
  my $entry = pack('iiia' . MBOX_NAME_MAX, $data->{flag}, $data->{qid}, $data->{timeout}, $data->{name} );
  unless($self->{shm}->write(\$entry, $offset, $self->{esize} )) {
    cluck "can not write entry[$id]";
    return undef;
  }
  return $self;
}

#################################################################
# {
#   skey  : long => semaphore key    readonly
#   qkey  : long => queue key        readonly
#   mbmax : int  => mbox max cnt     readonly
#   slab  : int  => slab count       readonly
#   used  : int  => used mbox entry  r/w
#   last  : int  => last entry       r/w
# }
# [flag:int] + [qid:int] + [ mb3:16Byte]
# [flag:int] + [qid:int] + [ mb3:16Byte]
# [flag:int] + [qid:int] + [ mb3:16Byte]
#################################################################
sub summary {

  my $self = shift;
  my $shm = $self->{shm};

  my @entry;
  for (my $i = 0; $i < $self->{mbmax}; ++$i) {
    $entry[$i] = $self->entry($i);
  }

  return {
    skey   => $self->{skey},
    qkey   => $self->{qkey},
    mbmax  => $self->{mbmax},
    expire => $self->{expire},
    slab   => $self->{slab},
    bsize  => $self->{bsize},
    used   => $self->used(),
    last   => $self->last(),
    entry  => \@entry,
  };
}

1;

