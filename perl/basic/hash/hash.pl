#!/usr/bin/perl
use strict;
use warnings;

use Data::Dump;
use Data::Dumper;

#my %hashs=(
#	banana => "yellow",
#	apple => "red",
#	orange => "yellow");
my %hashs = (
    "e" => 5,
    "d" => 4,
    "a" => 1,
    "b" => 2,
    "c" => 3
);
print "000000\n";
####keys 获取hash的所有key,返回是array
my @akey   = keys %hashs;
my @avalue = values %hashs;

warn "-------------- key 的个数：" ;
my $count  = @akey;
print "the count of hashs is $count\n";
warn "--------------------------" ;

warn "------------hash的所有key";
warn "@akey";

warn "------------hash的所有value";
warn "@avalue";

warn "----------------------------";
print "取出hash中的部分片段\n";
#####取出hash中多个key对应的value,返回array
print "取出hash中多个key对应的value,返回array\n";
my @tvalue = @hashs{ 'a', 'c' };
print "@tvalue\n";
##########################
print "222222\n";
print "取出hash中某个元素的value,value=\$hash{\$key}\n";
my $tvalue = $hashs{b};
print "$tvalue\n";

#############each函数迭代hash#############
print "333333\n";
print "eahc函数迭代hash,但是each返回的key/value对，顺序错乱\n";
while ( my ( $key, $value ) = each %hashs ) {
    print "$key => $value\n";
}

############foreach############
print "444444\n";
print "利用sort和foreach对hash进行排序\n";
foreach my $key ( sort keys %hashs ) {
    my $value = $hashs{$key};
    print "$key => $value\n";

    #print "$key => $hashs{$key}\n";
}
##############exists#################
print "555555\n";
print "利用exists函数检测某个key在hash中是否存在\n";
if ( exists $hashs{a} ) {
    print "Hey,there is key a in hashs\n";
    $hashs{"a"} += 3;
    Data::Dump->dump(%hashs);
}
###############delete##################
print "666666\n";
print "利用delete函数从hash中将指定的key及其对应的value删除\n";
print "before delete", Data::Dumper->Dump( [ \%hashs ] );

#delete $hashs{"a"};
delete $hashs{"d"};
print "after delete", Data::Dumper->Dump( [ \%hashs ] );

=a 
多行注释 以=开头，=cut结尾,且=后面紧跟一个字符,=cut后面可以不用,
且=,=cut只能在行首
=cut

############向hash里添加#########
$hashs{e} = "10";
print "after add", Data::Dumper->Dump( [ \%hashs ] );

##########hash => array##########
my @arr = %hashs;
printf "hash turn to array\n";
print "@arr\n";

########hash reverse#########
my %test = reverse %hashs;
print "after hash reverse\n";
Data::Dump->dump(%test);

########## array turn into hash ###########
my @arr2 = qw/a 10 b 11 c 12/;
printf "array turn into hash\n";
my %atoh = @arr2;
Data::Dump->dump( \%atoh );
