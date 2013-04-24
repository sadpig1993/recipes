package Util::MSNBot;

use Net::MSN;
use POSIX;
use IO::Select;
use Util::IniParse;

#
#  Util::MSNBot->new(
#    logger  =>  $logger
#    mconf   =>  mconf_file
#  )
# 
# mconf format 
#------------------------------------------
#[msnbot]
#debug_log = $HOMT/tmp/msn.debug
#admin     = robinzhou986@hotmail.com
#operator  = wjia.113@hotmail.com
#username  = hary_test@hotmail.com
#password  = jessie
#
#
sub new {

  my $class  = shift;
  my $args   = { @_ };

  my $logger = $args->{'logger'};
  my $config = ini_parse($args->{'mconf'});
  unless($config) {
    $logger->error("ini_parse" $args->{'mconf'}, "failed");
    return undef;
  }

  my %msn_dat;

  my $msn = new Net::MSN(
    Debug           =>  1,    # Debug or not 
    Debug_Lvl       =>  3,    # Debug level
    Debug_STDERR    =>  1,    # stderr 
    Debug_LogCaller =>  1,
    Debug_LogTime   =>  1,
    Debug_LogLvl    =>  1,
    Debug_Log       =>  $config->{'debug_log'},
  );

  $msn->set_event(
    on_connect => \&on_connect,   #
    on_status  => \&on_status,    # 
    on_answer  => \&on_answer,    #
    on_message => \&on_message,   # 
    on_join    => \&on_join,      # 
    on_bye     => \&on_bye,       #
    auth_add   => \&auth_add      #
  );

  unless($msn->connect($config->{'username'}, $config->{'password'})) {
    $logger->error("can not connect with username[", $config->{'username'},
                                       "] pasword[", $config->{'password'}, "]");
    return undef;
  }

  $msn_dat{'admin'}     = [split ',', $config->{'admin'}   ];
  $msn_dat{'operator'}  = [split ',', $config->{'operator'}];
  $msn_dat{'user'}      = $config->{'username'};
  $msn_dat{'pass'}      = $config->{'password'};
  $msn_dat{'msn'}       = $msn;
  $msn_dat{'logger'}    = $logger;

  bless \%msn_dat, $class;

}

#
# 执行  
#
sub run {
  my $self = shift;
  $self->{'msn'}->check_event();
}

############################################
# 预定义callback
############################################
sub on_connect {
   $client->{_Log}("Connected to MSN @ ". $client->{_Host}. ':'.
   $client->{Port}. ' as: '. $client->{ScreenName}.
    ' ('. $client->{Handle}. ")", 3);

}

sub on_message {
}

sub on_join {
}

sub on_bye {
}

sub on_status {
}

1;

__END__

=head1 NAME


=head1 SYNOPSIS


=head1 API


=head1 Author & Copyright


=cut

