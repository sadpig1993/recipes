package Util::SHTTPD::Static;

use Util::SHTTPD;
use URI;
use URI::Escape;
use HTTP::Status;
use IO::File;

my %hash;

sub handler {

  my( $req, $res, $dir ) = @_;

  my $expire = $shttpd_kernel->{route}->{$dir}->{'expire'};

  my $uri  = URI->new($req->uri);
  my $path = uri_unescape($uri->path);
  $shttpd_kernel->{elog}->debug("path is", $uri->path);

  my $msg;
  my $len;
  if( exists $hash{$path} ) {
    $msg = $hash{$path}->[0];
    $len = $hash{$path}->[1];
  }
  else {
    my $fh = IO::File->new("< $shttpd_kernel->{docroot}" . $path);
    local $/ = undef;
    $msg = <$fh>;
    $len = length $msg;
  }


  if($path =~ /\.(jpg|jpeg|gif|bmp)$/) {  
    $res->header("Content-Type", "image/$1");
  }
  elsif($path =~ /\.(js)$/) {  
    $res->header("Content-Type", "text/javascript");
  }
  elsif($path =~ /\.(html)$/) {  
    $res->header("Content-Type", "text/html");
    $hash{$path} = [$msg, $len]  unless exists $hash{$path};   # attention
  }
  elsif($path =~ /\.(css)$/) {  
    $res->header("Content-Type", "text/css");
  }

  # my $expires = localtime(time() + 100000000000);
  # warn "exipres: $expires";
  # $res->header("Expires", $expires);
  $res->header("Cache-Control", "max-age=$expire");
  $res->header("Content-Length", $len);
  $res->content($msg);
  $res->code(200);

  $shttpd_kernel->{alog}->access(sprintf("%4s [%6d]", $req->method, $len), $path);

  return RC_OK;

}

1;

