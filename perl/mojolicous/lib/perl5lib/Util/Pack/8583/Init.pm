package Util::Proto::8583::Init;

use strict;
use warnings;
use Data::Dump;
use Carp qw/cluck/;
use Util::Proto::8583::Constant;
use base qw/Exporter/;

our @EXPORT = qw/
init_config_file
init_chk_file
init_txn_file
init_hsm
/;

##########################################################
#
##########################################################
sub init_config_file {

  my $conf = shift;

  unless( defined $conf) {
    cluck "file \$conf needed";
    return undef;
  }

  unless(-f $conf) {
    cluck "file $conf does not exists";
    return undef;
  }
  my $fh = IO::File->new("< $conf");
  unless($fh) {
    cluck "can not open file $conf";
    return undef;
  }

  my @config;
  while(<$fh>) {
    s/^\s+//g;
    s/\s+$//g;
    next if /^$/;
    next if /^#/;
    my @data = split /\s+/, $_;
    my $id = shift @data;
    my @dmap;

    # type
    $dmap[TYPE_IDX]  = fld_type ($data[TYPE_IDX] );
    $dmap[LEN_IDX]   = fld_len  ($data[LEN_IDX]  );
    $dmap[CLASS_IDX] = fld_class($data[CLASS_IDX]);
    $dmap[LENC_IDX]  = fld_lenc ($data[LENC_IDX] );
    $dmap[DENC_IDX]  = fld_denc ($data[DENC_IDX] );
    $dmap[JUST_IDX]  = fld_just ($data[JUST_IDX] );
    $dmap[PAD_IDX]   = fld_pad  ($data[PAD_IDX]  );
    $dmap[DESC_IDX]  = fld_desc ($data[DESC_IDX] );
    $dmap[CHECK_IDX] = fld_check($data[TYPE_IDX] );  # 域格式检查函数   
    $config[$id] = \@dmap;
  }

  return \@config;
}

##########################################################
# 读检查文件  
##########################################################
sub init_chk_file {
  my $chk_file = shift;
  return undef;
}

##########################################################
# 读交易配置文件,此文件描述了 哪些域如何决定交易名称    
##########################################################
sub init_txn_file {
  return undef;
}

##########################################################
# 加密机初始化  
##########################################################
sub init_hsm {
  my $hsmi   = shift;
  my $logger = shift;
  my ($pm, $argstr) = split /\s*\|\s*/, $hsmi;
  my @args = split /\s+/, $argstr;
  eval "use $pm;";
  if($@) {
    cluck "can not load module[$pm] error[$@]";
    return undef;
  }
  push @args, "logger", $logger;
  my $hsm = $pm->new(@args);
  unless($hsm) {
    $logger->error("can not $pm create");
    return undef;
  }

  return $hsm;
}

1;

