package IRC::Server::Toolkit::Topic;
use Defaults::Modern;
use Moo; use MooX::late;

has topic => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
  writer    => 'set_topic',
);

has setter => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  writer    => 'set_setter',
  builder   => sub { '' },
);

has ts     => (
  is        => 'ro',
  isa       => Num,
  writer    => 'set_ts',
  builder   => sub { time },
);

1;
