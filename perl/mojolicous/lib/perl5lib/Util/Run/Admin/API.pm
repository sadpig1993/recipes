package Util::Run::Admin::API;

use strict;
use warnings;

use Util::Run;

###########################################################
#  administraton API
###########################################################
sub admin_api {

  my $class  = shift;
  my $proc   = shift;
  my $decode = shift;

  my $config;
  my $errmsg;
  
  if ($decode ) {
    $config = eval $decode;
    if($@) {
      $errmsg = "eval error $@";
      goto FAIL;
    }
  }
  $run_kernel->{logger}->debug("admin_api got proc[$proc] config\n" .  Data::Dump->dump($config));

  $proc = "admin_$proc";
  $run_kernel->{logger}->debug("begin call $class : $proc with:");
  {
    no strict;
    return $class->$proc($config);
  }

FAIL:
  return {
    'status' => 1,
    'errmsg' => $errmsg,
  };
}

#
#
#
sub admin_show {

  my $class = shift;
  my %out;

  $run_kernel->{logger}->debug("admin_show...");
  $out{'status'} = 0;
  $out{'errmsg'} = $run_kernel;

  return \%out;

}

#
# {
#   'name' => Zbat_reader
# }
#
sub admin_stop_module {

  my $class  = shift; 
  my $config = shift;

  my %out;
  my $errmsg;

  my $name  = $config->{'name'};
  $run_kernel->{logger}->debug("admin_stop_module: $name...");

  for (keys %{ $run_kernel->{running}} ) {
    next unless /^$name/;
    $run_kernel->{stopped}->{$_} = delete $run_kernel->{running}->{$_};
    my $pid = $run_kernel->{stopped}->{$_}->[0];
    $run_kernel->{logger}->warn("begin stop $_ pid[$pid]");
    kill 'TERM', $pid;
  }

  $out{'status'} = 0;
  return \%out;

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
  
}

#
#
#
sub admin_stop_all {

  my $class  = shift; 
  my $config = shift;

  my $old = $SIG{CHLD};
  $SIG{'CHLD'} = 'IGNORE';
  for my $kn (keys %{$run_kernel->{running}}) {
    if ($kn =~ /$run_kernel->{logname}/ ) {  
      next;
    }
    $run_kernel->{stopped}->{$kn} = delete $run_kernel->{running}->{$kn};
    my $pid = $run_kernel->{stopped}->{$kn}->[0];
    $run_kernel->{logger}->warn("begin kill process[$pid] name[$kn]...");
    kill 'TERM', $pid;
  }
  $SIG{'CHLD'} = $old;

  return { 'status' => 0, };

}

#
# already existing pacakge
#
sub admin_add_module_package {

  my $config = shift;
  my $code = $config->{'code'};

  $run_kernel->{logger}->debug("admin_add_module_package: $code...");

  unless($code =~ /^(.*)\s+(\w+)\s*\|(.*)/ ) {
    $run_kernel->{logger}->debug("invalid mcode[$code]");
    return undef;
  }
  my ($pkg, $handler, $arglist ) = ($1, $2, $3);
  eval "use $pkg;";
  if ($@) {
    $run_kernel->{logger}->debug("load $pkg failed[$@]");
    return undef;
  }
  my @args;
  if ($arglist) {
    $arglist =~ s/^\s+//;
    $arglist =~ s/\s+$//;
    @args = split '\s+', $arglist;
    $run_kernel->{logger}->debug("package[$pkg] handler[$handler] arglist[@args]...");
  } else {
    $run_kernel->{logger}->debug("package[$pkg] handler[$handler]...");
  }
  eval "use $pkg;";
  if ($@) {
    $run_kernel->{logger}->error("can't load package $pkg reason[$@]");
    return undef;
  }
  my $obj = $pkg->new(@args);
  unless($obj) {
    $run_kernel->{logger}->error("can not $pkg new");
    return undef;
  }
  $config->{'code'} = sub { $obj->$handler($config->{para}); };

  return $config;
}

#
# already existing kids with new parameter: name, para, channel
#
sub admin_add_module_have {

  my $config = shift;
  my $code   = delete $config->{'code'};

  $run_kernel->{logger}->debug("admin_add_module_have...");

  my %new_arg;
  my $have_arg;

  #
  # check stopped
  #
  if( exists $run_kernel->{stopped}->{$code} ) {
    $have_arg = $run_kernel->{stopped}->{$code}->[1];
  }
  elsif( exists $run_kernel->{stopped}->{$code .".0"} ) {
    $have_arg = $run_kernel->{stopped}->{$code}->[1];
  }

  #
  # check kids
  #
  elsif( exists $run_kernel->{running}->{$code} ) {
    $have_arg = $run_kernel->{running}->{$code}->[1];
    next;
  }
  elsif( exists $run_kernel->{running}->{$code .".0"} ) {
    $have_arg = $run_kernel->{stopped}->{$code}->[1];
  }

  #
  # not found
  #
  else {
    return undef;
  }
 
  ############################ 
  %new_arg  = %$have_arg;
  $new_arg{para} = $config->{'para'};
  $new_arg{name} = $config->{'name'};
  $new_arg{size} = $config->{'size'} if exists $config->{'size'};
  $new_arg{type} = $config->{'type'} if exitts $config->{'type'}; 

  my $have_pref = ref $have_arg->{'para'};
  my $new_pref  = ref $new_arg{'para'};
  if ($have_pref ne $new_pref) {
    $run_kernel->{logger}->error("new_pref is not equal to have_pref");
    return undef;
  }
  return \%new_arg;

}

#
#
#
sub admin_add_module_ext {

  my $config = shift;
  my $code = $config->{'code'};

  $run_kernel->{logger}->debug("admin_add_module_ext : $code...");

  unless( -f $code ) {
    $run_kernel->{logger}->error("file[$code] does not exists");
    return undef;
  }

  unless( -x $code ) {
    $run_kernel->{logger}->error("file[$code] is not executable");
    return undef;
  }

  return $config;
}


#
#  ctype => package  : use already existing package
#           have     : use already existing modules but with new arguments
#           external : use already existing external programme
#  code  =>
#  para  =>
#  name  =>
#  type  =>
#  size  =>
#  reap  =>
#
sub admin_add_module {

  my $class  = shift;
  my $config = shift;

  my %out;
  my $errmsg;

  my $type = $config->{'type'};
  my $name = $config->{'name'}; 

  $run_kernel->{logger}->debug("admin_add_module : $name...");

  ##############################
  # check module name
  ##############################
  if ( exists $run_kernel->{running}->{$name}       ||
       exists $run_kernel->{running}->{"$name.0"}   ||
       exists $run_kernel->{stopped}->{"$name"}  ||
       exists $run_kernel->{stopped}->{"$name.0"} ) {
    $errmsg = "module $name already exists, reassign a module name";
    goto FAIL;
  }

  ##############################
  # check channel type
  ##############################
  unless($type =~ /^(p2c|c2p|pc|no)$/) {
    my ($gtype, $ptype) = (split '\|', $type )[0,1];
    unless(exists $run_kernel->{channel}->{$gtype} ) {
      $errmsg = "module[$name] invalid type[$gtype]";
      goto FAIL;
    }    
  }     

  # module by default is restartable
  unless( exists $config->{'reap'} ) {
    $config->{'reap'} = 1;
  }

  my $ctype = $config->{'ctype'};
  my $para  = $config->{'para'};
  my $pref  = ref $config->{'para'};

  ##############################
  # regen config according ctype
  ##############################
  if( $ctype =~ /^external$/) {
    $config = &admin_add_module_ext($config);
    unless($pref =~ /ARRAY/) {
      $errmsg = "external module para must be array ref";
      goto FAIL;
    }
  }
  elsif ($ctype =~ /^package/) {
    $config = &admin_add_module_package($config);
    unless($pref =~ /HASH/) {
      $errmsg = "package module  para must be hash ref";
      goto FAIL;
    }
  }
  elsif( $ctype =~ /^have$/) {
    $config = &admin_add_module_have($config);
  }
  else {
    $errmsg = "unsupported ctype[$ctype]";
    goto FAIL;
  }

  unless( $config) {
    $errmsg = "admin_add_module_xxx failed";
    goto FAIL;
  }

  ##############################
  # begin start module...
  ##############################
  my $child;
  if( exists $config->{'size'} && $config->{size} > 1 ) {
    $child = &batch_child($config);
    unless($child) {
      $run_kernel->{logger}->debug("batch_child failed");
      return undef;
    }
  }    
  else {
    $child = $run_kernel->new_child($config);
    unless($child) {
      $run_kernel->{logger}->debug("new_child failed");
      return undef;
    }
  } 
  $out{'status'} = 0;
  return \%out;

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return  \%out;
}

#
# name =>  module name
#
sub admin_del_module {

  my $class  = shift;
  my $config = shift;

  my %out;
  my $errmsg;

  my $name = $config->{'name'};
  $run_kernel->{logger}->debug("admin_del_module : $name...");
  unless($name) {
    $errmsg = "module[$name] is null";
    goto FAIL;
  }

  for my $kn (keys %{$run_kernel->{running}} ) {
    if ($kn =~ /^$name/) {
      my $m = delete $run_kernel->{running}->{$kn};
      my $pid = $m->[0];
      my $arg = $m->[1];
      $arg->{reap} = 0;
      kill 'TERM', $pid;
    }
  }

  for my $kn (keys %{$run_kernel->{stopped}}) {
    if ($kn =~ /^$name/) {
      delete $run_kernel->{stopped}->{$kn};
    }
  }
  return { status => 0 };

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
}

#
#
#
sub admin_del_all {

  my $class = shift;

  $run_kernel->{logger}->debug("admin_del_all...");

  for ( keys %{$run_kernel->{stopped}}) {
    $run_kernel->{logger}->debug("begin delete stopped[$_]");
    delete $run_kernel->{stopped}->{$_};
  }

  for ( keys %{$run_kernel->{running}} ) {
    next if /$run_kernel->{logname}/;
    my $m = delete $run_kernel->{running}->{$_};
    my $pid = $m->[0];
    $run_kernel->{logger}->debug("begin kill $_ pid[$pid]");
    kill 'TERM', $pid;
  }

  return { 'status' => 0, };

}

#
#
#
sub admin_add_channel {

  my $class  = shift;
  my $config = shift;

  my %out;
  my $errmsg;

  my $name = $config->{'name'};
  my $type = $config->{'type'};

  $run_kernel->{logger}->debug("admin_add_channel : $name => $type...");

  Util::Run->add_channel($name, $type);

  return { status => 0 };

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
}

#
#
#
sub channel_can_del {
  my $name = shift;

  my $chan = $run_kernel->{channel}->{$name};

  my $chan_p = $chan->{'chan_c'};
  
  for (keys %{$run_kernel->{stopped}}) {
    next if $run_kernel->{stopped}->{$_}->[1]->{'type'} =~ /^no$/;
    my $tchan_c = $run_kernel->{stopped}->{$_}->[1]->{'chan_c'};
    my $tchan_p = $run_kernel->{stopped}->{$_}->[1]->{'chan_p'};
    if ($chan_p == $tchan_p || $chan_p == $tchan_c ) {
      $run_kernel->{logger}->debug("channel[$name] still in use by stopped process[$_]");
      return undef;
    }
  }
  
  for (keys %{$run_kernel->{running}} ) {
    next if $run_kernel->{running}->{$_}->[1]->{'type'} =~ /^no$/;
    my $tchan_c = $run_kernel->{running}->{$_}->[1]->{'chan_c'};
    my $tchan_p = $run_kernel->{running}->{$_}->[1]->{'chan_p'};
    if ($chan_p == $tchan_p || $chan_p == $tchan_c ) {
      $run_kernel->{logger}->debug("channel[$name] still in use by kids[$_]");
      return undef;
    }
  }

  return 1;
  
}

#
#
#
sub admin_del_channel {

  my $class = shift;
  my $config  = shift;

  my %out;
  my $errmsg;

  my $name = $config->{'name'};

  $run_kernel->{logger}->debug("admin_del_channel : $name");

  unless( &channel_can_del($name) ) {
    $errmsg = "channel[$name] can not be deleted";
    goto FAIL;
  }

  delete $run_kernel->{channel}->{$name};
  $out{'status'} = 0;
  return \%out;

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
}

#
# delete all deleteable channels
#
sub admin_del_all_channel {
  my $class = shift;
  for ( keys %{$run_kernel->{channel}} ) {
    unless( &channel_can_del($_) ) {
      $run_kernel->{logger}->debug("channel[$_] can not be deleted");
      next;
    }
    delete $run_kernel->{channel}->{$_};
  }

  return { 'status' => 0 };
}

#
#
#
sub admin_start_module {
  my $class  = shift;
  my $config = shift;

  my %out;
  my $errmsg;
  my $name = $config->{'name'};

  $run_kernel->{logger}->debug("admin_start_module : $name...");

  for ( keys %{$run_kernel->{stopped}} ) {
    next unless /^$name/;
    my $m = delete $run_kernel->{stopped}->{$_};
    $run_kernel->{running}->{$_} = $m;
    $run_kernel->{logger}->info("begin start process $_...");
    unless($run_kernel->new_child($m->[1])) {
      $errmsg = "start proces[$_] failed";
      goto FAIL;
    }
  }
  return { status => 0 };

FAIL:
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;

}

#
#
#
sub admin_restart_module {

  my $class  = shift;
  my $config = shift;

  my %out;
  my $errmsg;

  my $name = $config->{'name'};
  $run_kernel->{logger}->debug("admin_restart_module : $name");

  for my $kn (keys %{$run_kernel->{running}} ) {
    if ($kn =~ /^($name|$name\.\d+)/) {
      my $pid = $run_kernel->{running}->{$kn}->[0];
      my $arg = $run_kernel->{running}->{$kn}->[1];
      $arg->{reap} = 1;
      $run_kernel->{logger}->info("begin restart process $kn...");
      kill 'TERM', $pid;
    }
  }
  $out{'status'} = 0;
  return \%out;

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
}

sub admin_start_all {

  my $class = shift;
  my %out;
  my $errmsg;
  for my $kn (keys %{$run_kernel->{stopped}} ) {
    my $m = delete $run_kernel->{stopped}->{$kn};
    unless($run_kernel->new_child($m->[1])) {
      $errmsg = "restart $kn failed";
      goto FAIL;
    } 
  }
  return { 'status' => 0, };

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
}

sub admin_restart_all {

  my $class = shift;

  $run_kernel->{logger}->debug("admin_restart_all...");

  my %out;
  my $errmsg;

  for my $kn (keys %{$run_kernel->{running}} ) {

    next if $kn =~ /$run_kernel->{logname}/;
    my $pid = $run_kernel->{running}->{$kn}->[0];
    my $arg = $run_kernel->{running}->{$kn}->[1];
    if ($arg->{'reap'} ) {
      $run_kernel->{logger}->info("begin restart process $kn...");
      kill 'TERM', $pid;
    }
  }

  $out{'status'} = 0;
  return \%out;

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
}

#
#
#
sub admin_shutdown {

  my $class = shift;

  $run_kernel->{logger}->debug("admin_shutdown...");

  my %out;
  my $errmsg;

  my $old = $SIG{CHLD};
  $SIG{CHLD} = 'IGNORE';  # 

  for (keys %{$run_kernel->{running}} ) {
    next if /$run_kernel->{logname}/;
    my $kid = delete $run_kernel->{running}->{$_}; 
    my $pid  = $kid->[0];
    my $args = $kid->[1];
    $args->{'reap'} = 0;
    $run_kernel->{logger}->debug("begin kill $_ pid[$pid]...");
    kill 'TERM', $pid;

  }
  $SIG{CHLD} = $old;
  return  { 'status' => 0 };

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
}

#
# 增加资源 
#
sub admin_add_context {

  my $class  = shift;
  my $config = shift;

  my %out;
  my $errmsg;
  my $rtn;

  my $name  = $config->{'name'};
  my $value = $config->{'value'};
  my $type  = $config->{'type'};

  $run_kernel->{logger}->debug("admin_add_context : $name => $value...");

  #
  # 对象类型资源:   My::Package arg1 arg2 arg3
  #
  if (defined $type && $type =~ /^object/) {

    my ($pkg, @args) = split '\s+', $value;
    $run_kernel->{logger}->debug("begin load pkg[$pkg] and new with[@args]");
    eval "use $pkg;";
    if ($@) {
      $errmsg = "can not load package $pkg";
      $run_kernel->{logger}->error($errmsg);
      goto FAIL;
    }
    my $obj = $pkg->new(@args);
    unless($obj) {
      $errmsg = "can not $pkg new";
      $run_kernel->{logger}->error($errmsg);
      goto FAIL;
    }

    unless($run_kernel->add_context($name, $obj)) {
      $errmsg = "can not add_context($name, $value)";
      $run_kernel->{logger}->error($errmsg);
      goto FAIL;
    }
  }
  #
  # 标量类型资源 
  #
  else {
    unless($run_kernel->add_context($name, $value)) {
      $errmsg = "can not add_context($name, $value)";
      $run_kernel->{logger}->error($errmsg);
      goto FAIL;
    }
  }

  return  { 'status' => 0 };

FAIL:
  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
}

#
# 删除资源  
#
sub admin_del_context {

  my $class  = shift;
  my $config = shift;

  my %out;
  my $errmsg;

  my $name = $config->{'name'};
  $run_kernel->{logger}->debug("admin_del_context : $name");
  unless($run_kernel->del_context($name)) {
    $errmsg = "del_context $name failed";
    goto FAIL;
  }
  return  { 'status' => 0 };

FAIL:

  $run_kernel->{logger}->error($errmsg);
  $out{'status'} = 1;
  $out{'errmsg'} = $errmsg;
  return \%out;
  
}


1;

__END__

head1 NAME

=head1 SYNOPSIS


=head1 DESCRIPTION

admin_api
admin_show
admin_stop_module
admin_stop_all
admin_start_module
admin_restart_module
admin_start_all
admin_restart_all
admin_shutdown

admin_add_module_package
admin_add_module_have
admin_add_module_ext
admin_add_module
admin_del_module
admin_del_all

admin_add_channel
admin_del_channel
admin_del_all_channel

admin_add_context
admin_del_context

channel_can_del

=over 4

=back

