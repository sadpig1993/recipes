package Util::Proto::8583::Constant;
use strict;
use warnings;
use Data::Dump;
use Carp qw/cluck/;

sub import {

  my $pkg = caller();
  no strict 'refs';

  *{ $pkg . '::TYPE_N'      } = \&TYPE_N;
  *{ $pkg . '::TYPE_B'      } = \&TYPE_B;
  *{ $pkg . '::TYPE_AN'     } = \&TYPE_AN;
  *{ $pkg . '::TYPE_ANS'    } = \&TYPE_ANS;

  *{ $pkg . '::CLASS_FIX'   } = \&CLASS_FIX;
  *{ $pkg . '::CLASS_LLVAR' } = \&CLASS_LLVAR;
  *{ $pkg . '::CLASS_LLLVAR'} = \&CLASS_LLLVAR;
  *{ $pkg . '::CLASS_YYMM'  } = \&CLASS_YYMM;
  *{ $pkg . '::CLASS_MMDD'  } = \&CLASS_MMDD;
  *{ $pkg . '::CLASS_HHMMSS'} = \&CLASS_HHMMSS;

  *{ $pkg . '::LENC_ASCII'  } = \&LENC_ASCII;
  *{ $pkg . '::LENC_BCD'    } = \&LENC_BCD;

  *{ $pkg . '::DENC_ASCII'  } = \&DENC_ASCII;
  *{ $pkg . '::DENC_BCD'    } = \&DENC_BCD;

  *{ $pkg . '::JUST_LEFT'   } = \&JUST_LEFT;
  *{ $pkg . '::JUST_RIGHT'  } = \&JUST_RIGHT;

  *{ $pkg . '::PAD_SPACE'   } = \&PAD_SPACE;
  *{ $pkg . '::PAD_ZERO'    } = \&PAD_ZERO;

  *{ $pkg . '::TYPE_IDX'    } = \&TYPE_IDX;
  *{ $pkg . '::LEN_IDX'     } = \&LEN_IDX;
  *{ $pkg . '::CLASS_IDX'   } = \&CLASS_IDX;
  *{ $pkg . '::LENC_IDX'    } = \&LENC_IDX;
  *{ $pkg . '::DENC_IDX'    } = \&DENC_IDX;
  *{ $pkg . '::JUST_IDX'    } = \&JUST_IDX;
  *{ $pkg . '::PAD_IDX'     } = \&PAD_IDX;
  *{ $pkg . '::DESC_IDX'    } = \&DESC_IDX;
  *{ $pkg . '::CHECK_IDX'   } = \&CHECK_IDX;

  *{ $pkg . '::check_n'     } = \&check_n;
  *{ $pkg . '::check_b'     } = \&check_b;
  *{ $pkg . '::check_an'    } = \&check_an;
  *{ $pkg . '::check_ans'   } = \&check_ans;

  *{ $pkg . '::fld_type'    } = \&fld_type;
  *{ $pkg . '::fld_len'     } = \&fld_len;
  *{ $pkg . '::fld_class'   } = \&fld_class;
  *{ $pkg . '::fld_lenc'    } = \&fld_lenc;
  *{ $pkg . '::fld_denc'    } = \&fld_denc;
  *{ $pkg . '::fld_just'    } = \&fld_just;
  *{ $pkg . '::fld_pad'     } = \&fld_pad;
  *{ $pkg . '::fld_desc'    } = \&fld_desc;
  *{ $pkg . '::fld_check'   } = \&fld_check;
}


################################################################
# type: n a s b Xn
################################################################
sub TYPE_N        { 0 }   # 数字类型  
sub TYPE_B        { 1 }   # 二进制类型 
sub TYPE_AN       { 2 }   # alpha numeric 
sub TYPE_ANS      { 3 }   # alpha numeric, special

################################################################
# class:  fix llvar lllvar  yymm mmdd hhmmss
################################################################
sub CLASS_FIX     { 0 }   # 固定长度
sub CLASS_LLVAR   { 1 }   # llvar
sub CLASS_LLLVAR  { 2 }   # lllvar
sub CLASS_YYMM    { 3 }   # 09/22
sub CLASS_MMDD    { 4 }   # 09-22
sub CLASS_HHMMSS  { 5 }   # 12:12:12

################################################################
# lenc:  ascii  bcd
################################################################
sub LENC_ASCII    { 0 }   # 长度部分编码类型: ascii 
sub LENC_BCD      { 1 }   # 长度部分编码类型: bcd

################################################################
# denc:  ascii  bcd
################################################################
sub DENC_ASCII    { 0 }   # 数据部分编码类型 ascii 
sub DENC_BCD      { 1 }   # 数据部分编码类型 bcd

################################################################
# justify:  left right
################################################################
sub JUST_LEFT     { 0 }   # 左靠 
sub JUST_RIGHT    { 1 }   # 右靠 

################################################################
# padding:
################################################################
sub PAD_SPACE     { ' ' } # 补空格  
sub PAD_ZERO      { '0' } # 补0  

################################################################
# config name index
################################################################
sub TYPE_IDX      { 0 }   # type  index
sub LEN_IDX       { 1 }   # len   index
sub CLASS_IDX     { 2 }   # class index
sub LENC_IDX      { 3 }   # lenc  index
sub DENC_IDX      { 4 }   # denc  index
sub JUST_IDX      { 5 }   # just  index
sub PAD_IDX       { 6 }   # pad   index
sub DESC_IDX      { 7 }   # desc  index
sub CHECK_IDX     { 8 }   # check index

####################################
#
####################################
sub fld_type {
  my $literal = shift;
  if ($literal =~ /^n$/) {
    return TYPE_N;
  }
  if ($literal =~ /^b$/) {
    return TYPE_B;
  }
  if ($literal =~ /^an$/) {
    return TYPE_AN;
  }
  if ($literal =~ /^ans$/) {
    return TYPE_ANS;
  }
  return undef;
}

####################################
#
####################################
sub fld_len {
  return shift;
}

####################################
#
####################################
sub fld_class {
  my $literal = shift;
  if ($literal =~ /fix/) {
    return CLASS_FIX;
  }
  if ($literal =~ /hhmmss/) {
    return CLASS_HHMMSS;
  }
  if ($literal =~ /mmdd/) {
    return CLASS_MMDD;
  }
  if ($literal =~ /yymm/) {
    return CLASS_YYMM;
  }

  return undef;
}

####################################
#
####################################
sub fld_lenc {
  my $literal = shift;
  if ($literal =~ /undef/) {
    return undef;
  }
  if ($literal =~ /bcd/) {
    return LENC_BCD;
  }
  if ($literal =~ /ascii/) {
    return LENC_ASCII;
  }
  return undef;
}

####################################
#
####################################
sub fld_denc {
  return fld_lenc(shift);
}

####################################
#
####################################
sub fld_just {

  my $literal = shift;
  if ($literal =~ /left/) {
    return JUST_LEFT;
  }
  if ($literal =~ /right/) {
    return JUST_RIGHT;
  }
  return undef;

}

####################################
#
####################################
sub fld_pad {

  my $literal = shift;
  if ($literal =~ /space/) {
    return PAD_SPACE;
  }
  if ($literal =~ /zero/) {
    return PAD_ZERO;
  }
  return undef;

}

####################################
#
####################################
sub fld_desc {
  return shift;
}

####################################
#
####################################
sub fld_check {
  my $literal = shift;
  if ($literal =~ /^n/) {
    return \&check_n;
  }
  if ($literal =~ /^b/) {
    return \&check_b;
  }
  if ($literal =~ /^an/) {
    return \&check_an;
  }
  if ($literal =~ /^ans/) {
    return \&check_ans;
  }
  return undef;
}


####################################
#
####################################
sub check_n {
  my $data = shift;
  unless(isdigit($data)) {
    return undef;
  } 
  return 1;
}

####################################
#
####################################
sub check_b {
  return 1;
}

####################################
#
####################################
sub check_an {
  my $data = shift;
  unless(isalnum($data)) {
    return undef;
  } 
  return 1;
}

####################################
#
####################################
sub check_ans {
  return 1;
}

1;

