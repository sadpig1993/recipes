package  Util::Run;
use strict;
use warnings;
use Carp;
use File::Basename;
use Graph::Directed;
use Graph::Writer::Dot;

#
# 插件
my %plugin;

#
#  PLUGIN_DEBUG           : 打印所有添加的API
#  PLUGIN_UNIT_TEST       : plugin单元测试
#  PLUGIN_PATH            : 插件查找目录
#
# singleton模式对象数据结构
our $run_kernel = {};
sub import {

    my $pkg = shift;
    
    # stdin stdout pre-processing
    require IO::Handle;
    STDOUT->autoflush(1);
    STDIN->blocking(1);

    bless $run_kernel, __PACKAGE__;
    my ($callpkg, $fname, $line) = (caller)[0,1,2];
    {
        no strict 'refs';
        no warnings 'redefine';
        *{"$callpkg\::zkernel"}    = sub { $run_kernel };
        *{"$callpkg\::zlogger"}    = sub { $run_kernel->logger };
        *{"$callpkg\::helper"}     = sub { add_helper->($callpkg, $fname, $line, @_); };
        return 1;
    }
}

#
#
#
sub launch {
    my ($self, $config) = @_;
    
    # 参数检查
    $self->load_plugin('check');
    $self->init_plugin('check', $config);
    
    # 后台运行
    $self->load_plugin('daemonize');
    $self->init_plugin('daemonize', @{$config}{qw/name pidfile/}); 
    
    # 日志初始化
    $self->load_plugin('logger');
    $self->init_plugin('logger',logurl => $config->{logurl}, loglevel => $config->{loglevel});
    
    # 加载plugin
    for my $name ( qw/process channel /) {
        $self->load_plugin($name);
    }
        
    # 检查
    # 初始化channel   : 创建初始管道
    # 初始化process   : 主要是设置信号处理
    $self->init_plugin('channel', @{$config->{channel}});
    $self->init_plugin('process');

    # 模式为logger时, 构建loggerd进程后， 重新初始化logger
    if ($config->{mode} =~ /loggerd/) {
        my $channel = $self->channel_new();
        # 启动logger子进程
        $self->process_loggerd($config->{logname}, $config->{logurl},  $channel);
        
        $self->logger_reset(
            Util::Log->new(
                handle    => $channel->{writer},
                loglevel  => $config->{loglevel}
            ),
        );
    }
   
    return $self;    
}

#
# 提交主控制模块，子进程模块参数运行
#
sub run {
    my ($self, $args) = @_;
    # 启动进程模块
    # 运行主控进程
    $self->process_runall($args->{module});
    $args->{main}->(@{$args->{args}}) or confess "can not run main[@{$args->{args}}]";
    
    exit 0;
};

#
# 装饰器
#
sub add_helper {
    my ($class, $fname, $line, $name, $helper)  = @_;
    
    warn sprintf("helper[%-16s] is defined at[%s:%s:%s]\n",  $name, $class, $fname, $line) if $ENV{PLUGIN_DEBUG};
    my $cref = ref $helper;
    unless ($cref && $cref =~ /CODE/) {
        confess sprintf("helper[%-16s] defined at[%s:%s:%s] is not code ref\n",  $name, $class, $fname, $line);
    }

    # 重复定义
    if (__PACKAGE__->can($name)) {
        confess __PACKAGE__ . "::$name already exists";
    }
    
    # 保留前缀  
    if ($name =~ /^(_|load|init|prepare|run|channel|check|daemonize|process|kernel|logger|submit|time|serializer|db)/) {
        # warn "prefix[$1] is reserved for internal use";
    }

    no strict 'refs';
    *{ __PACKAGE__ . "::" . $name} = \&{$helper};
}


#
#  加载插件
#
sub load_plugin {
    my ($self, $name) = @_;
    warn "begin load_plugin[$name]\n";
    my @plugin_path   =  split ':', $ENV{PLUGIN_PATH} if $ENV{PLUGIN_PATH} and -d $ENV{PLUGIN_PATH};
    my $pfile;
    for (@plugin_path) {
        next unless -f "$_/$name.plugin";
        $pfile = "$_/$name.plugin";
        last; 
    }
    unless( $pfile ) {
        $pfile = dirname(__FILE__) . "/Run/Plugin/$name.plugin";
    }
    
    # warn "pfile[$pfile]";
    unless(-f $pfile) {
        confess "can not find plugin[$name] in[$ENV{PLUGIN_PATH}]";
    }

    # warn "begin do file[$pfile]";
    my $initor = do $pfile or confess "can not do file[$pfile] error[$@]";
    # warn "end do file[$pfile]";

    $plugin{$name} = $initor;
}

#
# 初始化插件
#
# use Carp qw/cluck/;
sub init_plugin {
    my ($self, $name) = (shift, shift);
    warn "begin init_plugin[$name][@_]\n";
    $plugin{$name}->(@_);
}

1;

__END__

#
# 子进程调用init_plugin初始化自己所需的plugin
# $self->init_plugin('plugin-a'  => [ 'para1', 'para2' ],  'plugin-b' => [ 'para1', 'para2' ])
#
sub init_plugin {
    my $self = shift;

    # 初始化plugin
    my $g = Graph::Directed->new();
    my $plugin = $self->{plugin};
    
}

#
#  加载plugin
#
sub load_plugin {
    my $self       = shift;
    my $plugin_cfg = shift;
    
    # 从PLUGIN_PATH中
    my @plugin_path =  split ':', $ENV{PLUGIN_PATH};
    confess "$plugin_cfg does not exists" unless -f $plugin_cfg;
    my $cfg = ini_parse($plugin_cfg);

    my %child_plugin;
    my $father_plugin;

    # 加载plugin
    my %plugin_list;
    for my $name ( keys %$cfg) {
       my $plugin = $cfg->{$name};
       my $path;
       # 搜索plugin
       for (@plugin_path) {
          next unless -f "$_/$name.plugin";
          $path = "$_/$name.plugin";
          last; 
       }
       my $initor = do $path or confess "can not do file[$path] error[$@]";  
       my $depend = [ split '\s+', $plugin->{depend} ];
       my $para   = [ split '\s+', $plugin->{para} ];

       # 子进程初始化的plugin
       if ($plugin->{child}) {
          $child_plugin{$name}{initor} = $initor;
          $child_plugin{$name}{depend} = $depend;
          $child_plugin{$name}{para}   = $para;
       }

       # 父进程初始化的plugin
       else {
          $father_plugin{$name}{initor} = $initor;
          $father_plugin{$name}{depend} = $depend;
          $father_plugin{$name}{para}   = $para;
       }
    }

    # plugin依赖检查
    unless($self->_check_depend(\%father_plugin, \%child_plugin)) {
        confess "plugin dependencies check failed";
    }

    # 如果是测试plugin, 那么就不区分child, paraent
    if ($ENV{PLUGIN_TEST}) {
       return $self->_load_plugin_test(\%father_plugin, \%child_plugin);
    }
    # 不是plugin测试, 只有父进程的plugin需要放入DAG加载
    else {
       return $self->_load_plugin(%father_plugin, %child_plugin);
    }

}

#
# 测试环境下加载plugin
#
sub _load_plugin_test {
    my 
}

#
# 非测试环境plugin加载
#
sub _load_plugin {
}

          unless($plugin->{child}) {
              $g->add_vertex($name);
              for (%$depend) {
                 $g->add_edge($name, $_);
              }
          }
       }

       # 初始化DAG中的plugin
       my $cnt = $g->vertices;
       for ( 1 .. $cnt ) {
           for my $pname ($g->vertices) {
              if ($g->in_degree($pname) == 0 ) {
                 my $p = delete $plugin_list{$pname};
                 for my $suc ($g->successors($pname)) {
                    $g->delete_edges($pname, $suc);
                 }
                 $g->delete_vertices($pname);
                 $p->{initor}->(@{$p->{para}}) or confess "can not init plugin[$pname] para[@{$p->{para}}]";
              }               
           }
           last unless $g->vertices;
       }
       my @vertices = $g->vertices;
       if (@vertices) {
          my $gwriter = Graph::Writer::Dot->new();
          my ($y, $m, $d, $H, $M, $S) = (localtime)[5,4,3,2,1,0];
          $y += 1900;  $m += 1;
          my $dt = sprintf("%04d%02d%02d%02d%02d%02d");
          $gwriter->write_graph($g, "/tmp/plugin-fail-$dt.dot");
          confess "can not init plugin[@vertices] see /tmp/log/plugin-fail-$dt.dot for details";
       }
    }
}
















1;

__END__

=head1 NAME
  
  Util::Run - an process && IPC management module


=head1 SYNOPSIS

  #!/usr/bin/perl -w
  use strict;

  use Util::Run;
  my $kernel = Util::Run->launch();

  $kernel->run();
  exit 0;


=head1 API

  launch  :
  run     :
  submit  :
  logger  :


=head1 tutorial

=head2 section 1

	section1 begin
	section1 end
 
=head2 section 2

	section2 begin
	section2 end
 

=head1 Author & Copyright

  zcman2005@gmail.com

=cut
