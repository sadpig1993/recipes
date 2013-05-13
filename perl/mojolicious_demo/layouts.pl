use Mojolicious::Lite;

# /with_layout
get '/with_layout' => sub {
  my $self = shift;
  $self->render('with_layout');
};

app->start;
__DATA__

@@ with_layout.html.ep
% title 'Green';
% layout 'green';
Hello layout!

@@ layouts/green.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
