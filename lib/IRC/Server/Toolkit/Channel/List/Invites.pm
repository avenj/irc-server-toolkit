package IRC::Server::Toolkit::Channel::List::Invites;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use Moo; use MooX::late;


with 'IRC::Server::Toolkit::Role::DefaultCaseMap';
with 'IRC::Toolkit::Role::CaseMap';
with 'IRC::Server::Toolkit::Role::CaseMappedList';

around add => sub {
  my ($orig, $self, %inv) = @_;
  while (my ($nick, $meta) = each %inv) {
    confess 'Expected an ARRAY containing setter and optional TS'
      unless ref $meta
      and reftype $meta eq 'ARRAY'
      and @$meta >= 1;
    $meta->[1] = time unless defined $meta->[1];
    $self->orig( $self->lower($nick) => $meta )
  }
};

around get => sub {
  my ($orig, $self, $nick) = @_;
  $self->$orig( $self->lower($nick) )
};

around get_slice => sub {
  my ($orig, $self, @keys) = @_;
  $self->$orig( map {; $self->lower($_) } @keys )
};


method is_invited (Defined $nick) {
  $self->keys_matching_ircstr($nick)
}

1;
