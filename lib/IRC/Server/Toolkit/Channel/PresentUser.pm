package IRC::Server::Toolkit::Channel::PresentUser;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];


use Moo; use MooX::late;

has user => (
  required  => 1,
  is        => 'ro',
  isa       => Maybe[UserObject],
  weaken    => 1,
);

has status => (
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  writer    => 'set_status',
  predicate => 'has_status',
  builder   => sub { hash },
  # FIXME sane API for status modes -> prefix translation
);

has ts => (
  is        => 'ro',
  isa       => Num,
  writer    => 'set_ts',
  builder   => sub { time }
);



1;
