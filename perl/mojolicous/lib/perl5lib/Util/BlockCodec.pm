package Util::BlockCodec;

use strict;
use warnings;
use base qw/Exporter/;
use Carp qw/cluck/;
use Util::Encode;

our @EXPORT_OK = qw(
nac_dec
nac_enc
ins_dec
ins_enc 
ascii_n
binary_n
bcd_n
);
our @EXPORT = @EXPORT_OK;

##########################
#
##########################
sub nac_enc {

  my $stuff = shift;

  unless(defined $$stuff) {
    cluck "nac_enc error";
    return;
  }

  my $len_part = pack('s', length $$stuff);
  my @t = split '', $len_part;
  my @tt;
  $tt[0] = $t[1];
  $tt[1] = $t[0];
  $len_part = join '', @tt;

  $$stuff   = $len_part . $$stuff;

  return;
}

##########################
#
##########################
sub nac_dec {

  my $stuff = shift;

  unless(defined $$stuff) {
    cluck "nac_ec error";
    return;
  }

  if (length $$stuff < 2 ) {
    # warn "length now is less than 2, can not decode now";
    return;
  }

  $$stuff =~ s/^(.)(.)//;
  my @tt = ($2, $1);
  my $len_part = join '', @tt;
  my $len = unpack('s', $len_part);

  return $len;

}

###############################
#
###############################
sub ins_enc {

  my $stuff = shift;
  
  unless(defined $$stuff) {
    cluck "ins_enc error";
    return;
  }

  # warn "before ins_enc: stuff[$$stuff]";
  my $len_part = sprintf("%04d", length $$stuff);
  $$stuff   = $len_part . $$stuff;
  # warn "after  ins_enc: stuff[$$stuff]";

  return;
}

###############################
#
###############################
sub ins_dec {

  my $stuff = shift;

  unless(defined $$stuff) {
    cluck "nac_ec error";
    return;
  }

  # warn "before ins_dec: stuff[$$stuff]";
  unless ($$stuff =~ s/^(.{4})//) {
    return;
  }
  my $len_part = $1;
  $len_part =~ s/^0+//g;
  # warn "after  ins_dec: stuff[$$stuff] len_part[$len_part]";
  return $len_part;

}

###############################
# return [ascii_enc, ascii_dec]
###############################
sub ascii_n {

  my $n = shift;
  my $format = "%0$n" . "d";

  return [
    sub {
      my $stuff = shift;
      unless(defined $$stuff) {
        cluck "enc error";
        return;
      }

      my $len_part = sprintf($format, length $$stuff);
      $$stuff   = $len_part . $$stuff;
      return;
    },

    sub {
      my $stuff = shift;
      unless(defined $$stuff) {
        cluck "dec error";
        return;
      }

      unless ($$stuff =~ s/^(.{$n})//) {
        return;
      }
      my $len_part = $1;
      $len_part =~ s/^0+//g;
      return $len_part;
    },
  ];

}

sub binary_n {

  my $n = shift;
  return [
    sub {
      my $stuff = shift;
      unless(defined $$stuff) {
        cluck "enc error";
        return;
      }

      my $len_part = sprintf("%04d", length $$stuff);
      $$stuff   = $len_part . $$stuff;
      return;
    },

    sub {
      my $stuff = shift;
      unless(defined $$stuff) {
        cluck "dec error";
        return;
      }

      unless ($$stuff  =~ s/^(.{$n})//) {
        return;
      }
      my $len_part = $1;
      $len_part =~ s/^0+//g;
      return $len_part;
    },
  ];

}


sub bcd_n {

  my $n = shift;

  return [
    sub {
      my $stuff = shift;
      unless(defined $$stuff) {
        cluck "enc error";
        return;
      }

      my $len_part = num2bcd(length $$stuff);
      $$stuff   = $len_part . $$stuff;
      return;
    },

    sub {
      my $stuff = shift;
      unless(defined $$stuff) {
        cluck "dec error";
        return;
      }

      unless ($$stuff  =~ s/^(.{$n})//) {
        return;
      }
      my $len_part = $1;
      $len_part =~ s/^0+//g;
      return $len_part;
    },
  ];

}

1;

__END__

