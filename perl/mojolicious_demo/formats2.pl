#限制性的占位符也可以使用

use Mojolicious::Lite;

# /hello.json
# /hello.txt
get '/hello' => [ format => [qw(json txt)] ] => sub {
    my $self = shift;
    return $self->render_json( { hello => 'world' } )
      if $self->stash('format') eq 'json';
    $self->render_text('hello world');
};

app->start;
