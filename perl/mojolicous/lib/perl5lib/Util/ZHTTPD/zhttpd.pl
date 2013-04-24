#!/usr/bin/perl
use strict;
use warnings;

use lib '/data1/hary/lib';
use POE;
use POE::Component::Server::SimpleHTTP;
use POE::Component::Server::SimpleHTTP::PreFork;
use Getopt::Long;
use File::Basename;
use Digest::MD5 qw/md5_hex/;
use Data::Dump;

use Util::ZHTTPD::Config qw/$hc $server_cfg $emap/;
use Util::IniParse;
use Util::Daemon;

my @argv = @ARGV;
###########################################
# command line parsing
###########################################
my $hconf;
my $rtn = GetOptions(
  "conf|c=s"  => \$hconf,
);
unless($rtn) {
  die "GetOptions error, Usage: ./httpd.pl -c httpd.conf";
}
unless(defined $hconf ) {
  die "GetOptions error, Usage: ./httpd.pl -c httpd.conf";
}
unless( -f $hconf) {
  die "$hconf does not exists";
}

###########################################
# running
###########################################
#
# init Util::HTTPD::Config
#
$hc = &ini_parse($hconf);
$server_cfg = delete $hc->{'%server'};

if ($server_cfg->{'background'} == 1 ) {
  Util::Daemon->daemonize();
}

#
# merge with sub configurations...
#
my $include = delete $server_cfg->{'include'};
if($include) {
  my @inc;
  my $conf_dir = dirname($hconf);
  my $_ = $include;
  push @inc, <$conf_dir/$_> for split;
  for (@inc) {
    my $sub_hc = ini_parse($_);
    for (keys %{$sub_hc}) {
      if( exists $hc->{$_}) {
        warn "ERROR:duplicated key";
        exit 0;
      }
      $hc->{$_} = $sub_hc->{$_};
    }
  }
}

my @handler;
my %pkg_states;

warn "hc configuration...\n";
Data::Dump->dump($hc);
warn "server_cfg configuration...\n";
Data::Dump->dump($server_cfg);

#
# ¼ÓÔØÄ£¿é  
#
for my $dir ( keys %{$hc} ) {

  my $sec = $hc->{$dir};

  my ($pkg, $handler)  = split '\s+', $sec->{'package'};
  $handler = "handler" unless $handler;
  $handler = "handler" if $handler =~ /^\s+$/;

  md5_hex($dir) =~ /^(.{8})/;
  my $md5 = $1;
  
  unless(exists $pkg_states{$pkg}) {
    warn "begin load package $pkg...";
    eval "use $pkg;";
    if ($@) {
      warn "load package $pkg failed[$@]\n";
      exit 0;
    }
  }
  my $entry = {
    'DIR'     =>  $dir,
    'SESSION' =>  $server_cfg->{'p_session'},
    'EVENT'   =>  $md5,
  };
  push @handler, $entry;
  $pkg_states{$pkg}{$md5} = $handler;
  $emap->{$md5} = $dir;

}

my @states;
for my $pkg (keys %pkg_states) {
  push @states, $pkg, $pkg_states{$pkg};
}
undef %pkg_states;

warn "\@states....\n";
Data::Dump->dump(\@states);
warn "\@handler....\n";
Data::Dump->dump(\@handler);

#
# SimpleHTTP server
#

if ( $server_cfg->{'min_spare_servers'} > 0  &&
     $server_cfg->{'max_spare_servers'} > 0  &&
     $server_cfg->{'max_clients'}       > 0  &&
     $server_cfg->{'start_servers'}     > 0 ) {
  POE::Component::Server::SimpleHTTP::PreFork->new (
    'ALIAS'            => $server_cfg->{'s_session'},
    'ADDRESS'          => $server_cfg->{'address'}, 
    'PORT'             => $server_cfg->{'port'},
    'HANDLERS'         => \@handler,
    'FORKHANDLERS'     => { $server_cfg->{'p_session'} => 'FORKED' },
    'MINSPARESERVERS'  => $server_cfg->{'min_spare_servers'},
    'MAXSPARESERVERS'  => $server_cfg->{'max_spare_servers'},
    'MAXCLIENTS'       => $server_cfg->{'max_clients'},
    'STARTSERVERS'     => $server_cfg->{'start_servers'},
  );
} else {
  POE::Component::Server::SimpleHTTP->new (
    'ALIAS'      => $server_cfg->{'s_session'},
    'ADDRESS'    => $server_cfg->{'address'}, 
    'PORT'       => $server_cfg->{'port'},
    'HANDLERS'   => \@handler,
  );
}

#
# process Session 
# 
POE::Session->create(
  'inline_states'  => { '_start' =>  sub { $_[KERNEL]->alias_set( $server_cfg->{'p_session'} ); }, },
  'package_states' => \@states,
);

$poe_kernel->run();


__END__

# use POE::Component::Server::SimpleHTTP::PreFork;
#
# prefork mode needed parameters
#
#

