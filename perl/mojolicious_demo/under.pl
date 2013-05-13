#Under
#
#认证并共享代码在多个路径之间很容易实现，只需要桥接生成的路由并使用 
#under 的声明。判断是认证还是路径显示只需要看看返回是否为 true 就知道了.

use Mojolicious::Lite;

# Authenticate based on name parameter
under sub {
  my $self = shift;

  # Authenticated
  my $name = $self->param('name') || '';
  return 1 if $name eq 'Bender';

  # Not authenticated
  $self->render('denied');
  return undef;
};

# / (with authentication)
get '/' => 'index';

app->start;
__DATA__;

@@ denied.html.ep
You are not Bender, permission denied.

@@ index.html.ep
Hi Bender.
