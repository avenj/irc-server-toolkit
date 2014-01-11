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
  fallback => 1;


with 'IRC::Server::Toolkit::Role::DefaultCaseMap';
with 'IRC::Toolkit::Role::CaseMap';


has name => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
);

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
    my $casemap;
    if ($self->has_casemap && $self->casemap ne 'rfc1459') {
      $casemap = $self->casemap
    }
    $self->list_classes->kv->visit(sub {
      my ($list, $class) = @$_;
      $lists->set(
        lc($list) => use_module($class)->new(
          # FIXME lists need to consume CaseMap/DefaultCaseMap also
          maybe casemap => $casemap,
        )
      )
    });
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
