#!/opt/local/bin/perl

use Util::Run -child   => 1,
              -mwriter => 1,
              -mreader => 1;

Data::Dump->dump($run_kernel);


