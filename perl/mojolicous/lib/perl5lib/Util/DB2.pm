package Util::DB2; 

use strict;
use warnings;
use DBI;
use Util::IniParse;
use Util::Log;
use File::Basename;
use Carp qw/cluck/;

#
#  usage: Util::DB->new( 
#    'db_conf' => '/file/of/db.conf',
#    'use'     => { 'table1' => [ op1, op2, op3], 'table2' => [op1, op2, op3]  }
#    'except'  => { 'table1' => [ op1, op2     ], 'table2' => [ op1, op2    ]  }
#  );
#---------------------------
#  db.conf format
#---------------------------
# [~dbconfig]
# dsn      = dbi:DB2:zdb_dev
# dbpass   = haryinst
# schema   = haryinst
# include  = table.d/*
# 
#
sub new {
    
    my $class = shift;
    my $args  = { @_ };
    
    my $self = bless {}, $class;
    
    defined $args->{db_conf} || die "db_conf undefined";
    -f $args->{db_conf}      || die  "$args->{db_conf} does not exist";
    
    # 初始化
    $self->_init($args->{'db_conf'}, $args->{'use'}, $args->{'except'});
    
    return $self;
}




#
# 通过配置文件增加操作
# [table]
# op1 = select * from table
# op2 = select * from table
# op3 = select * from table
#
# @parameters:
#   $file:    文件名称
#   $use:     使用哪些op
#   $ex:      不使用哪些op
#
sub add_config_file {

  my $self = shift;
  my ($file, $use, $ex)  =  @_;
  $self->_init_file($file, $use, $ex);
  return $self;

}


#
#  通过sql语句增加操作
#  table_a =>  {  op1 => 'select * from tbl_abcd', op2 => 'insert blah....' },
#  table_b =>  {  op1 => 'select * from tbl_abcd', op2 => 'insert blah....' },
#
sub add_config_sql {

    my $self   = shift;
    my $config = { @_ };
    
    for my $tbl ( keys %$config) {
        $self->_init_table("\@$tbl", $config->{$tbl}, undef, undef);
    }
    
    return $self;
}


#
# db preparation
#-------------------------------------
# dbc_file : shift['db.conf']
# use      : shift[{ tbl => [op1, op2,....], tblx => [] }]
# execept  : shift[{ tbl => [op1, op2,....], tblx => [] }]
#
sub _init {

  my $self      = shift;
  my $dbc_file  = shift;
  my $use       = shift;
  my $except    = shift;

  # 解析db.conf配置文件 
  my $dbc = ini_parse($dbc_file) or die "can not parse file $dbc_file";

  ###################################
  # ~dbconfig 节包含数据库连接信息  
  ###################################
  my $config = delete $dbc->{'~dbconfig'};
  $config->{schema} = $ENV{DB_SCHEMA} if $ENV{DB_SCHEMA};  # use env if set
  
  my $dbh = DBI->connect(
    $config->{'dsn'},
    $config->{'dbuser'},
    $config->{'dbpass'},
    {
      RaiseError  => 1,
      PrintError  => 1,
      PrintWarn   => 0,
      AutoCommit  => 0,
      ChopBlanks  => 1,
    },
  ) or die "can not connect to $config->{'dsn'}";
  $self->{'dbh'}  = $dbh;
 

  # 设置当前模式 
  if (exists $config->{'schema'}) {
    $dbh->do("set current schema $config->{'schema'}") 
      or die "can not set schema";
  }

  return $self if $use && not %$use; # 用哪些操作, %use为空

  my $sth;
  for my $secname (keys %{$dbc}) {

    my $section = $dbc->{$secname};

    if ( $secname =~ /^@(.*)/) {
      next if $use && not exists $use->{$1};
      $self->_init_table($secname, $section, $use, $except);
    }
    elsif ($secname =~ /^%/) {
      # todo     
    } 
    else {
      next;
    }
  }

  #########################################
  # ~dbconfig节的 include字段包含子配置文件 
  #########################################
  my $include = $config->{'include'};
  if ($include) {
    my $dir = dirname($dbc_file);
    my @files; 
    $_ = $include;
    for (split) { push @files, <$dir/$_>; }
    for my $file (@files) { $self->_init_file($file, $use, $except); }
  }
  return $self;

}

#
# sub configuration
#
sub _init_file {

  my $self     = shift;
  my $dbc_file = shift;
  my $use      = shift;
  my $except   = shift;

  # 解析db.conf配置文件 
  my $dbc = ini_parse($dbc_file);

  for my $secname (keys %{$dbc}) {
   
    my $section = $dbc->{$secname};
    #
    # table initialization
    #
    if ( $secname =~ /^@(.*)/) {
      next if $use && not exists $use->{$1};
      $self->_init_table($secname, $section, $use, $except);
    } 
  }
  return $self;

}



#
#  $tbl_name
#  $tbl hash
#
sub _init_table {

  my $self     = shift;
  my $tbl_name = shift;
  my $tbl      = shift;
  my $use      = shift;
  my $except   = shift;

  my $dbh      = $self->{'dbh'};

  # [@tbl_name]
  # c = insert into tbl_name values(?,?,?)
  # r = select * from tbl_name
  # u = update tbl_name set field1 = ? where field2 = ?
  # d = delete from tbl_name where field1 = ?

  my %use_op;
  if ($use) {
    $tbl_name =~ /^@(.*)/;
    my $ops = $use->{$1};
    for (@$ops) {
      $use_op{$_} = 1;
    }
  }

  my %except_op;
  if ($except) {
    $tbl_name =~ /^@(.*)/;
    my $ops = $except->{$1};
    for (@$ops) {
      $except_op{$_} = 1;
    }
  }

  for my $op (keys %{$tbl})  {
    next if %use_op    && not exists $use_op{$op};
    next if %except_op && exists $except_op{$op};
    $self->{'table'}->{$tbl_name}->{$op}->{'sth'} = $dbh->prepare($tbl->{$op}) or die "can not prepare sqlcode[" . $self->{dbh}->err() . "]";
    $self->{'table'}->{$tbl_name}->{$op}->{'sql'} = $tbl->{$op};
  }

  return $self;
}


#
# [@tbl_name]
# op = select/insert/update/delete blah...
#
sub execute {

  my $self     = shift;
  my $tbl      = shift;
  my $op       = shift;
  my @op_param = @_;

  $tbl = '@' . $tbl;
  my $sth = $self->{'table'}->{$tbl}->{$op}->{'sth'} or die "$tbl.$op does not exist";

  # debug info
  if ( @op_param) {
    $sth->execute(@op_param) or die "can not execute $tbl.$op: @op_param  sqlcode[" . $self->{dbh}->err() . "]";
  } else {
    $sth->execute() or die "can not execute $tbl.$op [@op_param] sqlcode[" . $self->{dbh}->err() . "]";
  }
  return $sth;

}



#
# 获取指定表的指定操作的statement handle
#
sub sth {
  my $self = shift;
  my $tbl  = shift;
  my $op   = shift;
  return $self->{'table'}->{'@' . $tbl}->{$op}->{'sth'};
}

#
# 获取指定表的指定操作的statement的sql语句 
#
sub sql {
  my $self = shift;
  my $tbl  = shift;
  my $op   = shift;
  return $self->{'table'}->{'@' . $tbl}->{$op}->{'sql'};
}

#
# 开始事物  
#
sub begin_work {
  my $self = shift;
  eval { 
    $self->{'dbh'}->begin_work(); 
  }; 
  die "can not begin_work: $@" if $@;
  return $self;
}

#
# 数据库提交  
#
sub commit {
  my $self = shift;
  $self->{'dbh'}->commit() or die "commit failed[$@]";
  return $self;
}

#
# 数据库回滚  
#
sub rollback {
  my $self = shift;
  $self->{'dbh'}->rollback() or die "can not rollback, sqlcode[" . $self->{dbh}->err() . "]";
  return $self;
}

#
# 断开到数据库连接 

sub disconnect {

  my $self = shift;
  unless($self->{'dbh'}) {
    return undef;
  }

  $self->finish();
  $self->rollback();

  $self->{'dbh'}->disconnect or die "can not disconnect, sqlcode[" . $self->{dbh}->err() . "]";
  delete $self->{'dbh'};

  return $self;

}


sub finish {

  my $self = shift;

  my $tbls = $self->{'table'};

  my $aec = 0; # all error count
  for my $t ( keys %{$tbls}) {
    my $ops = $tbls->{$t};
    for my $op (keys %{$ops}) {
      $ops->{$op}->{'sth'}->finish();
    }   
  }
  if ($aec) {
    return undef;
  }

  return $self;
}


#
# name hash of a table
#
sub nhash {
  my $self = shift;
  my $tbl  = shift;
  my $sth = $self->{dbh}->prepare(qq/select * from $tbl/) or die "can not prepare, sqlcode[" . $self->{dbh}->err() . "]";
  return $sth->{NAME_hash};
}



sub DESTROY {

  my $self = shift;
  if( $self->{'dbh'} ) {
    $self->finish();
    $self->rollback();
    eval { $self->{'dbh'}->disconnect };
    $self->{'dbh'} = undef;
  }
  $self->{'db'} = undef;
}

1;

__END__

=head1 SYNOPSYS
  
  Util::DB - A simple wrapper for DBI

  #!/usr/bin/perl -w
  use strict;
 
  my $db = Util::DB->new(
  );

  my $sth = $db->execute('tbl_txn_log_a', 'read', $arg1, $arg2);
  while($sth->fetchrow_hashref()) {
  }

  $db->disconnect();
  exit 0;
  

=head1 API

  new             :
  add_config_file :
  add_config_sql  :
  sqlcode         :
  execute         :
  sth             :
  sql             :
  begin_work      :
  commit          :
  rollback        :
  disconnect      :
  finish          :

=cut

