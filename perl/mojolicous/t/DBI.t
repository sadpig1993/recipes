#! /usr/bin/perl

use strict;
use warnings;

use Util::DBI;
use Data::Dump;


my $dbi = Util::DBI->new(qw/dsn dbi:DB2:zdb_dev dbuser ypinst dbpass ypinst schema ypinst/);
#my $dbh = $dbi->select_fld('tbl_role_route_map', ['route_id'], {role_id => 1}, {sth => 1});

#my $dbh = $dbi->select_page('tbl_role_inf', ["role_id", "role_name", "remark"], undef, ['role_id desc'], ["role_id", "role_name", "remark"], {cur_page => 2, page_size => 1 }, {sth => 1});
#while(my $row = $dbh->{sth}->fetchrow_hashref) {
#    Data::Dump->dump($row);
#}
#my $cnt = $dbh->{cnt}->fetchrow_arrayref->[0];
#Data::Dump->dump($cnt);
#$dbh->{sth}->finish;
#$dbh->{cnt}->finish;

#my $data = $dbi->select_sql('select route_id, route_name, parent_id, view_order, remark from tbl_route_inf order by route_id', undef);
my $data = $dbi->select_fld('tbl_role_route_map', ['count(*)'], {role_id => 1});
Data::Dump->dump($data);
$dbi->disconnect;
