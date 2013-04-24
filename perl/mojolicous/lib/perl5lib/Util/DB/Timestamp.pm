package Util::DB::Timestamp;

use strict;
use warnings;

use POSIX qw/mktime/;
use Time::HiRes qw/tv_interval gettimeofday/;
use base qw/Exporter/;

our @EXPORT = qw/
ts_add ts_sub
ts_interval
ts_lt ts_le 
ts_gt ts_ge 
ts_eq ts_ne
/;

our @EXPORT_OK =qw/
ts_add
ts_interval
/;

use Data::Dump;


############################################
#  t1   db2 timestamp | [ s, ms ]
#  t2   db2 timestamp | [ s, ms ]
############################################
sub ts_add {

  # Data::Dump->dump(\@_);
  my ($tv1, $tv2) = &_get_tv(@_);
  # Data::Dump->dump($tv1, $tv2);

  $tv1->[1] +=  $tv2->[1];
  $tv1->[0] +=  $tv2->[0];

  # 进位  
  if ( $tv1->[1] >= 1000000 ) {
    my $a = $tv1->[1] % 1000000;
    $tv1->[1] = $a;
    $tv1->[0] = $tv1->[0] + $tv2->[0] + 1;
  } else {
    $tv1->[0] = $tv1->[0] + $tv2->[0];
  }

  return unless defined wantarray;

  if (wantarray) {
    return @$tv1;
  }
  else {
    my ($y, $m, $d, $H, $M, $S) = (localtime($tv1->[0]))[5,4,3,2,1,0];
    $y += 1900;
    $m += 1;

    my $rtn = sprintf("%04d-%02d-%02d %02d:%02d:%02d.%06d", $y, $m, $d, $H, $M, $S, $tv1->[1]);
    $rtn =~ s/(\.\d{6})(\d+)$/$1/;
    return $rtn;
  }
}

############################################
#
############################################
sub ts_sub {

  my ($tv1, $tv2) = &_get_tv(@_);
  my ($y, $m, $d, $H, $M, $S);

  $tv2->[0] = 0 unless defined $tv2->[0];
  $tv2->[1] = 0 unless defined $tv2->[1];

  $tv1->[0] -= $tv2->[0];
  $tv1->[1] -= $tv2->[1];

  # 借位  
  if ( $tv1->[1] < 0 ) {
    $tv1->[0] -= 1;
    $tv1->[1] += 1000000;
  } 

  #
  return unless defined wantarray;
  if (wantarray) {
    return @$tv1;
  }
  else {
    ($y, $m, $d, $H, $M, $S) = (localtime($tv1->[0]))[5,4,3,2,1,0];
    $y += 1900;
    $m += 1;

    my $rtn = sprintf("%04d-%02d-%02d %02d:%02d:%02d.%06d", $y, $m, $d, $H, $M, $S, $tv1->[1]);
    $rtn =~ s/(\.\d{6})(\d+)$/$1/;
    return $rtn;
  }

}


############################################
#  t1   db2 timestamp | [ s, ms ]
#  t2   db2 timestamp | [ s, ms ]
#  floating
############################################
sub ts_interval {
  return tv_interval(&_get_tv(@_));
}

#####################################
#  less than:      <
#  greater equal:  >=
#####################################
sub ts_lt {

  my ($tv1, $tv2) = &_get_tv(@_);

  # 高位小，肯定小
  if ( $tv1->[0] < $tv2->[0]) {
    return 1;
  } 

  # 高位相等， 看低位 
  elsif ( $tv1->[0] == $tv2->[0]) {
    if ($tv1->[1] < $tv2->[1]) {
      return 1;
    }
    return 0;
  } 

  # 高位大 肯定大  
  else {
    return 0;
  }
}

sub ts_ge {

  my @caller = caller;
  return ! &ts_lt(@_);
}

#####################################
#  greater than: >
#  less or eq:   <=
#####################################
sub ts_gt {

  my ($tv1, $tv2) = &_get_tv(@_);

  # 高位大 肯定大  
  if ( $tv1->[0] > $tv2->[0]) {
    return 1;
  } 

  # 高位相等， 看低位 
  elsif ( $tv1->[0] == $tv2->[0]) {
    if ($tv1->[1] > $tv2->[1]) {
      return 1;
    }
    return 0;
  } 

  # 高位小， 肯定小 
  else {
    return 0;
  }

}

sub ts_le {
  return ! &ts_gt(@_);
}

#####################################
#  eq: ==
#  ne: !=
#####################################
sub ts_eq {
  my ($tv1, $tv2) = &_get_tv(@_);
  return ($tv1->[0] == $tv2->[0]  &&  $tv1->[1] == $tv2->[1]);
}

sub ts_ne {
  return ! &ts_eq(@_);
}

############################################
# return a tv represented  timestamp value
############################################
sub _get_tv {
  
  my ($t1, $t2) = @_;

  my $now;
  my ($tv1, $tv2);

  if ( 'ARRAY' eq ref $t1) {
    $tv1 = [ @$t1 ];
  } 
  else {

    if ($t1 =~ /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})\.(\d+)/ ) {
      # my ($y, $m, $d, $H, $M, $S) = ($1, $2, $3, $4, $5, $6);
      # $now = mktime($S, $M, $H, $d, $m - 1 , $y - 1900);
      $now = mktime($6, $5, $4, $3, $2 - 1 , $1 - 1900);
      
      my $us = $7 . ("0" x (6 - length($7)) );
      $tv1 = [$now, $us];

    } 
    elsif ($t1 =~ /(\d+)\.(\d+)/) {
      $tv1 = [ $1, $2 ];
    }

  }

  if ( 'ARRAY' eq ref $t2) {
    $tv2 = [ @$t2 ];
  } 
  else {
    if ( $t2 =~ /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})\.(\d+)/ ) {
      # my ($y, $m, $d, $H, $M, $S) = ($1, $2, $3, $4, $5, $6);
      # $now = mktime($S, $M, $H, $d, $m - 1 , $y - 1900);
      $now = mktime($6, $5, $4, $3, $2 - 1 , $1 - 1900);
      $tv2 = [$now, $7];
    }
    elsif ($t2 =~ /(\d+)\.(\d+)/) {
      $tv2 = [$1, $2];
    }
  }
  # Data::Dump->dump($tv1, $tv2);

  return ($tv1, $tv2);

}

1;

__END__
=head1 NAME
  
  Util::DB::Timestamp 

=head1 SYNOPSIS

  #!/usr/bin/perl -w
  use strict;
  use Util::DB::Timestamp qw/
  ts_interval 
  ts_addd 
  ts_sub 
  ts_lt 
  ts_le 
  ts_gt 
  ts_ge 
  ts_eq 
  ts_ne/;

  my $float = ts_interval('2012-12-12 00:00:00.12', '2012-12-12 00:00:00.12');
  warn "ts_interval is $float";

=head1 API


=head1 Author & Copyright

  zcman2005@gmail.com

=cut
                                  




