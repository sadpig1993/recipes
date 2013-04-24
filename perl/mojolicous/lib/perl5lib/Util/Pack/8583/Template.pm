package Util::Proto::8583::POSP;

use strict;
use warnings;

use base qw/Util::Proto::8583/;

###########################################
# 解包前处理 
# 参数:
#   $dref
# 返回值: 
#   undef:    failed
#   $header:  success + $dref
###########################################
sub pre_unpack {

  my $self = shift;
  my $dref = shift;

  my $logger = $self->{logger};
  $logger->debug("begin pre_unpack...");

  my $header;
  return undef;

}

###########################################
# 解包后处理:
# 参数:
#   $header
#   $fld
# 返回值:
#   $swt
###########################################
sub post_unpack {
   my $self = shift;
   my $header = shift;
   my $fld    = shift;

  my $logger = $self->{logger};
  $logger->debug("begin post_unpack...");

   my %swt;
   return \%swt;
}

###########################################
# pack前处理 
# 参数:
#   $swt :
#   undef:  pre_pack′|àíê§°ü
# 返回值 
#   [header, $fld]
###########################################
sub pre_pack {
  my $self = shift;
  my $swt  = shift;
 
  my $logger = $self->{logger};
  $logger->debug("begin pre_pack...");

  my $header;
  my @fld; 
  return [ $header, \@fld ];
}

###########################################
# 打包后处理 
# 参数:
#   $header
#   \$data
# 返回值:
#   undef:  failed
#   $self:  $dref changed
###########################################
sub post_pack {
  my $self   = shift;
  my $header = shift;
  my $dref   = shift;

  my $logger = $self->{logger};
  $logger->debug("begin post_pack...");

  return $self;
}

1;

