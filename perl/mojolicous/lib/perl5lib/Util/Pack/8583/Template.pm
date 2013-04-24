package Util::Proto::8583::POSP;

use strict;
use warnings;

use base qw/Util::Proto::8583/;

###########################################
# ���ǰ���� 
# ����:
#   $dref
# ����ֵ: 
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
# �������:
# ����:
#   $header
#   $fld
# ����ֵ:
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
# packǰ���� 
# ����:
#   $swt :
#   undef:  pre_pack��|��������㨹
# ����ֵ 
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
# ������� 
# ����:
#   $header
#   \$data
# ����ֵ:
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

