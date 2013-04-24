package Util::DB::Sync::Filter::History;

use strict;
use warnings;

use IO::Socket::INET;

################################
#  argstr  => tbl_txn_log_his
#  sync    => Util::DB::Sync对象   
################################
sub new {

  my $class = shift;
  my $arg = { @_ };

  my $sync    = $arg->{sync};

  my $self = bless { job  => $sync->{job}, 
                     ddb  => $sync->{ddb},
                     log  => $sync->{log}, 
                     his  => $arg->{argstr} }, $class;
  #
  #  目的库对象增加历史表的插入操作 
  #
  my $sql_insert = $self->{ddb}->sql('tbl_txn_log_bke_a', 'insert');
  my $sql_update = $self->{ddb}->sql('tbl_txn_log_bke_a', 'update');

  $sql_insert =~ s/tbl_txn_log_bke_a/tbl_txn_log_his/g;
  $sql_update =~ s/tbl_txn_log_bke_a/tbl_txn_log_his/g;

  unless ( $self->{ddb}->add_config_sql(
    'tbl_txn_log_his'  =>  {
      insert  =>  $sql_insert,
      update  =>  $sql_update,
    }
  )) {
    $self->{log}->error("can not add config");
    return undef;
  }

  return $self;
}

#
# 记录插入历史表  
#
sub handle {

  my $self = shift;
  my $row  = shift;   # [ ]

  $self->{ddb}->execute('tbl_txn_log_his', 'insert', @$row);
  my $sqlcode = $self->{ddb}->sqlcode();
  if ($sqlcode && $sqlcode =~ /^-803/) {
    my $j = $self->{job};
    $self->{ddb}->execute('tbl_txn_log_his', 'update', @{$row}[@{$j->{updt}}], @{$row}[@{$j->{primary}}]);
  }
  return $row;

}

1;

