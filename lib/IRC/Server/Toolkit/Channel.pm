package IRC::Server::Toolkit::Channel;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use IRC::Server::Toolkit::CaseMap;

use Module::Runtime 'use_module';

use Moo; use MooX::late;
use overload
  bool => sub { 1 },
  '""' => sub { shift->name },
  fallback => 1,

has name => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
);

# Channel casemap defaults to rfc1459, which should do for most ...
# if we have something else specified, save some memory by coercing
# to a CaseMap obj (these are cached):
has _casemap => (
  init_arg  => 'casemap',
  lazy      => 1,
  is        => 'ro',
  isa       => ValidCaseMapObject,
  predicate => 'has_casemap',
  coerce    => 1,
  builder   => sub { 'rfc1459' }
);
method casemap { $self->has_casemap ? $self->_casemap : 'rfc1459' }
with 'IRC::Toolkit::Role::CaseMap';


has ts  => (
  is        => 'ro',
  isa       => Num,
  writer    => 'set_ts',
  builder   => sub { time },
);

has topic => (
  lazy      => 1,
  is        => 'ro',
  isa       => TopicObject,
  coerce    => 1,
  writer    => 'set_topic',
  predicate => 'has_topic',
);

# FIXME figure out modes interfaces/storage

has _users => (
  # FIXME sane api for storing user status modes
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  writer    => '_set_users',
  predicate => '_has_users',
  builder   => sub { hash },
);

has _lists => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  writer    => '_set_lists',
  predicate => '_has_lists',
  builder   => sub {
    my ($self) = @_;
    my $lists = hash;
    $self->list_classes->kv->visit(
      sub {
        my ($list, $class) = @$_;
        $lists->set(
          lc($list) => use_module($class)->new 
        )
      }
    );
  },
);

method list_classes {
  # Override me to produce different lists.
  state $classes = hash(
    map {; $_ => 'IRC::Server::Toolkit::Channel::List::'.$_ } qw/
      Invites
      Bans
    /
  );
  $classes
}

1;
