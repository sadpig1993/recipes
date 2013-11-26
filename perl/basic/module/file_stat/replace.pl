#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dump;
use File::stat;
use IO::File;
use Carp;

my $rfh = IO::File->new("<allfiles");
if ($@) {
    confess "cannot open, errmsg is $@\n";
}

while (<$rfh>) {
    chomp;
    my $ofile = $_ ;

    my $lobfile = './lob/' . $_ . '.001.lob';
    # warn "file is $file\n";
    my $st = stat($lobfile) or die "No $lobfile: $!";
    warn "$lobfile size is $st->[7]\n";

    # 先把更改后的数据写到临时文件
    my $nfile = $_ . 'tmp';
    my $wfh = IO::File->new(">$nfile");
    my $rfh1 = IO::File->new("<$ofile");

    while (<$rfh1>) {
       chomp;
       if (/(^.+lob\.0.)(\d+)(\/.+$)/) {
           my $tmp = $1 . $st->[7] . $3;
           print $wfh "$tmp\n"; 
       }
    }
    $rfh1->close();
    $wfh->close();

    print "--------------$nfile\n";
    system("mv $nfile $ofile");
}

$rfh->close();
