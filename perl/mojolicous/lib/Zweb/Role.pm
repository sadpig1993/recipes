package Zweb::Role;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use DateTime;
use Encode qw/encode decode/;

################################
# show role list
################################
sub index {
    my $self = shift;
    my $data;
    my @records;

    my $index = $self->param('index') || 1;

    my $pager = $self->db_txn->select_page(
        'tbl_role_inf',
        [ "role_id", "role_name", "remark" ],
        undef,
        ['role_id desc'],
        [ "role_id", "role_name", "remark" ],
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
# input a new role information
################################
sub input {
    my $self   = shift;
    my $data   = "";
    my $routes = $self->db_txn->select_sql(
'select route_id, route_name, parent_id, view_order, remark from tbl_route_inf order by route_id',
        undef
    );

    # prepare the tree data
    for my $route (@$routes) {
        $self->decode_ch($route);
        my $tmp = ''
          . $route->{route_id} . '|'
          . $route->{parent_id} . '|'
          . $route->{route_name} . '|'
          . $route->{remark}
          . '|false;';
        $data .= $tmp;
    }
    $self->stash( 'pd', $data );
}

################################
# add a new role
################################
sub add {
    my $self = shift;
    my $data;
    my $role_name  = $self->param('role_name');
    my $remark     = $self->param('remark');
    my @limits     = $self->param('limits');
    my $dt         = DateTime->now( time_zone => 'local' );
    my $oper_date  = $dt->ymd('');
    my $oper_staff = $self->session->{uid};
    my $rid =
      $self->db_txn->select_fld( 'tbl_role_inf', ['role_id'],
        { role_name => encode( 'euc-cn', $role_name ) } );

    if ($rid) {
        $data->{result} = 0;
        $self->stash( 'pd', $data );
        return;
    }

    # begin work
    $self->db_txn->begin_work;

    # add role information to the tbl_role_inf
    my $role_sql =
'insert into tbl_role_inf(role_name, role_type, eff_date, exp_date, oper_staff, oper_date, status, remark) values (\''
      . $role_name
      . '\', \''
      . $role_name
      . '\', \'20110311\', \'20610311\', '
      . $oper_staff . ', \''
      . $oper_date
      . '\', 1, \''
      . $remark . '\')';
    $self->db_txn->dbh->do( encode( 'euc-cn', $role_sql ) );

    # error handle
    my $err_code = $self->db_txn->dberr;
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }
    my $role_id =
      $self->db_txn->select_fld( 'tbl_role_inf', ['role_id'],
        { role_name => encode( 'euc-cn', $role_name ) } );

    # add role limits to the tbl_role_route_map
    shift @limits;
    for my $limit (@limits) {
        my $sql =
"insert into tbl_role_route_map(role_id, route_id) values($role_id->{role_id}, $limit)";
        $self->db_txn->dbh->do($sql);

        # error handle
        my $err_code = $self->db_txn->dberr;
        unless ( $err_code eq '0000' ) {
            $data->{result} = 0;
            $self->db_txn->rollback;
            $self->stash( 'pd', $data );
            return;
        }
    }

    # commit
    $self->db_txn->commit;
    $self->redirect_to('/role/index');
}

################################
# the json method to comfir the role name
################################
sub check {
    my $self = shift;
    my $name = $self->param('rolename');
    my $key =
      $self->db_txn->select_fld( 'tbl_role_inf', ['role_id'],
        { role_name => encode( 'euc-cn', $name ) } )
      || 0;
    $self->render_json( { result => $key } );
}

################################
# delete a role
################################
sub delete {
    my $self = shift;
    my $data;

    # begin work
    $self->db_txn->begin_work;
    my $role_id = $self->param('role_id');

    # delete the data from tbl_role_inf
    my $sql = "delete from tbl_role_inf where role_id = $role_id";
    $self->db_txn->dbh->do( encode( 'euc-cn', $sql ) );

    # error handle
    my $err_code = $self->db_txn->dberr;
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    # get the count of role
    my $count =
      $self->db_txn->select_fld( 'tbl_role_route_map', ['count(*)'],
        { role_id => 1 } )->{1};
    if ( $count != 0 ) {

        # delete the data from tbl_role_route_map
        $sql = "delete from tbl_role_route_map where role_id = $role_id";
        $self->db_txn->dbh->do( encode( 'euc-cn', $sql ) );

        # error handle
        $err_code = $self->db_txn->dberr;
        unless ( $err_code eq '0000' ) {
            $data->{result} = 0;
            $self->db_txn->rollback;
            $self->stash( 'pd', $data );
            return;
        }
    }

    # commit
    $self->db_txn->commit;
    $self->redirect_to('/role/index');
}

################################
# edit a role for modify
################################
sub edit {
    my $self    = shift;
    my $role_id = $self->param('role_id');
    my $data;
    my $role_data =
      $self->db_txn->select( 'tbl_role_inf', { role_id => $role_id } );
    $self->decode_ch($role_data);
    $data->{role_data} = $role_data;
    my $routes = $self->db_txn->select_sql(
'select route_id, route_name, parent_id, view_order, remark from tbl_route_inf order by route_id',
        undef
    );
    my $limits = $self->db_txn->select_sql(
'select route_id from tbl_role_route_map where role_id = ? order by route_id',
        [$role_id]
    );

    for my $route (@$routes) {
        $self->decode_ch($route);
        my $tmp;
        for my $limit (@$limits) {
            if ( $limit->{route_id} == $route->{route_id} ) {
                $tmp = ''
                  . $route->{route_id} . '|'
                  . $route->{parent_id} . '|'
                  . $route->{route_name} . '|'
                  . $route->{remark}
                  . '|true;';
                last;
            }
        }
        $tmp = ''
          . $route->{route_id} . '|'
          . $route->{parent_id} . '|'
          . $route->{route_name} . '|'
          . $route->{remark}
          . '|false;'
          unless ($tmp);
        $data->{value} .= $tmp;
    }
    $self->stash( 'pd', $data );
}

################################
# update role information
################################
sub submit {
    my $self = shift;
    my $data;
    my $role_name = $self->param('role_name');
    my $role_id   = $self->param('role_id');
    my $remark    = $self->param('remark');
    my @limits    = $self->param('limits');

    # begin work
    $self->db_txn->begin_work;

    # update tbl_role_inf
    my $role_sql =
        'update tbl_role_inf set role_name = \''
      . $role_name
      . '\', remark = \''
      . $remark
      . "' where role_id = $role_id";
    $self->db_txn->dbh->do( encode( 'euc-cn', $role_sql ) );

    # error handle
    my $err_code = $self->db_txn->dberr;
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    # get the count of role
    my $count =
      $self->db_txn->select_fld( 'tbl_role_route_map', ['count(*)'],
        { role_id => $role_id } )->{1};

    if ( $count != 0 ) {

        # delete from tbl_role_route_map
        my $sql = "delete from tbl_role_route_map where role_id = $role_id";
        $self->db_txn->dbh->do( encode( 'euc-cn', $sql ) );

        # error handle
        $err_code = $self->db_txn->dberr;
        unless ( $err_code eq '0000' ) {
            $data->{result} = 0;
            $self->db_txn->rollback;
            $self->stash( 'pd', $data );
            return;
        }
    }

    # insert into tbl_role_route_maps
    shift @limits;
    for my $limit (@limits) {
        my $sql =
"insert into tbl_role_route_map(role_id, route_id) values($role_id, $limit)";
        $self->db_txn->dbh->do($sql);

        # error handle
        $err_code = $self->db_txn->dberr;
        unless ( $err_code eq '0000' ) {
            $data->{result} = 0;
            $self->db_txn->rollback;
            $self->stash( 'pd', $data );
            return;
        }
    }
    $self->db_txn->commit;
    $self->redirect_to('/role/index');
}

1;
