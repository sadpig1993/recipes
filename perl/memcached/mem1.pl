#!/usr/bin/env perl

use Cache::Memcached;
use Data::Dump;

use strict;
use warnings;

my $memd = new Cache::Memcached {
    'servers'            => 'localhost:11211',
    'debug'              => 0,
    'compress_threshold' => 10_000,
};

$memd->set( "my_key", "Some value" );
$memd->set( "object_key", { 'complex' => [ "object", 2, 4 ] } );


Data::Dump->dump($memd->get("my_key"));
