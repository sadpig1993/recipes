 use Mojolicious::Lite;

  # /agent
  get '/agent' => sub {
    my $self = shift;
    $self->res->headers->header('X-Bender' => 'Bite my shiny metal ass!');
    $self->render(text => $self->req->headers->user_agent);
  };

  app->start;
