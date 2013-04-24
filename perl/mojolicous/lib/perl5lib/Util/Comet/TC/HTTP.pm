package Util::Comet::TC::HTTP;

use strict;
use warnings;

use base qw/Util::Comet::TC/;

use Data::Dump;
use POE;
use POE::Wheel::ReadWrite;
use POE::Filter::HTTP::Parser;
use HTTP::Request::Common;
use Time::HiRes qw/gettimeofday/;

#
# ¶¨ÖÆon_start
#
sub _on_start {

    my $class  = shift;
    my $heap   = shift;
    my $kernel = shift;
    my $args   = shift;
    $heap->{filter} = 'POE::Filter::HTTP::Parser';
    $heap->{fargs}  = [];

}

#
# ´Óremote data È¡³öÒµÎñ±¨ÎÄ
#
sub _packet {

    my $class = shift;
    my $heap  = shift;
    my $rdata = shift;
    $rdata->content(),    # attention
}

#
# ´Óadapter data ¹¹Ôìrequest
#
sub _request {

    my $class = shift;
    my $heap  = shift;
    my $data  = shift;

    my $config = $heap->{config};
    my $url =
      "http://$config->{remoteaddr}:$config->{remoteport}" . $data->{path};
    my $request = POST $url, Content => $data->{packet};
    $heap->{logger}->debug( "send request:\n" . Data::Dump->dump($request) );
    return $request;
}

1;

