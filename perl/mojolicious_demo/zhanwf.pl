#占位符号
use Mojolicious::Lite;

# /foo/test
# /foo/test123
get '/foo/:bar' => sub {
  my $self = shift;
  my $bar  = $self->stash('bar');
  $self->render(text => "Our :bar placeholder matched $bar");
};

# /testsomething/foo
# /test123something/foo
get '/(:bar)something/foo' => sub {
  my $self = shift;
  my $bar  = $self->param('bar');
  $self->render(text => "Our :bar placeholder matched $bar");
};

app->start;
