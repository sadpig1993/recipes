package Zweb::User;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use DateTime;
use Encode qw/encode decode/;

################################
# show user list
################################
sub index {
    my $self = shift;
    my $data;
    my @records;

    my $index = $self->param('index') || 1;

    my $pager = $self->db_txn->select_page(
        'tbl_user_inf', [ "user_id", "username", "pwd_chg_date" ],
        undef, ['user_id desc'],
        undef, { cur_page => $index, page_size => 10 },
        { sth => 1 }
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
# input a new user
################################
sub input {
    my $self = shift;
    my $data;

    my $routes = $self->db_txn->select_sql(
        'select role_id, role_name from tbl_role_inf order by role_id', undef );
    for my $route (@$routes) {
        $self->decode_ch($route);
    }
    $data->{roles} = $routes;
    $self->stash( 'pd', $data );
}

################################
# add a new user
################################
sub add {
    my $self = shift;
    my $data;
    my $username = $self->param('username');
    use Data::Dump;

    #  Data::Dump->dump($username);
    my $password = $self->param('password');
    $password = Digest::MD5->new->add($password)->hexdigest;
    my @roles      = $self->param('listRight');
    my $dt         = DateTime->now( time_zone => 'local' );
    my $oper_date  = $dt->ymd('');
    my $oper_staff = $self->session->{uid};
    my $uid =
      $self->db_txn->select_fld( 'tbl_user_inf', ['user_id'],
        { username => encode( 'euc-cn', $username ) } );

    if ($uid) {
        $data->{result} = 0;
        $self->stash( 'pd', $data );
        return;
    }

    # begin work
    $self->db_txn->begin_work;

    # add user information to the tbl_user_inf
    my $user_sql =
'insert into tbl_user_inf(username, user_pwd, pwd_chg_date, eff_date, exp_date, oper_staff, oper_date, status) values (\''
      . $username
      . '\', \''
      . $password
      . '\', \''
      . $oper_date
      . '\', \'20121101\', \'20500101\', '
      . $oper_staff . ', \''
      . $oper_date
      . '\', 1)';
    $self->db_txn->dbh->do( encode( 'euc-cn', $user_sql ) );

    # error handle
    my $err_code = $self->db_txn->dberr;
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }
    my $user_id =
      $self->db_txn->select_fld( 'tbl_user_inf', ['user_id'],
        { username => encode( 'euc-cn', $username ) } );

    # add user roles to the tbl_user_role_map
    for my $role (@roles) {
        my $sql =
"insert into tbl_user_role_map(user_id, role_id) values($user_id->{user_id}, $role)";
        my $rv       = $self->db_txn->dbh->do($sql);
        my $err_code = $self->db_txn->dberr;

        # error handle
        unless ( $err_code eq '0000' ) {
            $data->{result} = 0;
            $self->db_txn->rollback;
            $self->stash( 'pd', $data );
            return;
        }
    }

    # commit
    $self->db_txn->commit;
    $self->redirect_to('/user/index');
}

################################
# the json method to comfirm user name
################################
sub check {
    my $self = shift;
    my $name = $self->param('username');
    my $key =
      $self->db_txn->select_fld( 'tbl_user_inf', ['user_id'],
        { username => encode( 'euc-cn', $name ) } )
      || 0;
    return $self->render_json( { 'result' => $key } );
}

################################
# delete a user
################################
sub delete {
    my $self = shift;
    my $data;
    my $user_id = $self->param('user_id');

    # begin work
    $self->db_txn->begin_work;

    # delete the data from tbl_user_inf
    my $sql = "delete from tbl_user_inf where user_id = $user_id";
    $self->db_txn->dbh->do( encode( 'euc-cn', $sql ) );
    my $err_code = $self->db_txn->dberr;

    # error handle
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    # get the count of role
    my $count =
      $self->db_txn->select_fld( 'tbl_user_role_map', ['count(*)'],
        { user_id => $user_id } )->{1};

    if ( $count != 0 ) {

        # delete the data from tbl_role_route_map
        $sql = "delete from tbl_user_role_map where user_id = $user_id";
        $self->db_txn->dbh->do( encode( 'euc-cn', $sql ) );
        $err_code = $self->db_txn->dberr;

        # error handle
        unless ( $err_code eq '0000' ) {
            $data->{result} = 0;
            $self->db_txn->rollback;
            $self->stash( 'pd', $data );
            return;
        }
    }
    $self->db_txn->commit;
    $self->redirect_to('/user/index');
}

################################
# edit a user for modify
################################
sub edit {
    my $self    = shift;
    my $user_id = $self->param('user_id');
    my $data;
    my $user_data =
      $self->db_txn->select( 'tbl_user_inf', { user_id => $user_id } );
    $data->{user_data} = $user_data;
    my $all_roles = $self->db_txn->select_sql(
        'select role_id, role_name from tbl_role_inf order by role_id', undef );
    my $my_roles = $self->db_txn->select_sql(
'select role_id from tbl_user_role_map where user_id = ? group by role_id',
        [$user_id]
    );
    my @right;
    my @left;

    for my $role (@$all_roles) {
        $self->decode_ch($role);
        my $tag = 0;
        for my $my_role (@$my_roles) {
            if ( $my_role->{role_id} == $role->{role_id} ) {
                push @right, $role;
                $tag = 1;
            }
        }
        if ( $tag == 0 ) {
            push @left, $role;
        }
    }
    $data->{left}  = [@left];
    $data->{right} = [@right];
    $self->stash( 'pd', $data );
}

################################
# update user information
################################
sub submit {
    my $self = shift;
    my $data;
    my $username = $self->param('username');
    my $user_id  = $self->param('user_id');
    my $password = $self->param('password') || '';
    my @roles    = $self->param('listRight');
    $self->db_txn->begin_work;
    my $user_sql;

    if ( $password eq '' ) {
        $user_sql =
            'update tbl_user_inf set username = \''
          . $username
          . "\' where user_id = $user_id";
    }
    else {
        $password = Digest::MD5->new->add($password)->hexdigest;
        $user_sql =
            'update tbl_user_inf set username = \''
          . $username
          . '\', user_pwd = \''
          . $password
          . "' where user_id = $user_id";
    }
    $self->db_txn->dbh->do( encode( 'euc-cn', $user_sql ) );
    my $err_code = $self->db_txn->dberr;

    # error handle
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->rollback;
        $self->stash( 'pd', $data );
        return;
    }

    # get the count of role
    my $count =
      $self->db_txn->select_fld( 'tbl_user_role_map', ['count(*)'] )->{1};
    if ( $count != 0 ) {

        # delete from tbl_user_role_map
        my $sql = "delete from tbl_user_role_map where user_id = $user_id";
        $self->db_txn->dbh->do( encode( 'euc-cn', $sql ) );
        $err_code = $self->db_txn->dberr;

        # error handle
        unless ( $err_code eq '0000' ) {
            $data->{result} = 0;
            $self->db_txn->rollback;
            $self->stash( 'pd', $data );
            return;
        }
    }

    # insert into tbl_user_role_maps
    for my $role (@roles) {
        my $sql =
"insert into tbl_user_role_map(user_id, role_id) values($user_id, $role)";
        $self->db_txn->dbh->do($sql);

        #error handle
        $err_code = $self->db_txn->dberr;

        # error handle
        unless ( $err_code eq '0000' ) {
            $data->{result} = 0;
            $self->db_txn->rollback;
            $self->stash( 'pd', $data );
            return;
        }
    }

    # commit
    $self->db_txn->commit;
    $self->redirect_to('/user/index');
}

1;
