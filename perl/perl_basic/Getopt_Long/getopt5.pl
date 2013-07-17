##################################
#Options with hash values
##################################

#!/usr/bin/env perl

use Getopt::Long;
use strict;
use warnings;

#If the option destination is a reference to a hash, the option will take, as value, strings of the form key= value. The value will be stored with the specified key in the hash.

################ demo 1 ###############
=p
my %defines;
my @k;
my @v;
GetOptions ("define=s" => \%defines);
@k = keys %defines;
@v = values %defines;
print <<EOF;
define	:	@k	@v
EOF
=cut

#Alternatively you can use:

################ demo 1 ###############
my $defines;
GetOptions ("define=s%" => \$defines);
my @k = keys %{$defines};
my @v = values %{$defines};
print <<EOF;
define	:	@k	@v
EOF

#When used with command line options:

#    --define os=linux --define vendor=redhat

#the hash %defines (or %$defines ) will contain two keys, "os" with value "linux" and "vendor" with value "redhat" . It is also possible to specify that only integer or floating point numbers are acceptable values. The keys are always taken to be strings.
