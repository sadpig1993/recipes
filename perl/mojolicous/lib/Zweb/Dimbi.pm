package Zweb::Dimbi;

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
    my $id = $self->param('id');

    if ( defined $id ) {
        $pager = $self->db_txn->select_page(
            'dim_bi',
            [ "id", "type", "name", "memo" ],
            { id => $id },
            ['id asc'],
            [ "id", "type", "name", "memo" ],
            { cur_page => $index, page_size => 8 },
            { sth      => 1 }
        );
    }
    else {
        $pager = $self->db_txn->select_page(
            'dim_bi',
            [ "id", "type", "name", "memo" ],
            undef,
            ['id asc'],
            [ "id", "type", "name", "memo" ],
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

    my $id   = $self->param("id");
    my $name = $self->param("name");
    my $type = $self->param("type");
    my $memo = $self->param("memo");

    #    Data::Dump->dump( $id, $name, $memo );

    my $sql =
        'insert into dim_bi(id, type, name, memo) values (\'' 
      . $id 
      . '\', \''
      . $type
      . '\', \''
      . $name
      . '\', \''
      . $memo . '\')';

    #warn "$sql";

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
    $self->redirect_to('/dimbi/index');

}

##########################
# edit dimbi for modify
##########################
sub edit {
    my $self = shift;
    my $id   = $self->param("id");

    #Data::Dump->dump("id is $id");
    my $data;
    my $dimbi_data = $self->db_txn->select( 'dim_bi', { id => $id } );
    $self->decode_ch($dimbi_data);
    $data->{dimbi_data} = $dimbi_data;

    #    Data::Dump->dump( $data->{dimbi_data} );
    $self->stash( 'pd', $data );
}

sub submit {
    my $self = shift;
    my $data;
    my $id   = $self->param("id");
    my $type = $self->param("type");
    my $name = $self->param("name");
    my $memo = $self->param("memo");

    #    Data::Dump->dump( $id, $type, $name, $memo );

    my $sql =
        "update dim_bi set name=\'" 
      . $name
      . "\', type=\'$type"
      . "\',  memo=\'"
      . $memo . "\'"
      . " where id=\'"
      . $id . "\'";

    #warn "$sql";

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
    $self->redirect_to('/dimbi/index');

}

sub delete {
    my $self = shift;
    my $data;
    my $id = $self->param("id");

    #    Data::Dump->dump("delte id $id");

    # begin work
    $self->db_txn->begin_work;

    # delete the data from tbl_user_inf
    my $sql = "delete from dim_bi where id = '$id'";

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
    $self->redirect_to('/dimbi/index');

}

##########################################
# the json method to comfirm DIM_BI info
##########################################
sub check {

    my $self = shift;
    my $ID   = $self->param('id');

    #  Data::Dump->dump("===check.json=== $ID");
    my $key = $self->db_txn->select_fld( 'dim_bi', ['id'], { id => $ID } ) || 0;
    return $self->render_json( { 'result' => $key } );
}

1;

