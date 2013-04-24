package Util::IPC::MB;
use strict;
use warnings;
use Carp qw/cluck/;
use Config;
use Util::IPC::MsgQ;
use Util::IPC::SHM;
use Util::IPC::SEM;
use Util::IPC::MB::BBS;
use Util::IPC::MB::Slab;

#######################################################
# mkey    =>  88880000
# qkey    =>  88880000
# skey    =>  88880000
# slab    =>  16      
# blkcnt  =>  1024
# blksize =>  8k
# mbmax   =>  100
# expire  =>  60
#######################################################
sub init {

  my $class = shift;
  my $args  = { @_ };

  my @slab;
  my $bbs;

  for (my $i = 0; $i < $args->{slab}; ++$i) {
    my $slab  = Util::IPC::MB::Slab->init( 
      blksize => $args->{blksize}, 
      blkcnt  => $args->{blkcnt},
      mkey    => $args->{mkey} + $i + 1,
      skey    => $args->{skey} + $i + 1,
    );
    unless($slab) {
      cluck "can not Util::IPC::MB::Slab->init";
      return undef;
    }
    push @slab, $slab;
  }

  #
  #  bbs格式:
  #  [mb_name:16bytes]  + [mb_qid:int]
  #
  $bbs = Util::IPC::MB::BBS->init(
    skey   => $args->{skey}, 
    qkey   => $args->{qkey}, 
    mkey   => $args->{mkey}, 
    mbmax  => $args->{mbmax},
    slab   => $args->{slab},
    expire => $args->{expire}, 
    bsize  => $args->{blksize},
  );
  unless($bbs) {
    return undef;
  }

  bless {
    slab => \@slab,
    bbs  => $bbs,
  }, $class;
}

##################################################################
# 连接到mb系统 
# $class->new();
##################################################################
sub new {

  my $class = shift;

  my $bbs;
  my $slab;

  # 连接bbs
  $bbs = Util::IPC::MB::BBS->new();
  unless( $bbs ) {
    cluck "can not Util::IPC::MB::BBS->new";
    return undef;
  }
  
  # 连接到所有的slab
  $slab = $class->all_slab($bbs); 
  unless($slab) {
    warn "all_slab error";
    return undef;
  }

  # 返回  
  bless {
    slab    => $slab,
    bbs     => $bbs,
  }, $class;
 
}

##################################################################
# 连接到所有slab
##################################################################
sub all_slab {

  my $self_or_class = shift;
  my $bbs  = shift;

  my @slab;
  for (my $i = 0; $i < $bbs->{slab}; ++$i) {
    my $tslab = Util::IPC::MB::Slab->new(
      mkey  => $bbs->{mkey} + $i + 1,
      skey  => $bbs->{skey} + $i + 1,
    );
    unless($tslab) {
      warn "can not connect to slab[$i]";
      return undef;
    }
    push @slab, $tslab;
  }
  return \@slab;
}

##################################################################
# 创建mbox
# $mbi->create($name {mode => 'fifo', timeout => 100});
##################################################################
sub create {

  my $self = shift;
  my $name = shift;

  my $attr = shift;
  unless(defined $attr) {
    $attr->{mode}    = 'queue';
    $attr->{timeout} = 60;
  }
  $attr->{mode}  ||= 'queue';

  my $rtn = $self->{bbs}->create($name, $attr);
  unless($rtn) {
    cluck "bbs->create failed";
    return undef;
  }

  return bless {
    bbs     => $self->{bbs},
    slab    => $self->{slab},
    channel => $rtn,
    bsize   => $self->{bbs}->{bsize},
    attr    => $attr,
    name    => $name,
  }, ref $self;

}

##################################################################
# 删除mbox
##################################################################
sub delete {

  my $self = shift;
  my $idx  = $self->{idx};
  unless($self->{bbs}->delete($self->{name})) {
    cluck "can not delete mbox $self->{name}";
    return undef;
  }
  return $self;
}

##################################################################
# 往mailbox写 
# $mb->write($dref);
##################################################################
sub write {

  my $self = shift;
  my $dref = shift;

  my $len = length $$dref;
  if ($len > $self->{bsize}) {
    cluck "data too long[$len]";
    return undef;
  }

  # 遍历所有的slab, 寻找空闲块  
  my $attr = $self->{attr};
  my $bid;
  my $sid;
  my $slab = $self->{slab};
  for ($sid = 0; $sid < @$slab; ++$sid) {
    $bid = $slab->[$sid]->alloc($attr);
    last if defined $bid;
  }
  unless(defined $bid) {
    cluck "insufficient memory";
    return undef;
  }

  warn "got free block[$sid, $bid]\n";

  # 写入数据
  unless($slab->[$sid]->write($dref, $len, $bid)) {
    $slab->[$sid]->free($bid);
    cluck "write data length[$len] to block[$sid, $bid] failed";
    return undef;
  }

  # 写入成功后， 发送消息
  if ($attr->{mode} =~ /queue/) {
    unless($self->{channel}->send(pack('ssi', $sid, $bid, $len), $$)) {
      $slab->[$sid]->free($bid);
      cluck "can not send to queue[${$self->{mq}}] for [$sid,$bid,$len]";
      return undef;
    }
  }
  elsif($attr->{mode} =~ /fifo/) {
    unless($self->{channel}->print(pack('ssi', $sid, $bid, $len))) {
      $slab->[$sid]->free($bid);
      cluck "can not send to fifo for [$sid,$bid,$len]";
      return undef;
    }
  }
  else {
    $slab->[$sid]->free($bid);
    cluck "internal error";
    return undef;
  }

  return $self;

}

##################################################################
# 从mailbox 读  
# $mb->read(\$data);
##################################################################
sub read {

  my $self = shift;
  my $dref = shift;
  my $msg;
  my $attr = $self->{attr};

RETRY:
  ######################################################################
  # 读取消息, 消息格式: [slab_id:short] + [blk_id:short] + [size:int]
  ######################################################################
  if ($attr->{mode} =~ /queue/) {
    unless($self->{channel}->recv(\$msg, 0)) {
      cluck("can not read msg from ${$self->{channel}}");
      return undef;
    }
    $msg = substr($msg, $Config{longsize});   # remove msgtype;
  }
  elsif ($attr->{mode} =~ /fifo/) {
    unless($self->{channel}->read($msg, $Config{shortsize}*2 + $Config{intsize})) {
      cluck("can not read msg from fifo");
      return undef;
    }
  }
  else {
    cluck "internal error";
    return undef;
  }

  ######################################################################
  # 获取slab_id, blk_id, $size
  ######################################################################
  my ($sid, $bid, $size) = unpack('ssi', $msg);
  unless(defined $sid && defined $bid && defined $size) {
    cluck "invalid msg[$msg]";
    return undef;
  }
  
  # sid非法
  if($sid > @{$self->{slab}}) {  
    cluck "invalid sid[$sid]";
    return undef;
  }
  my $slab = $self->{slab}->[$sid];

  # 
  # bid非法
  if($bid >= $slab->{blkcnt}) {
    cluck "invalid bid:[$bid], slab[$sid].blkcnt:[$slab->{blkcnt}]";
    return undef;
  }

  # 收到超时的消息  
  if ($slab->[$sid]->map($bid) < time()) {
    cluck "got an timeout msg";
    $slab->free($bid);
    goto RETRY;
  } 

  ######################################################################
  # 读取指定slab的指定bid数据
  ######################################################################
  unless($slab->read($bid, $dref, $size)) {
    $slab->free($bid);
    cluck "read sid[$sid] bid[$bid] failed";
    return undef;
  }

  ######################################################################
  # 释放空间  
  ######################################################################
  $slab->free($bid);

  return $self;
}

1;

__END__

=head1 NAME

  Util::IPC::MB  - a simple mailmox implementation

=head1 SYNOPSIS

  #--------------------------------------------------
  #  sender.pl
  #--------------------------------------------------
  #!/usr/bin/perl -w
  use strict;

  my $mbi = Util::IPC::MB->new();
  my $mb  = $mbi->create('mb_test', { mode => 'queue', timeout => 10 });

  while(1) {
    $mb->write("this is a test");
    sleep 1;
  }
  exit 0;


  #--------------------------------------------------
  #  recver.pl 
  #--------------------------------------------------
  #!/usr/bin/perl -w
  use strict;

  my $mbi = Util::IPC::MB->new();
  my $mb  = $mbi->create('mb_test');

  while(1) {
    $mb->read(\$data);
    warn "read: [$data]\n";
  }
  exit 0;



=head1 API

  init
  new
  create
  delete
  write
  read


=head2 init

  slab    =>
  mkey    =>
  skey    =>
  qkey    =>
  blksize =>
  blkcnt  =>
  mbmax   =>


=head2 new



=head2 create('mb_name', \%attr)

  attr:
    mode    => 'queue|fifo',
    timeout => 10,


=head2 delete('mb_name');
  


=head2 write(\$data)
  


=head2 read(\$data)
  



=head1 Author & Copyright

  zcman2005@gmail.com

=cut

