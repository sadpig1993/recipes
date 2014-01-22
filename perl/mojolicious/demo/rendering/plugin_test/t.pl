use Mojolicious::Lite;

plugin 'DebugHelper';

get '/' => sub {
    my $self = shift;
    $self->debug('It works.');
    $self->render_text('Hello.');
};

app->start;
