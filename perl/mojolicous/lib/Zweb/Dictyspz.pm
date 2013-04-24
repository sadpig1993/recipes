package Zweb::Dictyspz;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Encode qw/encode decode/;
use Data::Dump;
use DateTime;

################################
# show index list
################################
sub index {
    my $self = shift;
    my $data;
    my @records;
    my $pager;

    my $index = $self->param('index') || 1;
    my $code = $self->param("code");

    #    Data::Dump->dump($code);
    if ( defined $code ) {

        $pager = $self->db_txn->select_page(
            'dict_yspz',
            [ "code", "name", "memo" ],
            { code => $code },
            ['code asc'],
            [ "code", "name", "memo" ],
            { cur_page => $index, page_size => 8 },
            { sth      => 1 }
        );
    }
    else {
        $pager = $self->db_txn->select_page(
            'dict_yspz',
            [ "code", "name", "memo" ],
            undef,
            ['code asc'],
            [ "code", "name", "memo" ],
            { cur_page => $index, page_size => 8 },
            { sth      => 1 }
        );

    }

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
        size  => 8,
        index => $index,
    );
    $data->{index}      = $index;
    $data->{total_page} = $cal_data->{total_page} || 1;
    $data->{prev_page}  = $cal_data->{prev_page} || 1;
    $data->{next_page}  = $cal_data->{next_page} || 1;
    $self->stash( 'pd' => $data );

}

################################
# add dim_p data
################################
sub add {
    my $self = shift;
    my $data;
    my @record;

    my $code = $self->param("code");
    my $name = $self->param("name");
    my $memo = $self->param("memo");

    #    Data::Dump->dump( $code, $name, $memo );

    my $sql =
        'insert into dict_yspz (code, name, memo) values (\'' 
      . $code 
      . '\', \''
      . $name
      . '\', \''
      . $memo . '\')';

    warn "$sql";

    #$self->db_txn->dbh->do( encode( 'euc-cn', $acct_sql ) );
    $self->db_txn->dbh->do($sql);

    # error handle
    my $err_code = $self->db_txn->dberr;

    #warn "$err_code";
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    # commit
    $self->db_txn->commit;

    #}
    $self->redirect_to('/dictyspz/index');

}

##########################
# edit dictyspz for modify
##########################
sub edit {
    my $self = shift;
    my $id   = $self->param("code");

    #Data::Dump->dump("id is $id");
    my $data;
    my $dictyspz_data = $self->db_txn->select( 'dict_yspz', { code => $id } );
    $self->decode_ch($dictyspz_data);
    $data->{dictyspz_data} = $dictyspz_data;

    #    Data::Dump->dump( $data->{dictyspz_data} );
    $self->stash( 'pd', $data );
}

sub submit {
    my $self = shift;
    my $data;

    my $code = $self->param("code");
    my $name = $self->param("name");
    my $memo = $self->param("memo");

    #    Data::Dump->dump( $code, $name, $memo );

    my $sql =
        "update dict_yspz set name=\'" 
      . $name
      . "\', memo=\'"
      . $memo
      . "\'  where code=\'"
      . $code . "\'";

    warn "$sql";

    #$self->db_txn->dbh->do( encode( 'euc-cn', $acct_sql ) );
    $self->db_txn->dbh->do($sql);

    # error handle
    my $err_code = $self->db_txn->dberr;

    warn "$err_code";
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    # commit
    $self->db_txn->commit;

    #}
    $self->redirect_to('/dictyspz/index');

}

sub delete {
    my $self = shift;
    my $data;
    my $code = $self->param("code");

    #    Data::Dump->dump("delte code $code");

    # begin work
    $self->db_txn->begin_work;

    # delete the data from tbl_user_inf
    my $sql = "delete from dict_yspz where code = '$code'";

    #    Data::Dump->dump($sql);

    #$self->db_txn->dbh->do( encode( 'euc-cn', $sql ) );
    $self->db_txn->dbh->do($sql);

    my $err_code = $self->db_txn->dberr;

    # error handle
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    $self->db_txn->commit;
    $self->redirect_to('/dictyspz/index');

}

################################
# the json method to comfirm user name
################################
sub check {

    my $self = shift;
    my $code = $self->param('code');

    #  Data::Dump->dump("===check.json=== $code");
    my $key =
      $self->db_txn->select_fld( 'dict_yspz', ['code'], { code => $code } )
      || 0;
    return $self->render_json( { 'result' => $key } );
}

1;

