#!perl
use Data::Dump;

my %hash;
while(<DATA>) {

    #  取得合法似乎据
    s/^\s+|\s+$//g;
    next if /^$/;

    warn "$_";

    # non-space line
    my ($key, @e) = split;
    for (@e) {
        next unless /(\w+)_(\w+)=(\d+)/;
        $hash{$key}{$1}{$2} += $3; 
    }
}

Data::Dump->dump(\%hash);

#
#
#  sort map split  grep ..... slice  :
#
#

__END__
A      BUS_x=1      BUS_y=2   BUS_z=3   BUS_t=1  Z_u=3

B      BUS_x=1      BUS_y=2   BUS_z=3  
A      BUS_x=1      BUS_y=2   BUS_z=3   Z_u=4

