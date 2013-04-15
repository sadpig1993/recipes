#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use IO::File;
use IO::Dir;

## 创建file handler
my $fh;
##	创建db handler 连接数据库
my $dbh = DBI->connect( 'dbi:DB2:zdb_dev', 'ypinst', 'ypinst', );

unless ($dbh) {
    exit 0;
}

my $sth = $dbh->prepare("select * from source_jsck");
unless ($sth) {
    warn "can not prepare source_jsck";
    exit 0;
}

############生成结算出款数据############
my $narray = $sth->{NAME};
my @dim = join "|", map { lc } @$narray;

##取出创建目录的时间
$sth = $dbh->prepare("select * from source_jsck where c_out_type = '1'");
$sth->execute;
########mkdir begin#########
while ( my $row = $sth->fetchrow_arrayref ) {
    my $filepath = join( "", split( "-", ( substr $row->[9], 0, 10 ) ) );

    #print "$filepath\n";
    if ( -d $filepath ) {
        chdir($filepath);
        $fh = IO::File->new( ">>$filepath" . "_jsck.dat" );

        chdir("..");
    }
    else {
        mkdir "$filepath";
        chdir($filepath);
        $fh = IO::File->new( ">>$filepath" . "_jsck.dat" );
        chdir("..");
    }
}
########mkdir end#########
    #打印字段的表头
    $fh->print(<<EOF);
@dim
EOF

$sth->execute;
while ( my $row = $sth->fetchrow_arrayref ) {
	####array slice
	$fh->print (join '|',@{$row},"\n") ;

}
##释放$sth占用的资源
$sth->finish();

##	生成结算委托的数据
my $fh1;
$sth   = $dbh->prepare("select * from source_jsck where c_out_type = '2' ");
#$nhash = $sth->{NAME_hash};
$sth->execute;

######################mkdir###############################
while ( my $row = $sth->fetchrow_arrayref ) {
    my $filepath = join( "", split( "-", ( substr $row->[9], 0, 10 ) ) );

    #print "$filepath\n";
    if ( -d $filepath ) {
        chdir($filepath);
        $fh1 = IO::File->new( ">>$filepath" . "_xswt.dat" );

        chdir("..");
    }
    else {
        mkdir "$filepath";
        chdir($filepath);
        $fh1 = IO::File->new( ">>$filepath" . "_xswt.dat" );
        chdir("..");
    }
}
#######################mkdir_end###########################
$fh1->print(<<EOF);
@dim
EOF

$sth->execute;
while ( my $row = $sth->fetchrow_hashref() ) {
    my @fld_name =
      qw/C_MERCHANT_NO C_OUT_SERIALNO C_OUT_TYPE F_OUT_BALANCE F_INCOME_BALANCE C_BANK_NO D_BANK_CONFIRM_DATE F_INNER_BANK_BALANCE F_OUTER_BANK_BALANCE D_CREATE_DATE/;
    $fh1->print( join '|', @{$row}{@fld_name}, "\n" );
}

##释放$sth占用的资源
$sth->finish();
##断开与数据库的连接
$dbh->disconnect();
##关闭文件IO
$fh->close();
$fh1->close();

