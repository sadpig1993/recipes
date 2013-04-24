package Util::PoCo::SHTTPD::RunAdmin;

use strict;
use warnings;

use URI;
use URI::Escape;
use Util::Run;
use Util::Run::Admin::API;
use Util::PoCo::SHTTPD;
use HTTP::Status;
use MIME::Base64;
use IO::File;
use Template;

use Data::Dump;

my $show_tt2 =<<EOF;

<html>
<head>
  <title>Util::Run Administration</title>
</head>

<body bgcollor="#ffffff">

</body>

</html>

EOF

#
# /admin/show            : 显示状态  
#--------------------------------------
# add_channel            :
# del_channel            :
# del_all_channel        :
#--------------------------------------
# /admin/add_module      : 增加模块  
# /admin/del_module      : 删除模块 
# /admin/del_all         : 删除所有模块 
#--------------------------------------
# /admin/start_module    : 启动模块 
# /admin/restart_module  : 重启模块  
# /admin/restart_all     : 重启所有模块 
# /admin/start_all       : 重启所有模块 
#--------------------------------------
# /admin/stop_module     : 停止模块 
# /admin/stop_all        : 停止所有模块 
# /admin/shutdown        : 
#--------------------------------------
# /admin/add_context
# /admin/del_context
#

sub handler {

  my( $req, $res, $dir ) = @_;
 
  $shttpd_kernel->{elog}->debug("handler got dir: $dir");

=pod 
  {
    my $uri = $req->uri;
    warn "uri     : ", $uri, "\n";
    warn "path    : ", $uri->path, "\n";
    warn "query   : ", $uri->query, "\n";
    warn "content : ", $req->content, "\n";
    warn "method  : ", $req->method, "\n";

    my $errmsg = "test only";
    my $len = length $errmsg;
    $res->header("Content-Length", $len);
    $res->content($errmsg);
    $res->code(200);
    return RC_OK;
  }
=cut

  my $uri  = $req->uri;
  my $path = $uri->path;
  my $query;
  my $decoded;
  my $errmsg = "error3";
  

  if ($req->method =~ /GET/) {
    $query = $uri->query;
  } elsif ($req->method =~ /POST/) {
    $query = $req->content;
  } else {
    $errmsg = "wrong method " . $req->method;
    goto HEND;
  }

  if ($query) {
    my %args;
    $shttpd_kernel->{elog}->debug("ben parse param[$query]...");
    for ( split '&', $query) {
      my ($k, $v) = split '=', $_;
      $v =~ s/%([A-Fa-f\d]{2})/chr hex $1/eg;   # uri_unescape
      $args{$k} = $v;
    }
    $decoded = decode_base64(delete $args{'req'})  if exists $args{'req'};
  }

  my $proc;
  $path =~ /^\/admin\/(.*)/;
  if( $1 eq '' || $1 eq "show" ) {
    $errmsg = &gen_html();
  } 

  else {
    $proc = $1;
    unless($proc =~ /^(
                       add_channel|
                       del_channel|
                       del_all_channel|

                       add_module|
                       del_module|
                       del_all|

                       restart_module|
                       restart_all|
                       start_module|
                       start_all|

                       stop_module|
                       stop_all|
                       shutdown|

                       add_context|
                       del_context
                       )$/mx) {
      $errmsg = "$path can not be handled";
      $shttpd_kernel->{elog}->error($errmsg);
    } 
    else {
      my $out; 
      $shttpd_kernel->{elog}->debug("begin call $proc...");
      eval {
        $out = Util::Run::Admin::API->admin_api($proc, $decoded);
      };
      if($@) {
        $shttpd_kernel->{elog}->error("Util::Run::Admin::API->admin_api($proc,decoded) failed[$@]");
        $errmsg = "Util::Run::Admin::API->admin_api($proc,decoded) failed";
      } else {
        if( $out->{'status'} ) {
          $shttpd_kernel->{elog}->error("call $proc failed");
          $errmsg = $out->{'errmsg'};
        } 
        else {
          $errmsg = &gen_html();
        }
      }
    }
  }

HEND:
  my $len = length $errmsg;
  $res->header("Content-Length", $len);
  $res->content($errmsg);
  $res->code(200);
  return RC_OK;
}

sub gen_html {
  my $out;
  eval {
    $out  = Util::Run::Admin::API->admin_show();
  };
  if ($@) {
    return "Util::Run::Admin::API->admin_show() failed";
  }
  return  Data::Dump->dump($out->{'errmsg'});
}

1;

__END__



