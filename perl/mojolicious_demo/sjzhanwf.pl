#松懈占位符

#松懈占位可以让你匹配直接到 / 。

use Mojolicious::Lite;

# /test/hello
# /test123/hello
# /test.123/hello
get '/#you/hello' => 'groovy';

app->start;
__DATA__

@@ groovy.html.ep
Your name is <%= $you %>.
