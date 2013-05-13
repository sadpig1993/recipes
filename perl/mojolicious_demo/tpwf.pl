#通配位符

#配位符可以匹配到任何东西，包括 / 和 ..

use Mojolicious::Lite;

# /hello/test
# /hello/test123
# /hello/test.123/test/123
get '/hello/*you' => 'groovy';

app->start;
__DATA__

@@ groovy.html.ep
Your name is <%= $you %>.
