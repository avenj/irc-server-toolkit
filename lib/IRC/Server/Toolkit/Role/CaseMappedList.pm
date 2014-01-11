package IRC::Server::Toolkit::Role::CaseMappedList;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use IRC::Toolkit::Masks;

use Moo::Role; use MooX::late;

# Expect we have IRC::Toolkit::Role::CaseMap or compatible impl:
requires qw/
  casemap
  lower
  upper
  equals
/;

has _list => (
  init_arg => 'list',
  lazy     => 1,
  is       => 'ro',
  isa      => HashObj,
  coerce   => 1,
  builder  => sub { hash },
);

method add (@pairs) { $self->_list->set(@pairs) }
{ no warnings 'once'; *set = *add }

method del (Defined $key) {
  return unless $self->_list->exists($key);
  $self->_list->delete($key)
}

method get (Defined $key) { $self->_list->get($key) }

method get_slice (@keys)  { $self->_list->sliced(@keys) }

method keys { $self->_list->keys }

method values { $self->_list->values }

method kv { $self->_list->kv }

method keys_matching_regex (RegexpRef $re) { 
  $self->_list->keys->grep(sub { $_ =~ $re })
}

method keys_matching_ircstr (Defined $str) {
  $self->_list->keys->grep(sub { $self->equals($str, $_) })
}

method keys_matching_mask (Defined $mask) {
  my $norm = normalize_mask($mask);
  my $cmap = $self->casemap;
  $self->_list->keys->grep(
    sub { matches_mask( $norm, $_, $cmap ) }
  )
}

method keys_matching_host (Defined $host) {
  # Reverse-ish of above, assumes keys are masks
  # FIXME does not normalize, should it?
  #  or just assume keys were normalized on 'add' ?
  my $cmap = $self->casemap;
  $self->_list->keys->grep(
    sub { matches_mask( $_, $host, $cmap ) }
  )
}

1;
