package Util::Hash::Add;

use Hash::Merge qw/merge/;
use base 'Exporter';
our @EXPORT = qw/hash_add/;

sub hash_add {

  my ($left, $right) = @_;

  Hash::Merge::specify_behavior(
    {
      'SCALAR' => {
        'SCALAR' => sub { $_[0] + $_[1]},
        'ARRAY'  => sub { [ $_[0], @{$_[1]} ] },
        'HASH'   => sub { $_[1] },
      },
      'ARRAY'  => {
        'SCALAR' => sub { $_[1] },
        'ARRAY'  => sub { [ @{$_[0]}, @{$_[1]} ] },
        'HASH'   => sub { $_[1] },
      },
      'HASH' => {
        'SCALAR' => sub { $_[1] },
        'ARRAY'  => sub { [ values %{$_[0]}, @{$_[1]} ] },
        'HASH'   => sub { Hash::Merge::_merge_hashes( $_[0], $_[1] ) },
      },
    },
    'My Behavior',
  );

  return merge(@_);
}


1;

__END__

