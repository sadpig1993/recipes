package Util::HSM::Soft;
use strict;
use warnings;
use Data::Dump;
use Crypt::DES;
use Crypt::ECB;
use Carp qw/cluck/;
use Data::Dump;
use Util::IniParse qw/ini_parse/;

#########################################################
#  usage: Util::Soft->new("/path/of/config/key.ini");
#--------------------------------------------------------
#  conf ini format
#--------------------------------------------------------
#  [mk]
#      key  = FFFFFFFFFFFFFFFF
#  [mmk]
#      0001 = FFFFFFFFFFFFFFFF
#      0002 = FFFFFFFFFFFFFFFF
#      0003 = FFFFFFFFFFFFFFFF
#########################################################
sub new {
    my $class = shift;
    my $cfg   = shift;

    unless($cfg) {
        cluck "config file must be provided";
        return;
    }

    unless( -f $cfg) {
        cluck "file $cfg does not exist";
        return;
    }

    my $data = ini_parse($cfg);
    unless($data) {
        cluck "can not parse file[$cfg]";
        return;
    }

    #  check validitiy
    for my $idx (keys %{$data->{mmk}}) {
       my $key = $data->{mmk}->{$idx};
       my $len = length $key;
       unless($len == 16 ) {
           cluck "key $key invalid length[$len]";
           return;
       }
       if ($key =~ /[^0-9A-Fa-f]/) {
           cluck "key $key, error[contains non-hex character]";
           return;
       }
       my $kraw = pack('H16', $key);
       $data->{mmk}->{$idx} = $kraw;
    } 

    bless $data, $class;

}

#
#
# mak      => 'hex-FFFFFFFFFFFFFFF',  
# kid      => $kid,
# macblock => "1234567812346578aaa",  
#-------------------------------------------
# type is  ANSI-X9.9-mac DES CBC
# ascii,not hex,length not fix
#
sub gen_mac_ansix99 {

    my $self  =  shift;
    my $args  =  {@_};

    # check validity
    unless( length $args->{mak}  == 16 ) {
        cluck "invalid mak[$args->{mak}]";
        return;
    }
    my $mak_raw = pack("H16", $args->{mak});
    my $mab_len = length $args->{macblock};
    unless($mab_len % 8 == 0 ) {
        cluck "invalid macblock, length[$mab_len]";
        return;
    }

    #  get plain mak
    my $kid_cipher  = new Crypt::DES $self->{mmk}->{$args->{kid}} or die "can't init DES";
    my $mak_org = $kid_cipher->decrypt($mak_raw);

    # get macblock array
    my $cnt = length $args->{macblock} / 8;
    my @blockarr = unpack('A8' x $cnt, $args->{macblock});

    # get mak cihper
    my $mak_cipher = new Crypt::DES $mak_org;

    # begin cbc...
    my $cur = "\x00" x 8;
    my $xor;
    for (@blockarr) {
        $xor  = $cur ^ "$_" ;
        $cur   = $mak_cipher->encrypt($xor);
    }
    return unpack('H16', $cur);
}

#----------------------------------
#  macblock => "134567980aaaaaaa" 
#  mak      => "1234567890123456" 
#  kid      => '0001'
#  mac      => 'FFFFFFFF'
#----------------------------------
sub ver_mac_anix99 {
    my $self = shift;
    my $args = {@_};

    # 计算mac
    my $mac  = $self->gen_mac_ansix99(@_);

    # 比较mac
    return $mac == $args->{mac} ? $self : undef;
}

#
# pik      => "cf03b2dbfb7181e8" # work pin key, hex, 8bytes
# tmk      => "终端主密钥明文"
# pinblock => "binary"
#
# 返回值:  8字节的pin密文 
#
sub encrypt_pin_term {

    my $self = shift;
    my $args = {@_};

    #
    # validity check
    my $pb_len = length $args->{pinblock};
    unless ( $pb_len == 8 ) {
        cluck "pinblock invalid, length[$pb_len]";
        return;
    }

    my $tmk_len = length $args->{tmk};
    unless ( $tmk_len == 8 ) {
        cluck "tmk invalid, length[$tmk_len]";
        return;
    }

    my $pik_len =  length $args->{pik};
    unless ( $pik_len == 8 ) {
        cluck "pik invalid, length[$pik_len]";
        return;
    }

    #  TMK cipher
    my $tmk_cipher = Crypt::DES->new($args->{tmk});

    #  get plain pik
    my $pik_org    = $tmk_cipher->decrypt(pack( "H16", $args->{pik} ));

    #  PIK cipher
    my $pik_cipher = Crypt::DES->new($pik_org);

    #  encrypt pinblock
    return $pik_cihper->encrypt(pack( "H16", $args->{pinblock}));
}

#
# kid_in    => "0001"                # key of index from key file
# pik_in    => "1234567890123456"    # work key, len 16,hex eq 8bytes
# kid_out   => "0002"                #
# pik_out   => "1234567890123456"    #
# pinblock  => "\x06\x12\x34\x56\xFF"
#
sub tran_pin_i2i {

    my $self = shift;
    my $args = {@_};

    #  validity check
    my $pik_in  = pack("H16", $args->{kid_id});
    my $pik_out = pack("H16", $args->{kid_out});

    # get plain pik_in, pik_out
    my $pik_in_org  = Crypt::DES->new(pack("H16", $self->{mmk}->{$kid_in}))->decrypt($pik_in);
    my $pik_out_org = Crypt::DES->new(pack("H16", $self->{mmk}->{$kid_out}))->decrypt($pik_out);

    # decrypt pinblock  and encrypt it
    return Crypt::DES->new($pik_out_org)
                     ->encrypt(
                               Crypt::DES->new($pik_in_org)
                                         ->decrypt($args->{pinblock}
                     );
}


#
# kid_tmk   => '0001',
# tmk       => 'FFFFFFFFFFFFFFFF',
# pik_term  => "1234567890123456"    # work key, len 16,hex eq 8bytes
# kid_out   => "0002"                #
# pik_out   => "1234567890123456"    #
# pinblock  => "\x06\x12\x34\x56\xFF"
#
sub tran_pin_t2i {
   my $self = shift;
    my $args = {@_};

    #  validity check


    # 取得pinblock明文
    my $pinblock_plain = Crypt::DES->new(
                              Crypt::DES->new(
                                   Crypt::DES->new($self->{mmk}->{$args->{kid_tmk}})    
                                             ->decrypt($args->{tmk}))   # decrypt 得到tmk明文
                                        ->decrypt($args->{pik_term}))   # decrypt 得到pik_term的明文
                                   ->decrypt($args->{pinblock});        # decrypt 得到pinblock明文

    # 生成目标机构pinblock密文
    return Crypt::DES->new(
               Crypt::DES->new($self->{mmk}->{$args->{kid_out}})
                         ->decrypt($args->{pik_out}))    # decrypt 得到目标机构pik明文
                     ->encrypt($pinblock_plain);         # encrypt 得到目标机构pik密文

}


#
#  pin => "123456",
#  pan => "1234657890123456"   # 如果传了pan, 就是带主账号的pinblock
#
sub pin_block {
    my $self = shift;
    my $args = { @_ };

    #
    # pin组成格式:
    # 1个字节长度  + BCD pin +  右补充FF
    #
    $pin = pack("H2", sprintf( "%02d", length($args->{pin}))) .  pack('H*', $args->{pin});
    $pin = $pin . ( "\xFF" x ( 8 - length $pin ) );

    # 不带主账号
    unless ($args->{pan})
        return $pin;
    }

    #
    # 带主账号的pinblock, 
    # panblock组成规则
    # 除掉pan最后一位
    #
    my $pan = $args->{pan};
    $pan =~ s/.$//;
    if ( $args->{pan} =~ /(.{12})$/ ) {
        $pan = $1;
    }
    else {
       my $len = length $pan;
    }
    return $pin ^ $pan;

}

1;

