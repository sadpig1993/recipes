package Zweb::Ypos;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Digest::MD5;
use Util::Pack::JSON;
use IO::Socket::INET;

sub list {
    my $self = shift;
    my $data;
    my @records;

    my $index = $self->param('index') || 1;
    my $pager = $self->db_txn->select_page(
        'tbl_key_ypos',
        [ "mid", "tid", "pik", "mak", "bcode", "mcc", "rec_upd_ts" ],
        undef,
        [ 'mid desc', 'tid desc' ],
        undef,
        { cur_page => $index, page_size => 10 },
        { sth      => 1 }
    );
    $data->{count} = $pager->{cnt}->fetchrow_arrayref->[0];
    while ( my $row = $pager->{sth}->fetchrow_hashref() ) {
        $self->decode_ch($row);
        push @records, $row;
    }
    $pager->{cnt}->finish;
    $pager->{sth}->finish;
    $data->{data} = \@records;
    my $cal_data = $self->cal_page(
        total => $data->{count},
        size  => 10,
        index => $index,
    );
    $data->{index}      = $index;
    $data->{total_page} = $cal_data->{total_page} || 1;
    $data->{prev_page}  = $cal_data->{prev_page} || 1;
    $data->{next_page}  = $cal_data->{next_page} || 1;
    $self->stash( 'pd' => $data );
}

sub signin {
    my $self = shift;
    my $mid  = $self->param('mid');
    my $tid  = $self->param('tid');

    my $req = {
        tcode => 'ypos.si',
        mid   => $mid,
        tid   => $tid,
    };
    my $pack   = Util::Pack::JSON->new();
    my $packet = $pack->pack($req);
    my $len    = sprintf( "%04d", length $packet );
    $req = $len . $packet;
    my $svr = IO::Socket::INET->new("127.0.0.1:9191");
    syswrite( $svr, $req, $len + 4 );

    sysread( $svr, $len, 4 );
    $len =~ s/^0+//g;
    sysread( $svr, $req, $len );
    my $res = $pack->unpack($req);

    $self->redirect_to('/ypos/list');
}

sub monitoring {
    my $self = shift;
    my $data;
    my @records;

    my $pager = $self->db_txn->select_page(
        'tbl_log_txn',
        [qw/id step c_amt i_tcode i_name i_resp tcode_1 name_1 resp_1/],
        undef,
        ['id desc'],
        undef,
        { cur_page => 1, page_size => 10 },
        { sth      => 1 }
    );
    while ( my $row = $pager->{sth}->fetchrow_hashref() ) {
        push @records, $row;
    }
    $pager->{cnt}->finish;
    $pager->{sth}->finish;
    my $total = $self->db_txn->select_fld( 'tbl_log_txn', ['count(*)'], undef );
    my $fin =
      $self->db_txn->select_fld( 'tbl_log_txn', ['count(*)'], { step => 'f' } );
    my $unfin = $self->db_txn->select_sql(
'select count(*) from tbl_log_txn where step <> \'f\' and step <> \'0\'',
        undef
    );
    $data->{data}    = \@records;
    $data->{fin}     = $fin->{1};
    $data->{unfin}   = $unfin->[0]->{1};
    $data->{total}   = $total->{1};
    $data->{unusual} = $data->{total} - $data->{fin} - $data->{unfin};
    $self->stash( 'pd' => $data );
}

sub index {
    my $self = shift;
    my $data;
    my $fld = $self->param('fld');
    unless ($fld) {
        $data->{head} = [
            qw/id tdate c_pan c_amt
              i_name i_tcode i_resp i_ssn i_date i_time i_mcc i_mid i_tid i_auth_code
              i_ref_id rev_id rev_flag can_id can_flag name_1 tcode_1 tkey_1 resp_1 mid_1
              tid_1 tbn_1 tsn_1 stlm_date_1 ref_id_1 auth_code_1 rec_upd_ts/
        ];
        $fld = ['*'];
    }
    else {
        $data->{head} = $fld;
    }
    my $sql = "select " . join ",", @$fld . " from tbl_log_bdbp";
    $data->{data} = $self->db_txn->select_sql( $sql, undef );
    $self->stash( 'pd' => $data );
}

1;
