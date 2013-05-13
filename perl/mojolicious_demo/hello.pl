use Mojolicious::Lite;

#	/foo
#get '/foo' => sub {
#	my $self = shift ;
#	$self->render(text => 'hello world!');
#};


#	/foo?user=sri
get '/foo' => sub {
	my $self = shift ;
	my $user = $self->param('user');
	
	#my $name = $self->param('name');
	$self->render(text => "hello $user!");
};


app->start;
