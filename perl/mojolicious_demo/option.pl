#选的占位符
#
#可选的占位符.

use Mojolicious::Lite;

# /hello
# /hello/Sara
get '/hello/:name' => { name => 'Sebastian' } => sub {
#get '/hello/:name' => sub {
    my $self = shift;
    $self->render( 'groovy', format => 'txt' );
};

app->start;
__DATA__

@@ groovy.txt.ep
My name is <%= $name %>.
