package IRC::Server::Toolkit::Channel::List::Bans;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use IRC::Toolkit::Masks;

use Moo; use MooX::late;

# Order matters:
with 'IRC::Server::Toolkit::Role::DefaultCaseMap';
with 'IRC::Toolkit::Role::CaseMap';
with 'IRC::Server::Toolkit::Role::CaseMappedList';


around add => sub {
  my ($orig, $self, %bans) = @_;
  while (my ($mask, $meta) = each %bans) {
    confess 'Expected an ARRAY containing setter and optional TS'
      unless ref $meta
      and reftype $meta eq 'ARRAY'
      and @$meta >= 1;
    # Set TS if we don't have one:
    $meta->[1] = time unless defined $meta->[1];
    $self->$orig( normalize_mask($mask) => $meta )
  }
};

around get => sub {
  my ($orig, $self, $mask) = @_;
  $self->$orig(normalize_mask $mask)
};

around get_slice => sub {
  my ($orig, $self, @keys) = @_;
  $self->$orig(map {; normalize_mask $_ } @keys)
};


method is_banned (Defined $host) {
  $self->keys_matching_host($host)->has_any
}

method has_ban (Defined $mask) { 
  $self->_list->exists(normalize_mask $mask) 
}

method added_by (Defined $mask) {
  my $item = $self->get(normalize_mask $mask) // return;
  $item->[0]
}

method added_at (Defined $mask) {
  my $item = $self->get(normalize_mask $mask) // return;
  $item->[1]
}

1;
