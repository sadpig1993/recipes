package Util::Proto::VSep::ICBC;

use strict;
use warnings;

use base qw/Util::Proto::VSep/;


###################################
# ��swt����ת����vsep����  
###################################
sub _out {
  my $self = shift;
  my $swt  = shift;
  return $swt;
}

###################################
# ��vset����ת����swt���� 
###################################
sub _in {
  my $self = shift;
  my $out  = shift;
  return $out;
}

1;

