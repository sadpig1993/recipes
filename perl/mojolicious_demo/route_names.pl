use Mojolicious::Lite;

# /
get '/' => sub {
	my $self = shift;
    $self->render;
} => 'index';

# /hello
get '/hello';

app->start;

__DATA__

@@ index.html.ep
<%= link_to Hello  => 'hello' %>.
<%= link_to Reload => 'index' %>.

@@ hello.html.ep
Hello World!
