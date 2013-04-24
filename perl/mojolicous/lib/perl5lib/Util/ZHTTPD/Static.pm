package Util::ZHTTPD::Static;

use URI;
use IO::File;
use Data::Dump;
use Util::ZHTTPD::Config qw/$server_cfg $hc/;

use POE::Session;

sub handler {

  my( $req, $res, $dir ) = @_[ ARG0 .. ARG2 ];

  my $expire = $hc->{$dir}->{'expire'};

  my $uri = URI->new($req->uri);
  my $path = $uri->path;

  my $img = IO::File->new("< $server_cfg->{document_root}" . $path);
  local $/ = undef;
  my $msg = <$img>;
  my $len = length $msg;

  $res->header("Expires", $expire);
  $res->header("Cache-Control", "max-age=$expire");
  $res->header("Content-Length", $len);
  $res->content($msg);
  $res->code(200);

  if($path =~ /\.(jpg|jpeg|gif|bmp)$/) {  
    $res->header("Content-Type", "image/$1");
  }

  elsif($path =~ /\.(js)$/) {  
    $res->header("Content-Type", "text/javascript");
  }

  elsif($path =~ /\.(html)$/) {  
    $res->header("Content-Type", "text/html");
  }

  elsif($path =~ /\.(css)$/) {  
    $res->header("Content-Type", "text/css");
  }

  $_[KERNEL]->post( $server_cfg->{'s_session'}, 'DONE', $res);

}

1;

