#!/usr/bin/env perl

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

Data::Dump->dump($cfg);

# 建立数据库连接
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
my $sql = "select * from dim_p";
my $aref = $dbh->selectall_arrayref( $sql, { Slice => {} } );

foreach my $row (@$aref) {
    print " ID: $row->{id}\t Name: $row->{name}\n";
}

$dbh->commit();
$dbh->disconnect;
