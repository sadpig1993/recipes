package Util::Pack::8583;

use strict;
use warnings;

use IO::File;
use Data::Dump;
use Util::Log;
use integer;

use constant  ID_IDX    => 0;
use constant  TYPE_IDX  => 1;
use constant  LEN_IDX   => 2;
use constant  CLASS_IDX => 3;
use constant  LENC_IDX  => 4;
use constant  DENC_IDX  => 5;

#
#  conf  =>  $xxx/conf/tlpos.conf
#
sub new {
    my $self = bless {}, shift;
    $self->_init(@_);
    return $self;
}

#
#  conf  => /path/of/config/file
#
sub _init {

    my $self = shift;
    my $args = { @_ };  
    
    # load the config file
    my $conf_data = [];
    my $fh = IO::File->new("< $args->{conf}");
    unless($fh) {
        warn "config file : $args->{conf} not exist";
        exit;
    }
    while (<$fh>) {
        unless (/^#/) {
            # remove the first empty element
            s/^\s+//;
            my $data = [split /\s+/, $_];
            # store the first 5 elements
            $conf_data->[@{$data}[0]] = [@{$data}[0..5]];
        }
    }
    for (my $i = 0; $i < @$conf_data; ++$i) {
      $_=$conf_data->[$i];
    }
    $fh->close;
    $self->{config} = $conf_data;
    $self->{hdr}    = $args->{hdr};
}

#
#
#
#
#
sub pack {
    
    my $self   = shift;
    my $fld    = shift;
    my @conf   = @{$self->{config}};
        
    my $data;
  
    ######################################
    # bitmap部分 
    ######################################
    
    my @bitmap;
    if (@$fld > 65) {
      @bitmap = (0) x 128;
      $bitmap[0] = 1;
    } else {
      @bitmap = (0) x 64;
    }
    my @fld;
    for (my $i = 1; $i < @$fld; ++$i) {
      my $idx = $i + 1;
      next unless defined $fld->[$idx];
      my $cfg     = $conf[$idx];
      $bitmap[$i] = 1;
      ######################################
      # 固定长度  
      ######################################
      if ($cfg->[CLASS_IDX] =~ /^fix/) {
        
        if ($cfg->[DENC_IDX] =~ /^ascii/) {
          $data .= $fld->[$idx]; 
          next;
        }
  
        if ($cfg->[DENC_IDX] =~ /^bcd/) {
          my $tmp = '0' x ($cfg->[LEN_IDX] - (length $fld->[$idx]));
          if ($cfg->[DENC_IDX] !~ /^bcdl/) {
            $fld->[$idx] = $tmp.$fld->[$idx];
          } else {
            $fld->[$idx] = $fld->[$idx].$tmp;
          }
          $data .= pack('H*', $fld->[$idx]);
          next;
        }
      }
  
      ######################################
      # LLLVAR
      ######################################
      if ($cfg->[CLASS_IDX] =~ /^lllvar/) {
        
        # 长度部分 
        my $dlen;
        if ($cfg->[LENC_IDX] =~ /^bcd/) {
            $dlen = sprintf("%04d", length $fld->[$idx]);
            $dlen = pack("H*", $dlen);
        } else {
            $dlen = sprintf("%03d", length $fld->[$idx]);
        }
        
        $data .= $dlen;

        if ($cfg->[DENC_IDX] =~ /^bcd/) {
          if ((length $fld->[$idx]) % 2){
            if ($cfg->[DENC_IDX] !~ /^bcdl/) {
                $fld->[$idx] = '0'.$fld->[$idx];
            } else {
                $fld->[$idx] = $fld->[$idx].'0';
            }
          }
          $data .= pack('H*', $fld->[$idx]);
          next;
        }
  
        if ($cfg->[DENC_IDX] =~ /^ascii/) {
          $data .= $fld->[$idx]; 
          next;
        }
      }
      
      ######################################
      # LLVAR
      ######################################
      if ($cfg->[CLASS_IDX] =~ /^llvar/) {
  
         # 长度部分
        my $dlen;
        
        if ($cfg->[LENC_IDX] =~ /^bcd/) {
            $dlen = sprintf("%02d", length $fld->[$idx]);
            $dlen = pack("H*", $dlen);
        } else {
            $dlen = sprintf("%02d", length $fld->[$idx]);
        }
        
        $data .= $dlen;
        
        if ($cfg->[LENC_IDX] =~ /^bcd/) {
            $dlen = unpack("H*", $dlen);
        }
        
        if ($cfg->[DENC_IDX] =~ /^bcd/) {
          if ((length $fld->[$idx]) % 2){
            if ($cfg->[DENC_IDX] !~ /^bcdl/) {
              $fld->[$idx] = '0'.$fld->[$idx];
            } else {
              $fld->[$idx] = $fld->[$idx].'0';
            }
          }
          $data .= pack('H*', $fld->[$idx]);
          next;
        }
  
        if ($cfg->[DENC_IDX] =~ /^ascii/) {
          $data .= $fld->[$idx];
          next;
        }
      }
      
      ######################################
      # 十六进制
      ######################################
      if ($cfg->[CLASS_IDX] =~ /^binary/) {
        $fld->[$idx] =~ s/\<HEX\>//g;
        #$fld->[$idx] = pack('H*', $fld->[$idx]);
        $data .= $fld->[$idx];
        next;
      }
  
    }
  
    my $bstr   = join '', @bitmap;
    my $bitmap = pack('b*', $bstr);

    return pack('h*',$fld->[0]).$bitmap.$data;
}

sub unpack {
    
    my $self = shift;
    my $data = shift;
    my $conf = $self->{config};
   
    my @bitmap; 
    
    ########################################
    # 先取2个字节msgtype + 8个字节的bitmap  
    ########################################
    my $mbyte; 
    my $bbyte;
    ($mbyte, $bbyte, $data) = unpack("a2a8a*", $data);
    my $type = unpack('H*', $mbyte);
    push  @bitmap, split '', unpack('B*', $bbyte);
    
    ########################################
    # 再看是否还有另外8字节的bitmap 
    ########################################
    if ($bitmap[0] eq '1') {
      ($bbyte, $data) = unpack("a8a*", $data); 
      push  @bitmap, split '', unpack('B*', $bbyte);
    }

    ########################################
    # 根据bitmap解析报文域  
    ########################################
    my @fld;
    $fld[0] = $type;
    $fld[1] = '<HEX>'.uc unpack('H*', CORE::pack('B*', join '', @bitmap));
    
    my ($fbyte, $lbyte); 
    for (my $i = 1; $i < @bitmap; ++$i ) {
  
      next if $bitmap[$i] eq '0';
      my $idx = $i + 1;
      my $cfg = $conf->[$idx];
      ##################################
      # 定长 
      ##################################
      if ($cfg->[CLASS_IDX] =~ /^fix/) {
  
        my $dlen = $cfg->[LEN_IDX];
        
        # 定长bcd编码  
        if ($cfg->[DENC_IDX] =~ /^bcd/) {
          my $len = $dlen;
          $dlen = ($dlen + 1) / 2;

          ($fbyte, $data) = unpack("a${dlen}a*", $data);
          my $tmp = unpack('H*', $fbyte);
          #warn "data: ", unpack('H*', $fbyte);

          if($cfg->[DENC_IDX] =~ /^bcdl/){
            $tmp =~ /^(.{$len})/;
            $fld[$idx] = $1;
          } else {
            $tmp =~ /(.{$len})$/;
            $fld[$idx] = $1;
          }
          next;
        }
  
        # 定长ASCII编码  
        if ($cfg->[DENC_IDX] =~ /^ascii/) {
          ($fbyte, $data) = unpack("a${dlen}a*", $data);
          #$data =~ s/^(.{$dlen})//g;
          $fld[$idx] = $fbyte;
          next;
        }
      }
  
      ##################################
      # LLLVAR
      ##################################
      if ($cfg->[CLASS_IDX] =~ /^lllvar/) {
  
        # 解开长度部分 
        my $dlen;
        
        if ($cfg->[LENC_IDX] =~ /^bcd/) {
            #$data =~ s/^(.{2})//g;
            ($fbyte, $data) = unpack("a2a*", $data);
            $dlen = unpack("H*", $fbyte);
            #warn "length: ", unpack('H*', $fbyte);
        } else {
            #$data =~ s/^(.{3})//g;
            ($fbyte, $data) = unpack("a3a*", $data);
            $dlen = $fbyte;
        }
        $dlen =~ s/^0+//g;
  
        # 合法性校验:
        if ($dlen > $cfg->[LEN_IDX]) {
            warn 'a error accurred when do : '."$idx $dlen gt $cfg->[LEN_IDX]";
            return undef;
        }
          
        #  LLLVAR BCD
        if ($cfg->[DENC_IDX] =~ /^bcd/) {
  
          # 解数据部分
          my $len = $dlen;
          if ($dlen % 2 ) {
            $dlen += 1;
          }
          $dlen /= 2;
          #$data =~ s/^(.{$dlen})//g;
          ($fbyte, $data) = unpack("a${dlen}a*", $data);
          my $tmp = unpack('H*', $fbyte);
          #warn "data: ", unpack('H*', $fbyte);
          if($cfg->[DENC_IDX] =~ /^bcdl/){
            $tmp =~ /^(.{$len})/;
            $fld[$idx] = $1;
          } else {
            $tmp =~ /(.{$len})$/;
            $fld[$idx] = $1;
          }
          next; 
  
        }
  
        if ($cfg->[DENC_IDX] =~ /^ascii/) {
          # 解数据部分
          #$data =~ s/^(.{$dlen})//g;
          ($fbyte, $data) = unpack("a${dlen}a*", $data);
          #warn "data: ", unpack('H*', $fbyte);
          $fld[$idx] = $fbyte;
          next; 
        }
      }
  
      ##################################
      # LLVAR
      ##################################
      if ($cfg->[CLASS_IDX] =~ /^llvar/) {
        # 解开长度部分 
        my $dlen;
        
        if ($cfg->[LENC_IDX] =~ /^bcd/) {
            #$data =~ s/^(.{1})//g;
            ($fbyte, $data) = unpack("a1a*", $data);
            $dlen = unpack("H*", $fbyte);
            #warn "length: ", unpack('H*', $fbyte);
        } else {
            #$data =~ s/^(.{2})//g;
            ($fbyte, $data) = unpack("a2a*", $data);
            #warn "length: ", unpack('H*', $fbyte);
            $dlen = $fbyte;
        }
        $dlen =~ s/^0+//g;
        unless($dlen){
            $dlen = 0;
        }
        # 合法性校验:
        if ($dlen > ($cfg->[LEN_IDX])) {
            warn "error! when do:$idx $dlen comp $cfg->[LEN_IDX]";
            return undef;
        }
          
        #  LLVAR BCD
        if ($cfg->[DENC_IDX] =~ /^bcd/) {
  
          # 解数据部分
          if ($dlen % 2 ) {
            $dlen += 1;
          }
          $dlen /= 2;
          ($fbyte, $data) = unpack("a${dlen}a*", $data);
          #warn "data: ", unpack('H*', $fbyte);
          #$data =~ s/^(.{$dlen})//g;
          my $tmp = unpack('H*', $fbyte);
          $dlen *= 2;
          if($cfg->[DENC_IDX] =~ /^bcdl/){
            $tmp =~ /^(.{$dlen})/;
            $fld[$idx] = $1;
          } else {
            $tmp =~ /(.{$dlen})$/;
            $fld[$idx] = $1;
          }
          next; 
        }
  
        if ($cfg->[DENC_IDX] =~ /^ascii/) {
            
          # 解数据部分
          ($fbyte, $data) = unpack("a${dlen}a*", $data);
          #warn "data: ", unpack('H*', $fbyte);
          #$data =~ s/^(.{$dlen})//g;
          $fld[$idx] = $fbyte;
          next; 
        }
      }
      
      ##################################
      # 十六进制
      ##################################
      if ($cfg->[CLASS_IDX] =~ /^binary/) {

        my $len = $cfg->[LEN_IDX];
        
        # 定长ASCII编码
        #$data =~ s/^(.{$len})//g;
        ($fbyte, $data) = unpack("a${len}a*", $data);
        #warn "data: ", unpack('H*', $fbyte);
        #$fld[$idx] = unpack('H*', $fbyte);
        $fld[$idx] = $fbyte;
        next;
      }
    }   
    return \@fld; 
}

sub debug_8583 {
    my $self = shift;
    my $fld = shift;
    my $debug_str = "第[".sprintf("%03d", 0)."]域＝[".sprintf("%03d", 4)."][$fld->[0]]\n"."第[".sprintf("%03d", 1)."]域＝[".sprintf("%03d", ((length $fld->[1]) - 5) / 2)."][$fld->[1]]\n";
    my @conf = @{ $self->{config} };
    for (my $i = 2; $i < @$fld; ++$i ) {
        next unless defined $fld->[$i] && defined $conf[ $i ];
        my $tmp = $fld->[$i];
        if ($conf[ $i ] -> [CLASS_IDX] =~ /^binary/){
            $tmp = '<HEX>' . (uc CORE::unpack('H*', $tmp));
        }
        $debug_str .= "第[".sprintf("%03d", $i)."]域＝[".sprintf("%03d", $conf[$i]->[LEN_IDX])."][$tmp]\n";
    }
    return $debug_str;
}


1;

