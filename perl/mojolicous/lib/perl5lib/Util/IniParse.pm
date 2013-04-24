package Util::IniParse;

use strict;
use warnings;

use base qw /Exporter/;

our @EXPORT = qw /ini_parse ini_parse_sect /;   # default epxort

sub ini_parse {

   my ($conf) = @_;
   unless($conf && -f $conf) {
     return undef;
   }

   my $cur_line = 0;
   my $valid_line = 0;
   my $cur_section;
   my $cur_key;
   my $cur_val;
   my $mul = 0;

   my $ini = {};

   die "[ERROR] config file ($conf) not exist: $!" unless -e $conf;

   open(CONF, '<', $conf) or die "[ERROR] can not open file ($conf): $!";

   while (<CONF>) {
      $cur_line ++;
      chomp;
    
      # 多行值状态  
      if($mul) { 
        s/^\s+//; 
        if( /\\$/ ) {    #  遇到普通行 adfadfafd \
          s/\\//;
          $cur_val .= $_;
        } else {         #  遇到普通行 adfadfafd, 多行值最后一行  
          $cur_val .= $_;
          $cur_val =~ s/\s+/ /g;
          $ini->{$cur_section}->{$cur_key} = $cur_val;
          $mul = 0;   # 结束多行状态  
          next;
        }
        next;
      }

      if ( /^([^\#]+)/ ) {
         $_ = $1;
      }
      s/^\s+//g;     # 行首空格 
      s/\s+$//g;     # 行尾空格 

      next if /^$/ or /^#/;   #  空行或是注释行不管 

      # last if $valid_line++ > 200;

      # 遇到[section]
      if (/^\[(.*)\]$/) {
         $cur_section = $1;   # 获得当前section 
         next;
      }

      # 遇到 key = val
      if (/^([^\=]+)=(.*)$/) {  # 获得key = val行 
         die "[ERROR] no section config file ($conf)!" unless defined $cur_section;
         $cur_key = $1;
         my $val = $2;

         $cur_key =~ s/^\s+//g;
         $cur_key =~ s/\s+$//g;
         $cur_key =~ s/^\t+//g;
         $cur_key =~ s/\t+$//g;

         $val =~ s/^\s+//g;
         $val =~ s/\s+$//g;
         $val =~ s/^\t+//g;
         $val =~ s/\t+$//g;
         if( $val =~ /\\/ ) {   # 遇到 key = val \   多行值开始 
            $cur_val = $val;
            $cur_val =~ s/\\$//;
            $mul = 1;
            next;
         } else {              # 遇到  key = val
            $ini->{$cur_section}->{$cur_key} = $val;
            $mul = 0;
            next;
         }
      }

       
   }

   close(CONF) or die "[ERROR] can not close file ($conf): $!";

   return $ini;
}

sub ini_parse_sect {
    
  my $conf = shift;
  my $sect = shift;
  my $config = ini_parse($conf);
  return $config->{$sect};
  
}

sub subs_env {

    my $str = shift;
    my @part = split '\/', $str;
    for (@part) {
        if(/^\$/) {
            # warn "begin substitute $_...";
            eval "use Env qw/$_/";
            $_ = eval $_;
        }
    }
    return join '/', @part;

}

1;

__END__

=head1 NAME


=head1 SYNOPSIS


=head1 API


=head1 Author & Copyright

  zcman2005@gmail.com

=cut


