package Zweb::Bip;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use DateTime;
use Encode qw/encode decode/;

################################
# show bip list
################################
sub index {
    my $self = shift;
    my $data;
    my @records;
    my $where;
    my $index = $self->param('index') || 1;
    my $id = $self->param('bid');
    if ($id) {
        $where = { id => $id };
    }
    else {
        $where = undef;
    }

    my $pager = $self->db_txn->select_page(
        'bip',
        [
            "id",        "bi",          "begin",      "end",
            "bjhf_acct", "bjhf_period", "bjhf_delay", "bjhf_nwd",
            "round",     "disable",     "memo",       "oper_id",
            "ts_c",      "ts_u"
        ],
        $where,
        ['id'],
        [
            "id",        "bi",          "begin",      "end",
            "bjhf_acct", "bjhf_period", "bjhf_delay", "bjhf_nwd",
            "round",     "disable",     "memo",       "oper_id",
            "ts_c",      "ts_u"
        ],
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

################################
# add a new bip
################################
sub add {
    my $self = shift;
    my $data;
    my $id          = $self->param('id');
    my $bi          = $self->param('bi');
    my $begin       = $self->param('begin');
    my $end         = $self->param('end');
    my $bjhf_acct   = $self->param('bjhf_acct');
    my $bjhf_period = $self->param('bjhf_period');
    my $bjhf_delay  = $self->param('bjhf_delay');
    my $bjhf_nwd    = $self->param('bjhf_nwd');
    my $round       = $self->param('round');
    my $disable     = $self->param('disable');
    my $memo        = $self->param('memo');
    my $oper_id     = $self->param('oper_id');
    my $ts_u        = $self->param('ts_u');
    my @limits      = $self->param('limits');
    my $dt          = DateTime->now( time_zone => 'local' );
    my $oper_date   = $dt->ymd('');
    my $oper_staff  = $self->session->{uid};

    my $rid = $self->db_txn->select_fld( 'bip', ['id'], { bi => $bi } );

    if ($rid) {
        $data->{result} = 0;
        $self->stash( 'pd', $data );
        return;
    }

    # begin work
    $self->db_txn->begin_work;

    my $role_sql =
"insert into bip (id, bi, begin, end, bjhf_acct, bjhf_period, bjhf_delay, bjhf_nwd, round,disable,memo,oper_id,ts_u) values ($id, $bi, '$begin','$end', $bjhf_acct, '$bjhf_period', $bjhf_delay, '$bjhf_nwd', '$round','$disable','$memo','$oper_id','$ts_u')";

    $self->db_txn->dbh->do($role_sql);

    # commit
    $self->db_txn->commit;
    $self->redirect_to('/bip/index');
}

################################
# the json method to comfir the bip id
################################
sub check {
    my $self = shift;
    my $id   = $self->param('id');
    my $key  = $self->db_txn->select_fld( 'bip', ['id'], { id => $id } )
      || 0;
    $self->render_json( { result => $key } );
}

################################
# delete a bip
################################
sub delete {
    my $self = shift;
    my $data;

    # begin work
    $self->db_txn->begin_work;
    my $role_id = $self->param('id');

    my $sql = "delete from bip where id = \'$role_id\'";

    #    $self->db_txn->dbh->do( encode( 'euc-cn', $sql ) );
    $self->db_txn->dbh->do($sql);

    # error handle
    my $err_code = $self->db_txn->dberr;
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    # commit
    $self->db_txn->commit;
    $self->redirect_to('/bip/index');
}

################################
# edit a bip for modify
################################
sub edit {
    my $self = shift;

    #bi对应index.html.eq中的值
    my $role_id = $self->param('id');
    my $data;
    my $role_data = $self->db_txn->select( 'bip', { id => $role_id } );
    $self->decode_ch($role_data);
    $data->{role_data} = $role_data;
    $self->stash( 'pd', $data );
}

################################
# update bip information
###############################
sub submit {
    my $self = shift;
    my $data;
    my $id          = $self->param('id');
    my $bi          = $self->param('bi');
    my $begin       = $self->param('begin');
    my $end         = $self->param('end');
    my $bjhf_acct   = $self->param('bjhf_acct');
    my $bjhf_period = $self->param('bjhf_period');
    my $bjhf_delay  = $self->param('bjhf_delay');
    my $bjhf_nwd    = $self->param('bjhf_nwd');
    my $round       = $self->param('round');
    my $disable     = $self->param('disable');
    my $memo        = $self->param('memo');
    my $oper_id     = $self->param('oper_id');
    my $ts_u        = $self->param('ts_u');
    $self->db_txn->begin_work;

    my $role_sql =
"update bip set bi=$bi, begin='$begin', end='$end', bjhf_acct=$bjhf_acct, bjhf_period='$bjhf_period', bjhf_delay=$bjhf_delay, bjhf_nwd='$bjhf_nwd', round='$round',disable='$disable',memo='$memo',oper_id='$oper_id',ts_u='$ts_u'  where id=$id";

    #    $self->db_txn->dbh->do( encode( 'euc-cn', $role_sql ) );
    $self->db_txn->dbh->do($role_sql);

    # error handle
    my $err_code = $self->db_txn->dberr;
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    $self->db_txn->commit;
    $self->redirect_to('/bip/index');
}

1;
