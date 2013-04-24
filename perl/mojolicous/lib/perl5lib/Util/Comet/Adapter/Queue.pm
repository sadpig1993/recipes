package Util::Comet::Adapter::Queue;
use base qw/Util::Comet::Adapter/;
use Util::Wheel::Queue;

#
# send wheel
#
sub _send_wheel {

    my $class  = shift;
    my $heap   = shift;
    my $writer = shift;

    # $heap->{logger}->debug("begin create Util::Wheel::Queue...");
    my $w = Util::Wheel::Queue->new( $writer );
    unless ($w) {
        $heap->{logger}->error("Util::Wheel::Queue->new($writer) error");
        return undef;
    }
    return $w;
}


1;
