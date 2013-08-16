#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Data::Dump;

my $cfg = {
    dsn    => "dbi:DB2:$ENV{DB_NAME}",
    user   => "$ENV{DB_USER}",
    pass   => "$ENV{DB_PASS}",
    schema => "$ENV{DB_SCHEMA}",
};

# Data::Dump->dump($cfg);

# 建立数据库连接
# 创建database handle object dbh
my $dbh = DBI->connect(
    $cfg->{dsn},
    $cfg->{user},
    $cfg->{pass},
    {
        RaiseError       => 1,
        PrintError       => 0,
        AutoCommit       => 0,
        FetchHashKeyName => 'NAME_lc',

    }
);

# Data::Dump->dump( $dbh ) ;
my %attr;

# SQL
my $sql = "select id,value  from dict_book";

# 创建statement handle object (sth)
my $sth_sel = $dbh->prepare( $sql, \%attr ) or die $dbh->errstr ;  

# SQL 语句结束
$sth_sel->finish();

# 执行SQL
$sth_sel->execute();

# fetch 数据
my $aref = $sth_sel->fetchall_arrayref();
foreach my $row (@$aref) {
    print " ID: $row->[0]\t Name: $row->[1]\n";
}

$dbh->commit();
$dbh->disconnect;
