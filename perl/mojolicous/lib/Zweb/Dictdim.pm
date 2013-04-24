package Zweb::Dictdim;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use DateTime;
use Encode qw/encode decode/;

################################
# show dictdim list
################################
sub index {
    my $self = shift;
    my $data;
    my @records;
    my $where;
    my $index = $self->param('index') || 1;
    my $dim = $self->param('dim');
    if ($dim) {
        $where = { dim => $dim };
    }
    else {
        $where = undef;
    }
    my $pager = $self->db_txn->select_page(
        'dict_dim',
        [ "dim", "name", "memo", "ts_c" ],
        $where,
        ['dim'],
        [ "dim", "name", "memo", "ts_c" ],
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
# add a new dictdim
################################
sub add {
    my $self = shift;
    my $data;
    my $dim        = $self->param('dim');
    my $name       = $self->param('name');
    my $memo       = $self->param('memo');
    my @limits     = $self->param('limits');
    my $dt         = DateTime->now( time_zone => 'local' );
    my $oper_date  = $dt->ymd('');
    my $oper_staff = $self->session->{uid};

    my $rid = $self->db_txn->select_fld(
        'dict_dim', ['dim'],

        # { name => encode('euc-cn',$name)} );
        { name => $name }
    );

    if ($rid) {
        $data->{result} = 0;
        $self->stash( 'pd', $data );
        return;
    }

    # begin work
    $self->db_txn->begin_work;

    my $role_sql =
      "insert into dict_dim(dim,name,memo) values ('$dim','$name','$memo')";

    #$self->db_txn->dbh->do( encode( 'euc-cn', $role_sql ) );
    $self->db_txn->dbh->do($role_sql);

    # commit
    $self->db_txn->commit;
    $self->redirect_to('/dictdim/index');
}

################################
# the json method to comfir the dictdim name
################################
sub check {
    my $self = shift;
    my $dim  = $self->param('dim');
    my $key  = $self->db_txn->select_fld( 'dict_dim', ['dim'], { dim => $dim } )
      || 0;
    $self->render_json( { result => $key } );
}

################################
# delete a dictdim
################################
sub delete {
    my $self = shift;
    my $data;

    # begin work
    $self->db_txn->begin_work;
    my $role_dim = $self->param('dim');

    my $sql = "delete from dict_dim where dim = \'$role_dim\'";

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
    $self->redirect_to('/dictdim/index');
}

################################
# edit a dictdim for modify
################################
sub edit {
    my $self = shift;

    #bi对应index.html.eq中的值
    my $role_dim = $self->param('dim');
    my $data;
    my $role_data = $self->db_txn->select( 'dict_dim', { dim => $role_dim } );
    $self->decode_ch($role_data);
    $data->{role_data} = $role_data;
    $self->stash( 'pd', $data );
}

################################
# update dictdim information
###############################
sub submit {
    my $self = shift;
    my $data;

    # begin work
    my $dim  = $self->param('dim');
    my $name = $self->param('name');
    my $memo = $self->param('memo');
    $self->db_txn->begin_work;
    my $role_sql =
      "update dict_dim set name='$name',memo='$memo' where dim='$dim'";

    #$self->db_txn->dbh->do( encode( 'euc-cn', $role_sql ) );
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
    $self->redirect_to('/dictdim/index');
}

1;
