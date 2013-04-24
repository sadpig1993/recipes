package Util::DB; 

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
#    'logger'  => $logger,
#    'use'     => { 'table1' => [ op1, op2, op3], 'table2' => [op1, op2, op3]  }
#    'except'  => { 'table1' => [ op1, op2 ], 'table2' => [ op1, op2 ],        }
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
    
    # 如果没有logger， 就从stderr生成logger
    $self->{logger} = $args->{logger};
    $self->{logger} ||= Util::Log->new(
        logurl   => 'stderr',
        loglevel => 'ERROR',
    );
    
    # 配置文件检查
    unless( defined $args->{db_conf}) {
        cluck "db_conf undefined";
        return undef;
    }
    
    # 配置文件检查
    unless( -f $args->{db_conf}) {
        cluck "$args->{db_conf} does not exist";
        return undef;
    }
    
    # 初始化
    unless( $self->_init($args->{'db_conf'}, $args->{'use'}, $args->{'except'}) ) {
        cluck "_init failed with:\n" . Data::Dump->dump($args);
        return undef;
    }
    
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

  unless($self->_init_file($file, $use, $ex)) {
    cluck "add_config_file error with:\n" . Data::Dump->dump(\@_);
    return undef;
  }
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
        unless($self->_init_table("\@$tbl", $config->{$tbl}, undef, undef)) {
            $self->{logger}->error("_init_table[$tbl] error");
            return undef; 
        }
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
  my $dbc = ini_parse($dbc_file);
  unless($dbc) {
    cluck "can not parse file $dbc_file";
    return undef;
  }

  ###################################
  # ~dbconfig 节包含数据库连接信息  
  ###################################
  my $config = delete $dbc->{'~dbconfig'};
  $config->{schema} = $ENV{DB_SCHEMA} if $ENV{DB_SCHEMA};  # use env if set
  
  $self->{logger}->info('begin connect to database...');
  my $dbh = DBI->connect(
    $config->{'dsn'},
    $config->{'dbuser'},
    $config->{'dbpass'},
    {
      RaiseError  => 0,
      PrintError  => 0,
      PrintWarn   => 0,
      AutoCommit  => 0,
      ChopBlanks  => 1,
    }
  );
  unless($dbh) {
    cluck "can not connect to $config->{'dsn'}";
    return undef;
  }
  $self->{'dbh'}  = $dbh;
 

  # 设置当前模式 
  $self->{logger}->debug("beg set schema to $config->{'schema'}...");
  if (exists $config->{'schema'}) {
    
    eval {$dbh->do("set current schema $config->{'schema'}") };
    if( $@) {
      $self->{sqlcode} = $dbh->err;
      $self->{logger}->error("end set schema to $config->{'schema'} sqlcode[$self->{sqlcode}]\n\n");
      return undef;
    }
  }
  $self->{logger}->debug("end set schema to $config->{'schema'} success\n\n");

  return $self if $use && not %$use;

  my $sth;
  for my $secname (keys %{$dbc}) {

    my $section = $dbc->{$secname};

    if ( $secname =~ /^@(.*)/) {
      next if $use && not exists $use->{$1};
      
      $self->{logger}->debug("init table $secname begin...");
      unless($self->_init_table($secname, $section, $use, $except)) {
        $self->{logger}->debug("init table $secname end error");
        return undef;
      }
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
    for (split) {
      push @files, <$dir/$_>;
    }
    for my $file (@files) {
      $self->{logger}->debug("init_file $file begin...");
      unless($self->_init_file($file, $use, $except)) {
        $self->{logger}->error("init_file $file end error");
        return undef;
      }
      $self->{logger}->debug("init_file $file end success");
    }
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
      $self->{logger}->debug("init table $secname begin...");
      unless($self->_init_table($secname, $section, $use, $except)) {
        $self->{logger}->error("init table $secname end error");
        return undef;
      }
      $self->{logger}->debug("init table $secname end success");
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
    $self->{logger}->debug("beg prepare $tbl_name.$op [$tbl->{$op}]...");
    eval { $self->{'table'}->{$tbl_name}->{$op}->{'sth'} = $dbh->prepare($tbl->{$op}) };  
    if ($@) {
      $self->{'sqlcode'} = $self->{'dbh'}->err;
      $self->{logger}->error("end prepare $tbl_name.$op sqlcode[$self->{'sqlcode'}]\n\n");
      return undef;
    }
    $self->{'sqlcode'} = $self->{'dbh'}->err;
    if ($self->{'sqlcode'}) {
      $self->{logger}->error("end prepare $tbl_name.$op warning[$self->{sqlcode} => " . $self->{'dbh'}->errstr . "\n\n");
      return undef;
    }
    $self->{logger}->debug("end prepare $tbl_name.$op success\n\n");
    $self->{'table'}->{$tbl_name}->{$op}->{'sql'} = $tbl->{$op};
  }

  return $self;
}

#
# 上次sql语句的 返回码  
#
sub sqlcode {
  my $self = shift;
  return $self->{'sqlcode'};
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
  my $sth = $self->{'table'}->{$tbl}->{$op}->{'sth'};
  unless($sth) {
    $self->{logger}->error("$tbl.$op does not exists");
    return undef;
  }

  # debug info
  if ( @op_param) {
    $self->{logger}->debug("beg $tbl.$op [$self->{'table'}->{$tbl}->{$op}->{'sql'}]\n",
                 "with arg: \n",
                 Data::Dump->dump(\@op_param));
    eval { $sth->execute(@op_param); };
  } else {
    $self->{logger}->debug("execute $tbl.$op [$self->{'table'}->{$tbl}->{$op}->{'sql'}]");
    eval { $sth->execute(); };
  }

  #############################
  # eval execution
  #############################
  if($@) {
    $self->{sqlcode} = $sth->err;
    $self->{logger}->error("end $tbl.$op sqlcode[$self->{sqlcode}]\n\n");
    return undef;
  }
  $self->{sqlcode} = $sth->err;

  if ($self->{sqlcode} ) {
    $self->{logger}->error("end $tbl.$op warning sqlcode[$self->{sqlcode} => " . $sth->errstr . "]\n\n");
    return undef;
  } 
  else {
    $self->{logger}->debug("end $tbl.$op end success\n\n");
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
  $self->{logger}->debug("beg begin_work...");
  eval { $self->{'dbh'}->begin_work() };
  if($@) {
    $self->{sqlcode} = $self->{'dbh'}->err;
    $self->{logger}->error("end begin_work sqlcode[$self->{sqlcode}]\n\n");
    return undef;
  }
  $self->{logger}->debug("end begin_work success\n\n");
  return $self;
}

#
# 数据库提交  
#
sub commit {

  my $self = shift;

  $self->{logger}->debug("beg commit...");
  eval { $self->{'dbh'}->commit() };
  if($@) {
    $self->{sqlcode} = $self->{'dbh'}->err;
    $self->{logger}->error("end commit sqlcode[$self->{sqlcode}]\n\n");
    return undef;
  }
  $self->{logger}->debug("end commit success\n\n");
  return $self;
}

#
# 数据库回滚  
#
sub rollback {
  my $self = shift;
  
  $self->{logger}->debug("beg rollback...");
  eval { $self->{'dbh'}->rollback() };
  if($@) {
    $self->{sqlcode} = $self->{'dbh'}->err;
    $self->{logger}->error("end rollback sqlcode[$self->{sqlcode}]\n\n");
    return undef;
  }
  $self->{logger}->debug("end rollback success\n\n");
  return $self;
}

#
# 断开到数据库连接 

sub disconnect {

  my $self = shift;
  unless($self->{'dbh'}) {
    return undef;
  }

  $self->{logger}->debug("beg disconnect...");

  $self->finish();
  $self->rollback();

  eval { $self->{'dbh'}->disconnect };
  if($@) {
    $self->{'sqlcode'} = $self->{'dbh'}->err;
    $self->{logger}->debug("end disconnect end sqlcode[$self->{sqlcode}]\n\n");
    return undef;
  }
  $self->{logger}->debug("end disconnect success\n\n");
  delete $self->{'dbh'};

  return $self;

}


sub finish {

  my $self = shift;

  my $tbls = $self->{'table'};

  my $aec = 0; # all error count
  for my $t ( keys %{$tbls}) {

    $self->{logger}->debug("beg finish $t...");
    my $ops = $tbls->{$t};
    my $ec = 0; # error count

    for my $op (keys %{$ops}) {
      $self->{logger}->debug("beg finish $t.$op...");
      eval { $ops->{$op}->{'sth'}->finish() };
      if($@) {
        $self->{logger}->debug("end finish $t.$op error");
        $ec++;
        $aec++;
        next;
      }   
      $self->{logger}->debug("end finish $t.$op success");
    }   

    if($ec) {
      $self->{logger}->debug("end finish $t end error cnt[$ec]\n\n");
      next;
    }
    $self->{logger}->debug("end finish $t success\n\n");

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

  my $sth;

  eval { $sth = $self->{dbh}->prepare(qq/select * from $tbl/); };
  if ($@) {
    $self->{logger}->error("can not prepare:\n", $@);
    return undef;
  }

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

