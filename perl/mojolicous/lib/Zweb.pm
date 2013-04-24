package Zweb;
use Mojo::Base 'Mojolicious';
use Util::Log;
use Util::DBI;
use Env qw/ZWEB_HOME/;
use Encode qw/decode/;
use Data::Dump;

# This method will run once at server start
sub startup {
  my $self = shift;
  
  my $logger = Util::Log->new(
    logurl   => "file://$ZWEB_HOME/log/zweb.log",
    loglevel => 'DEBUG',
  );
  
  my $db_txn = Util::DBI->new(qw/dsn dbi:DB2:zdb_dev dbuser ypinst dbpass ypinst schema ypinst/);
  #my $db_log = Util::DBI->new(qw/dsn dbi:DB2:zdb_dev dbuser db2inst dbpass db2inst schema zbp/);

  # plugin
  $self->plugin(Charset => {charset => 'utf-8'});
  $self->plugin('RenderFile');
  
  # helper
  $self->helper(db_txn  => sub { return $db_txn; }); # db_txn
  $self->helper(decode_ch => sub {
    my $self = shift;
    my $row = shift;
      
    # chinese decode
    $row->{route_name} = decode('gbk', $row->{route_name}) if $row->{route_name};
    $row->{route_value} = decode('gbk', $row->{route_value}) if $row->{route_value};
    $row->{role_name} = decode('gbk', $row->{role_name}) if $row->{role_name};
    $row->{role_type} = decode('gbk', $row->{role_type}) if $row->{role_type};
    $row->{remark} = decode('gbk', $row->{remark}) if $row->{remark};
    $row->{username} = decode('gbk', $row->{username}) if $row->{username};
    $row->{name}=decode('utf-8',$row->{name}) if $row->{name};
    $row->{memo}=decode('utf-8',$row->{memo}) if $row->{memo};
    $row->{acct_name} = decode('utf-8', $row->{acct_name}) if $row->{acct_name};
    $row->{b_name} = decode('utf-8', $row->{b_name}) if $row->{b_name};

    
    # string cut off
    $row->{rec_upd_ts} =~ s/\..*$// if $row->{rec_upd_ts};
  });
  $self->helper(cal_page => sub{
    my $self = shift;
    my %args = @_;
    my $total = $args{total};
    my $size = $args{size};
    my $index = $args{index};
    my $data;
    
    use integer;
    if($total % $size){
      $data->{total_page} = 1 + $total / $size;
    } else {
      $data->{total_page} = $total / $size;
    }
    $data->{prev_page} = ($index - 1) > 0 ? $index - 1 : 1;
    $data->{next_page} = ($index + 1) <= $data->{total_page} ? $index + 1 : $data->{total_page};
    return $data;
  });
  
  # hook
  $self->hook( before_dispatch => \&before_dispatch);

  # Router
  my $r = $self->routes;

  # login controller
  $r->route('/')->to('login#show');
  $r->route('/login')->to('login#login');
  $r->route('/login/left')->to('login#left');
  $r->route('/login/reset_password')->to('login#reset_password');
  $r->route('/login/password_reset')->to('login#password_reset');
  $r->route('/logout')->to('login#logout');
  
  ########################################################
  # role controller
  $r->get('/role/index')->to("role#index");
  $r->get('/role/input')->to("role#input");
  $r->get('/role/add')->to("role#add");
  $r->get('/role/delete')->to("role#delete");
  $r->get('/role/edit')->to("role#edit");
  $r->get('/role/submit')->to("role#submit");
  $r->get('/role/check.json')->to("role#check");
  
  ########################################################

  ########################################################
  # bank controller
  $r->get('/bank/index')->to("bank#index");
  $r->get('/bank/input')->to("bank#input");
  $r->get('/bank/add')->to("bank#add");
  $r->get('/bank/delete')->to("bank#delete");
  $r->get('/bank/edit')->to("bank#edit");
  $r->get('/bank/submit')->to("bank#submit");
  $r->get('/bank/check.json')->to("bank#check");
  
  ########################################################
  # bip controller
  $r->get('/bip/index')->to("bip#index");
  $r->get('/bip/input')->to("bip#input");
  $r->get('/bip/add')->to("bip#add");
  $r->get('/bip/delete')->to("bip#delete");
  $r->get('/bip/edit')->to("bip#edit");
  $r->get('/bip/submit')->to("bip#submit");
  $r->get('/bip/check.json')->to("bip#check");

  ########################################################
  # dictbook controller
  $r->get('/dictbook/index')->to("dictbook#index");
  $r->get('/dictbook/input')->to("dictbook#input");
  $r->get('/dictbook/add')->to("dictbook#add");
  $r->get('/dictbook/delete')->to("dictbook#delete");
  $r->get('/dictbook/edit')->to("dictbook#edit");
  $r->get('/dictbook/submit')->to("dictbook#submit");
  $r->get('/dictbook/check.json')->to("dictbook#check");

  ########################################################
  # dictdim controller
  $r->get('/dictdim/index')->to("dictdim#index");
  $r->get('/dictdim/input')->to("dictdim#input");
  $r->get('/dictdim/add')->to("dictdim#add");
  $r->get('/dictdim/delete')->to("dictdim#delete");
  $r->get('/dictdim/edit')->to("dictdim#edit");
  $r->get('/dictdim/submit')->to("dictdim#submit");
  $r->get('/dictdim/check.json')->to("dictdim#check");
  ########################################################
  # dictyspz controller
  $r->get('/dictyspz/add')->to("dictyspz#add");
  $r->get('/dictyspz/submit')->to("dictyspz#submit");
  $r->get('/dictyspz/input')->to("dictyspz#input");
  $r->get('/dictyspz/index')->to("dictyspz#index");
  $r->get('/dictyspz/edit')->to("dictyspz#edit");
  $r->get('/dictyspz/delete')->to("dictyspz#delete");
  $r->get('/dictyspz/check.json')->to("dictyspz#check");

  ########################################################
  # dimbi controller
  $r->get('/dimbi/add')->to("dimbi#add");
  $r->get('/dimbi/submit')->to("dimbi#submit");
  $r->get('/dimbi/input')->to("dimbi#input");
  $r->get('/dimbi/index')->to("dimbi#index");
  $r->get('/dimbi/edit')->to("dimbi#edit");
  $r->get('/dimbi/delete')->to("dimbi#delete");
  $r->get('/dimbi/check.json')->to("dimbi#check");

  ########################################################
  # dimp controller
  $r->get('/dimp/add')->to("dimp#add");
  $r->get('/dimp/submit')->to("dimp#submit");
  $r->get('/dimp/input')->to("dimp#input");
  $r->get('/dimp/index')->to("dimp#index");
  $r->get('/dimp/edit')->to("dimp#edit");
  $r->get('/dimp/delete')->to("dimp#delete");
  $r->get('/dimp/check.json')->to("dimp#check");


  ########################################################
  # dimbfj controller
  $r->get('/dimbfj/add')->to("dimbfj#add");
  $r->get('/dimbfj/submit')->to("dimbfj#submit");
  $r->get('/dimbfj/input')->to("dimbfj#input");
  $r->get('/dimbfj/index')->to("dimbfj#index");
  $r->get('/dimbfj/edit')->to("dimbfj#edit");
  $r->get('/dimbfj/delete')->to("dimbfj#delete");
  $r->get('/dimbfj/check.json')->to("dimbfj#check");

  ########################################################
  # user controller
  $r->get('/user/index')->to("user#index");
  $r->get('/user/input')->to("user#input");
  $r->get('/user/add')->to("user#add");
  $r->get('/user/delete')->to("user#delete");
  $r->get('/user/edit')->to("user#edit");
  $r->get('/user/submit')->to("user#submit");
  $r->get('/user/check.json')->to("user#check");
  ########################################################
  # user controller
  $r->get('/ypos/list')->to("ypos#list");
  $r->get('/ypos/si')->to("ypos#signin");
  $r->get('/ypos/monitoring')->to("ypos#monitoring");
	

}

sub before_dispatch {
  my $c = shift;
  
  my $path = $c->req->url->path;
  
  return 1 if $path =~ /^\/login|^\/logout/;   # 登陆退出可以访问
  return 1 if $path =~ /^\/$/;                 # 登陆页面可以访问
  return 1 if $path =~ /^\/(js|css|images)\//; # 静态文件可以访问
  return 1 if $path =~ /^\/fail.html$/;        # fail 
  
  my $cfg  = $c->config;
  my $sess = $c->session;

  # 没有登陆不让访问  
  unless(defined $sess->{user}) {
    $c->redirect_to("/fail.html");
    return;
  }
  
  if ($path =~ /\.html$/) {
    return 1;
  }

  my $routes = [@{$sess->{routes}}];
  for my $route (@$routes) {
    if ($path =~ m{$route$}) {
      return 1;
    }
  }
  $c->redirect_to("/denied.html");
}

1;
