package Util::IPC::MB::GC;

use strict;
use warnings;
use POE;

########################################################
# gc_rate      => 0.3
# gc_idle_max  => 5,
# gc_interval  => 10,
# logger       => $logger
########################################################
sub spawn {

  my $class = shift;

  my $self = bless { @_ },  $class;

  my $mbi = Util::IPC::MB->new();
  unless($mbi) {
    warn "can not Util::IPC::MB->new()";
  }

  $self->{gc_rate}      ||= 0.3;
  $self->{gc_idle_max}  ||= 5;
  $self->{gc_interval}  ||= 10;
  $self->{slab}   = $mbi->{slab};
  $self->{logger} = $self->{logger}->clone('gc.log');

  POE::Session->create(
    object_states => [
      $self => {
        _start => 'on_start',
        on_gc  => 'on_gc', 
      },
    ],
  );

  return $self;
}

########################################################
#
########################################################
sub on_start {
  $_[KERNEL]->yield('on_gc' => $_[OBJECT]->{gc_interval});
}

########################################################
#
########################################################
sub on_gc {

  my $self = $_[OBJECT];

  my $used  = 0; 
  my $total = 0;
  my $slab  = $self->{slab};

  for (my $i = 0; $i < @$slab; ++$i) {
    $used  += $slab->[$i]->used();
    $total += $slab->[$i]->{blkcnt};
  }
 
  # 暂时不gc 
  if ( $used / $total < $self->{gc_rate}) {
    if (++$self->{idle} < $self->{gc_idle_max}) {
      $_[KERNEL]->delay('on_gc'  => $self->{gc_interval});
      return 1;
    }
  }

  $self->{idle} = 0;
  # 开始gc  
  my $gc = 0;
  for (my $i = 0; $i < @$slab; ++$i) {
    my $cnt = $slab->[$i]->gc();
    $gc += $cnt;
    $self->{logger}->info("slab[$i] gc block[$cnt]");
  }

  $_[KERNEL]->delay('on_gc' => $self->{gc_interval});

  return 1;
}

1;

