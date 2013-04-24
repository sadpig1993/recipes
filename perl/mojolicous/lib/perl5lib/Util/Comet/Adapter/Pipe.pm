package Util::Comet::Adapter::Pipe;
use base qw/Util::Comet::Adapter/;
use Util::Wheel::Block;

#
# send wheel
#
sub _send_wheel {

    my $class  = shift;
    my $heap   = shift;
    my $writer = shift;

    my $w = Util::Wheel::Block->new( handle => $writer );
    unless ($w) {
        $heap->{logger}->error("Util::Wheel::Block->new error");
        return undef;
    }
    return $w;
}

1;

