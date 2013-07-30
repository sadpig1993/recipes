#!/usr/bin/env perl
use Getopt::Long;
use strict;
use warnings;

# declare default values for variables
my $verbose = 0;
my $all     = 0;
my $more    = -1;       # so we can detect both -more and -nomore
my $diam    = 3.1415;
my @libs    = ();
my %flags   = ();
my $debug   = -1;       # test for -debug with no argument (0)

# process options from command line
# verbose will be incremented each time it appears
# either all, everything or universe will set $all to 1
# more can be negated (-nomore)
# diameter expects a floating point argument
# lib expects a string and can be repeated (pushing onto @libs)
# flag expects a key=value pair and can be repeated
# debug will optionally accept an integer (or 0 by default)
GetOptions(
    'verbose+'                => \$verbose,
    'all|everything|universe' => \$all,
    'more!'                   => \$more,
    'diameter=f'              => \$diam,
    'lib=s'                   => \@libs,
    'flag=s'                  => \%flags,
    'debug:i'                 => \$debug
);

# display resulting values of variables
print <<EOF;
Verbose:        $verbose
All:            $all
More:           $more
Diameter:       $diam
Debug:          $debug
Libs:           @{[ join ',', @libs ]}
Flags:          @{[ join "\n\t\t", map { "$_ = $flags{$_}" }each  %flags ]}

Remaining:      @{[ join ',', @ARGV ]}
  (ARGV contents)
EOF

#######################################################################
###
# the commandline
#perl Getopt_LongTest.pl -l abc -l def -f a=b -f b=c -ev -de 5 -nomore arg

######################################################################
###
#

=head the result
Verbose:        0
All:            1
More:           0
Diameter:       3.1415
Debug:          5
Libs:           abc,def
Flags:          a = b
		b = c

Remaining:      arg
  (ARGV contents)

=cut
