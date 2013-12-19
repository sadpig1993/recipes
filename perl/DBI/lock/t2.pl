#!/usr/bin/env perl

use strict;
use warnings;

use DBI;
use Data::Dump;
use Carp;

# connect to db

my $cfg = {
    dsn => "dbi:DB2:$ENV{DB_NAME}",

    #dsn    => "dbi:DB2:zdb_test",
    user   => "$ENV{DB_USER}",
    pass   => "$ENV{DB_PASS}",
    schema => "$ENV{DB_SCHEMA}",
};

Data::Dump->dump( @{$cfg}{qw/dsn user pass/} );

my $dbh1 = DBI->connect(
    @{$cfg}{qw/dsn user pass/},
    {
        AutoCommit => 0,    #默认属性是on , 此处关闭
        PrintError => 1,    #
        RaiseError => 1,    #
        FetchHashKeyName => 'NAME_lc',
        ChopBlanks => 1,
    }
);

if ($dbh1) {
    warn "connect to db this is 1st dbh \n";
}
else {
    warn "cannot connect 1st dbh $DBI::errstr\n";
}

my $sth = $dbh1->prepare("select * from job_dz where id = 1 with rs for update");
#     0    1    2      3     4    5     
my ($sec,$min,$hour, $mday, $mon,$year) = (localtime(time))[ 0, 1, 2, 3, 4, 5 ];
my $date = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900 , $mon + 1 , $mday, $hour, $min, $sec);
print $date . "\n";
unless ($sth->execute()) {
    confess "ERROR: $@";    
}


while( my $row = $sth->fetchrow_hashref() ) {
    print $row->{id} . $row->{type} . "\n";
}
$dbh1->commit();
if($@) {
    confess "ERROR: $@";    
}

my $rv = $dbh1->disconnect();
warn "the return value of succeed disconnect is :$rv";

exit;

