package db;
use strict;
use warnings;
use DBI;
use Carp;
use constant { DEBUG => $ENV{DB_DEBUG} || 0, };

BEGIN {
    require Data::Dump if DEBUG;
}

# 建立dbh database handler 
# 需要环境变量 $DB_NAME $DB_USER $DB_PASS $DB_SCHEMA
#
sub dbh {
    my $class = shift;

    # 检查环境变量
    unless ( $ENV{DB_NAME} && $ENV{DB_USER} && $ENV{DB_PASS} ) {
        die "需要环境变量:\n" . <<EOF;
                    数据库名称 : \$ENV{DB_NAME}  
                    数据库用户 : \$ENV{DB_USER}  
                    数据库密码 : \$ENV{DB_PASS}  
EOF
    }

    # 连接数据库, 设置默认schema
    my $dbh = DBI->connect(
        "dbi:DB2:$ENV{DB_NAME}",
        @ENV{qw/DB_USER DB_PASS/},
        {
            RaiseError       => 1,
            PrintError       => 0,
            AutoCommit       => 0,
            FetchHashKeyName => 'NAME_lc',
            ChopBlanks       => 1,
        }
    );
    unless ($dbh) {
        zlogger->error("can not connet db[@ENV{qw/DB_ANME DB_USER DB_PASS/}]");
        exit 0;
    }
    $dbh->do("set current schema $ENV{DB_SCHEMA}")
      or confess "can not set current schema $ENV{DB_SCHEMA}";
    return $dbh;
}

1;
