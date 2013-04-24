package Util::DB::Sync::Cut;

use strict;
use warnings;

sub new {

  my $class = shift;
  my $sdb   = shift;

  my $self = bless {
    tbl_map => {
      #'tbl_txn_log_a'  =>  'tbl_txn_log_a_bke',
      #'tbl_txn_log_b'  =>  'tbl_txn_log_b_bke',

      'tbl_txn_log_bke_a'  =>  'tbl_txn_log_a',
      'tbl_txn_log_bke_b'  =>  'tbl_txn_log_b',
    },
    sdb => $sdb,
  }, $class;

  return $self;
}


###################################
# select_cut   = select \
#    cur_txn_tbl   as cur_table, \
#    bf_txn_tbl    as bef_table, \
#    bf_stlm_date  as bef_date, \
#    cur_stlm_date as cur_date, \
#    rec_upd_ts    as cut_time \
# from \
#    tbl_bat_cut_ctl
###################################
sub load {

  my $self = shift;
  my $sdb  = $self->{sdb};

  my $sth = $sdb->execute('tbl_dbsync_ctl', 'select_cut') or return undef;
  my $bci = $sth->fetchrow_hashref();
  return undef unless $bci;

  $bci->{BEF_TABLE} = "tbl_txn_log_bke_" . lc $bci->{BEF_TABLE};
  $bci->{CUR_TABLE} = "tbl_txn_log_bke_" . lc $bci->{CUR_TABLE};

  return $bci;
}

sub destination {

  my $self = shift;
  my $src  = shift;
  return $self->{tbl_map}->{$src};

}

1;

