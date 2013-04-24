package Zweb::Login;

use Mojo::Base 'Mojolicious::Controller';
use utf8;
use Digest::MD5;

#
#
#
sub show {
    my $self = shift;
    my $tag = shift || 0;
    $self->stash( 'pd', $tag );
}

#
#
#
sub login {
    my $self     = shift;
    my $username = $self->param('username');
    my $user_data =
      $self->db_txn->select( 'tbl_user_inf', { username => $username } );
    unless ($user_data) {
        $self->stash( 'action', 'show' );
        $self->show(1);
        return 1;
    }
    my $pwd = $self->param('password');
    $pwd = Digest::MD5->new->add($pwd)->hexdigest;
    if ( $user_data->{user_pwd} eq $pwd ) {
        $self->session->{user} = $user_data->{username};
        $self->session->{uid}  = $user_data->{user_id};
        $self->session->{routes} =
          [ @{ $self->getRoutes( $user_data->{user_id} ) } ];
        $self->session( expires => time + 604800 );
        $self->redirect_to('/index.html');
        return 1;
    }
    $self->app->log->error("invalid password");
    $self->stash( 'action', 'show' );
    $self->show(1);
}

sub left {
    my $self  = shift;
    my $data  = {};
    my $uid   = $self->session->{uid};
    my $rdata = $self->db_txn->select_sql(
"select route_name, route_value, parent_id, route_id from tbl_route_inf where status = 1 and route_id in
                                (select route_id from tbl_role_route_map where role_id in
                                (select role_id from tbl_user_role_map where user_id = ?))",
        [$uid]
    );
    for my $route_data (@$rdata) {
        $self->decode_ch($route_data);
        if ($route_data) {
            if ( $route_data->{parent_id} == 0 ) {
                $data->{ $route_data->{route_id} } =
                  { name => $route_data->{route_name} };
            }
            else {
                my $tmp->{key} = $route_data->{route_name};
                $tmp->{value} = $route_data->{route_value};
                my $k = $route_data->{parent_id};
                $data->{$k} = {} unless $data->{$k};
                $data->{$k}->{children} = [] unless $data->{$k}->{children};
                push @{ $data->{$k}->{children} }, $tmp;
            }
        }
    }
    $self->stash( 'pd', $data );
}

sub reset_password {
    my $self = shift;
}

sub password_reset {
    my $self         = shift;
    my $data         = {};
    my $old_password = $self->param('old_password');
    my $new_password = $self->param('new_password');
    my $uid          = $self->session->{uid};
    $old_password = Digest::MD5->new->add($old_password)->hexdigest;
    my $user_data =
      $self->db_txn->select( 'tbl_user_inf',
        { user_id => $uid, user_pwd => $old_password } );
    unless ($user_data) {
        $data->{result} = 0;
        $self->stash( 'pd', $data );
        return;
    }
    $self->db_txn->begin_work;
    $new_password = Digest::MD5->new->add($new_password)->hexdigest;
    my $sql =
        "update tbl_user_inf set user_pwd = '"
      . $new_password
      . "' where user_id = $uid";

    $self->db_txn->dbh->do($sql);
    my $err_code = $self->db_txn->dberr;
    unless ( $err_code eq '0000' ) {
        $data->{result} = 0;
        $self->db_txn->dbh->rollback;
        $data->{result} = 2;
        $self->stash( 'pd', $data );
        return;
    }
    $self->db_txn->commit;
    $data->{result} = 1;
    $self->stash( 'pd', $data );
}

#
#
#
sub logout {
    my $self = shift;
    $self->session->{username} = undef;
    $self->session( expires => 1 );
    $self->redirect_to('/');
}

sub getRoutes {
    my $self = shift;
    my $uid  = shift;
    my $data = [];

    my $rdata = $self->db_txn->select_sql(
        'select route_regex from tbl_route_inf where route_id in
                                        (select route_id from tbl_role_route_map where role_id in
                                        (select role_id from tbl_user_role_map where user_id = ?))',
        [$uid]
    );
    for my $route_data (@$rdata) {
        if ( $route_data && $route_data->{route_regex} ) {
            push @{$data}, $route_data->{route_regex};
        }
    }

    return $data;
}

1;
