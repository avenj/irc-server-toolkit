package IRC::Server::Toolkit::Role::DefaultCaseMap;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];


use Moo::Role; use MooX::late;

has _casemap => (
  init_arg  => 'casemap',
  lazy      => 1,
  is        => 'ro',
  isa       => ValidCaseMapObject,
  predicate => 'has_casemap',
  writer    => 'set_casemap',
  clearer   => 'clear_casemap',
  coerce    => 1,
  builder   => sub { 'rfc1459' },   # shouldn't be called, but eh
);

around set_casemap => sub {
  my ($orig, $self, $cmap) = @_;
  if ($cmap eq 'rfc1459') {
    $self->clear_casemap
  } else {
    $self->$orig($cmap)
  }
};

method casemap { $self->has_casemap ? $self->_casemap : 'rfc1459' }

1;
