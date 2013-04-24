package Util::PoCo::SHTTPD;

####################################
# POE-based HTTP服务器 
####################################

use strict;
use warnings;

use POE::Component::Server::HTTP;
use File::Basename;
use HTTP::Status;
use URI;

use Util::IniParse;
use Util::Log;

our $shttpd_kernel = bless {
  debug  => 0,
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
#  xxxx  => 
#  conf  => /path/of/httpd.conf
#  debug => 1/0
#  \%config  optional
##########################################################
sub spawn {

  my $class = shift;
  if (@_ % 2 ) {
    $shttpd_kernel->{config} = pop @_;
  }
  my $args  = { @_};
  $shttpd_kernel->{debug}  = delete $args->{'debug'};

  # 加载配置文件 
  my $cfile = delete $args->{'conf'}; 
  if ( $cfile && -f $cfile) {
    unless(&load_cfg($cfile)) {
      warn "load_cfg error";
      return undef;
    }
  }

  # 函数参数优先于配置文件 
  $shttpd_kernel->{docroot} = delete $args->{docroot} if $args->{docroot} && -d $args->{docroot};
  $shttpd_kernel->{port}    = delete $args->{port}    if $args->{port};
  if ( $args->{logdir} && $args->{loglevel} ) {
    unless(__PACKAGE__->init_log($args->{logdir}, $args->{loglevel})) {
      warn "can not init_log";
      return undef;
    }
  }

  POE::Component::Server::HTTP->new (
    'Port'           => $shttpd_kernel->{'port'},
    'TransHandler'   => [ \&translation ],
    'ContentHandler' => { '/'  =>  \&default_content, },
  );


  $shttpd_kernel->{elog}->debug("SHTTPD information:\n" . Data::Dump->dump($shttpd_kernel));

  return $shttpd_kernel;
}

sub add_config {
  my $class_or_self = shift;
  $shttpd_kernel->{config}->{$_[0]} = $_[1];
}

#
#  regex    =>  ".html$",
#  package  =>  "package or code"
#  expire   =>  10,
#
sub add_route {
  my $class_or_self = shift;
  my $rif  = { @_ };

  my ($pkg, $handler)  = split '\s+', $rif->{package};
  $handler = "handler" unless $handler;
  $handler = "handler" if $handler =~ /^\s+$/;

  if ("CODE" eq ref $rif->{package}) {
    $shttpd_kernel->{route}->{$rif->{regex}} = [ $rif->{package}, $rif->{expire} ];
  } else {
    eval "use $pkg;";  #load module 
    if($@) {
      warn "load module $pkg failed with[$@]";
      return undef;
    }
    if ($shttpd_kernel->{debug}) {
      $shttpd_kernel->{route}->{$rif->{regex}} = [ $pkg . "::" . $handler,     $rif->{expire} ];
    } else {
      $shttpd_kernel->{route}->{$rif->{regex}} = [ \&{$pkg . "::" . $handler}, $rif->{expire} ];
    }
  }
  return $shttpd_kernel;

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
  #  error and access log
  ############################################
  unless(__PACKAGE__->init_log($server_cfg->{logdir}, $server_cfg->{loglevel})) {
    warn "can not init_log";
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
    if ($shttpd_kernel->{debug}) {
      $shttpd_kernel->{route}->{$dir} = [ $pkg . "::" . $handler,     $sec->{expire} ];
    } else {
      $shttpd_kernel->{route}->{$dir} = [ \&{$pkg . "::" . $handler}, $sec->{expire} ];
    }
  }  

  return 1;
}

sub init_log {

  my $class    = shift;
  my $logdir   = shift;
  my $loglevel = shift;

  ############################################
  # init elog
  ############################################
  $shttpd_kernel->{elog} = Util::Log->new(
    'logurl'   => $logdir . '/error.log',
    'loglevel' => $loglevel,
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
    'logurl'   => $logdir . '/access.log',
    'loglevel' => $loglevel,
  );
  unless($shttpd_kernel->{alog}) {
    $shttpd_kernel->{alog}->error("Util::Log->new error");
    return undef;
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
      if ($shttpd_kernel->{debug}) {
        $shttpd_kernel->{route}->{$dir}->[0] =~ /^(.*)::(\w+)$/;
        $shttpd_kernel->{elog}->debug("begin load module $1...");
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
      return $shttpd_kernel->{route}->{$dir}->[0]->($req, $res, $dir);
    }
  }

}

sub default_content {
  my ($request, $response) = @_;
  return RC_OK;
}

1;

__END__

=head1 NAME


=head1 SYNOPSIS


=head1 API


=head1 Author & Copyright


=cut

