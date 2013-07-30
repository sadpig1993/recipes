#!/usr/bin/perl
use strict;
use warnings;
use Data::Dump;

=a 
多行注释 以=开头，=cut结尾,且=后面紧跟一个字符,=cut后面可以不用,
且=,=cut只能在行首
=cut

my %hashs = (
    "e" => 5,
    "d" => 4,
    "a" => 1,
    "b" => 2,
    "c" => 3
);

warn "------------%hashs的数据";
Data::Dump->dump(%hashs);

warn "-------------------------1";
####keys 获取hash的所有key,返回是array
my @akey   = keys %hashs;
my @avalue = values %hashs;
warn "-------------- key 的个数：";
my $count = @akey;
print "the count of hashs is $count\n";
warn "--------------------------";
warn "------------hash的所有key";
warn "@akey";
warn "------------hash的所有value";
warn "@avalue";

print "---------------取出hash中的部分key的值\n";

#####取出hash中多个key对应的value,返回array
print "取出hash中多个key对应的value,返回array\n";
my @tvalue = @hashs{ 'a', 'c' };
print "@tvalue\n";

##########################
warn "--------------------------2";
print "取出hash中某个元素的value,value=\$hash{\$key}\n";
my $tvalue = $hashs{b};
print "$tvalue\n";

#############each函数迭代hash#############
warn "--------------------------3";
print "eahc函数迭代hash,但是each返回的key/value对，顺序错乱\n";
while ( my ( $key, $value ) = each %hashs ) {
    print "$key => $value\n";
}

############foreach############
warn "--------------------------4";
print "利用sort和foreach对hash进行排序\n";
foreach my $key ( sort keys %hashs ) {
    my $value = $hashs{$key};
    print "$key => $value\n";

    #print "$key => $hashs{$key}\n";
}
##############exists#################
warn "--------------------------5";
print "利用exists函数检测某个key在hash中是否存在\n";
if ( exists $hashs{a} ) {
    print "Hey,there is key a in hashs\n";
    $hashs{"a"} += 3;
    Data::Dump->dump(%hashs);
}

###############delete##################
warn "--------------------------6";
print "利用delete函数从hash中将指定的key及其对应的value删除\n";
print "before delete", Data::Dump->dump( \%hashs );

delete $hashs{"d"};
print "after delete", Data::Dump->dump( \%hashs );

############向hash里添加#########
warn "------------向hash里添加key/value对";
print "before add", Data::Dump->dump( \%hashs );
$hashs{f} = '10';
print "after add", Data::Dump->dump( \%hashs );

##########hash转换成array##########
warn "-------------hash转换成数组";
my @arr = %hashs;
printf "hash turn to array\n";
print "@arr\n";

########hash reverse#########
warn "------------对hash进行反向";
my %test = reverse %hashs;
print "after hash reverse" . Data::Dump->dump(%test) . "\n";

########## array turn into hash ###########
warn "-----------------hash转换成数组";
my @arr2 = qw/a 10 b 11 c 12/;
printf "array turn into hash\n";
my %atoh = @arr2;
Data::Dump->dump( \%atoh );
