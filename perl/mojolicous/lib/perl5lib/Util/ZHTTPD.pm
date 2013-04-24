package Util::SHTTPD;

use strict;
use warnings;

use POE;
use POE::Component::Server::HTTP;
use File::Basename;
use HTTP::Status;
use URI;

use Data::Dump;

use Util::IniParse;
use Util::Log;

our $shttpd_kernel = bless {
  debug  => 0,               # debug
  alog   => undef,           # access log
  elog   => undef,           # error log
  route  => undef,           # url mapping
  config => undef,           # {} customizable
}, __PACKAGE__;

sub import {
  my $pkg = shift;
  my $callpkg = (caller)[0];
  no strict;
  *{"$callpkg\::shttpd_kernel"} = \$shttpd_kernel;
}

sub config {
  my $class_or_self = shift;
  my $name = shift;
  return $shttpd_kernel->{config}->{$name};
}

##########################################################
# configuration
#
# [%server]
# address        = 192.168.1.29   #  hostname
# port           = 52052          #  port
# document_root  = .              #  document root
# 
# s_session      = httpd          # 
# p_session      = process        # 
# background     = 0              #   oóì¨??DD
# 
# loglevel       = DEBUG
# logdir         = file:///tmp
# 
# include        = httpd.conf.d/* #  sub configuration
# 
# [^/flow/risk]
# package = Util::SHTTPD::Flow risk
# expire  = 10
# 
# [^/static/ExtJS-4.0/.*(.jpg|.gif|.jpeg|.js|.css)$]
# package   = Util::SHTTPD::Static
# expire    = 1000000
# 
# [.html$]
# package   = Util::SHTTPD::Static
# expire    = 10
##########################################################
#  conf => /path/of/httpd.conf
##########################################################
sub spawn {

  my $class = shift;
  my $args  = { @_};

  my $cfile = delete $args->{'conf'}; 
  unless(&load_cfg($cfile)) {
    warn "load_cfg error";
    return undef;
  }
  $shttpd_kernel->{config} = $args;

  POE::Component::Server::HTTP->new (
    'Port'           => $shttpd_kernel->{'port'},
    'TransHandler'   => [ \&translation ],
    'ContentHandler' => {
     '/'  =>  \&default_content,
    },
  );
}

#
# parse httpd.conf to get configuration
#
sub load_cfg {

  my $cfile = shift;

  my $urlmap = &ini_parse($cfile);
  unless($urlmap) {
    warn "ini_parse($cfile) error";
    return undef;
  }
  my $server_cfg = delete $urlmap->{'%server'};
  $shttpd_kernel->{docroot} = $server_cfg->{docroot};
  $shttpd_kernel->{host}    = $server_cfg->{host};
  $shttpd_kernel->{port}    = $server_cfg->{port};

  ############################################
  #  如果有子配置, 则读取子配置并与之合并  
  ############################################
  my $include = delete $server_cfg->{'include'};
  if($include) {
    my @inc;
    my $conf_dir = dirname($cfile);
    my $_ = $include;
    push @inc, <$conf_dir/$_> for split;
    for (@inc) {
      my $sub_urlmap = ini_parse($_);
      for (keys %{$sub_urlmap}) {
        if( exists $urlmap->{$_}) {
          warn "ERROR:duplicated key";
          return undef;
        }
        $urlmap->{$_} = $sub_urlmap->{$_};
      }
    }
  }

  ############################################
  # init elog
  ############################################
  $shttpd_kernel->{elog} = Util::Log->new(
    'logurl'   => $server_cfg->{'logdir'} . '/error.log',
    'loglevel' => $server_cfg->{'loglevel'},
  );
  unless($shttpd_kernel->{elog}) {
    warn "Util::Log->new  error";
    return undef;
  }
  $shttpd_kernel->{elog}->debug("error log is inited");

  ############################################
  # init alog
  ############################################
  $shttpd_kernel->{alog} = Util::Log->new(
    'logurl'   => $server_cfg->{'logdir'} . '/access.log',
    'loglevel' => $server_cfg->{'loglevel'},
  );
  unless($shttpd_kernel->{alog}) {
    $shttpd_kernel->{alog}->error("Util::Log->new error");
    return undef;
  }

  ############################################
  # 生成route信息 
  ############################################
  for my $dir ( keys %{$urlmap} ) {

    my $sec = $urlmap->{$dir};

    my ($pkg, $handler)  = split '\s+', $sec->{'package'};
    $handler = "handler" unless $handler;
    $handler = "handler" if $handler =~ /^\s+$/;

    eval "use $pkg;";  #load module 
    if($@) {
      warn "load module $pkg failed with[$@]";
      return undef;
    }
    $shttpd_kernel->{route}->{$dir} = $pkg . "::" . $handler;
  }

  return 1;
}

########################################
# PoCo::HTTP callbacks
########################################
sub translation {

  my ($req, $res) = @_;
  my $uri  = URI->new($req->uri);
  my $path = $uri->path;
  for my $dir (keys %{$shttpd_kernel->{route}}) {
    if ( $path  =~ /$dir/) {
      $shttpd_kernel->{elog}->debug("$path matched with $dir");

      #
      # in the debug mode:  
      # the handler module will always be reloaded for every request
      #
      if ($shttpd_kernel->{config}->{debug}) {
        $shttpd_kernel->{route}->{$dir} =~ /^(.*)::(\w+)$/;
        $shttpd_kernel->{elog}->debug("begin load module $1...");
        use Class::Unload;
        Class::Unload->unload($1);
        eval "use $1;";
        if($@) {
          my $errmsg = "load module $1 failed";
          $shttpd_kernel->{elog}->error($errmsg);
          $res->content($errmsg);
          $res->header("Content-Length", length $errmsg);
          $res->header("Content-Type", 'text/plain');
          $res->code(200);
          return 1;
        }
      }
      no strict;
      return $shttpd_kernel->{route}->{$dir}->($req, $res, $dir);
    }
  }

}

sub default_content {
  my ($request, $response) = @_;
  $shttpd_kernel->{elog}->debug("default_content is called");
  return RC_OK;
}

1;

