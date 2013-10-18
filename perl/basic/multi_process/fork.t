#!/usr/bin/env perl

use strict;
use warnings;


my $pid = fork ;

if ($pid > 0) {
    warn "this is parent";
    sleep 20 ;
}
elsif ( $pid == 0 ) {
    warn "this is child";
    sleep 20 ;
}
else {
    warn "fork error";
}

exit 0 ;
