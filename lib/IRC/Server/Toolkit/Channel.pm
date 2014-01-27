package IRC::Server::Toolkit::Channel;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use IRC::Server::Toolkit::CaseMap;
use IRC::Server::Toolkit::Channel::PresentUser;

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

has _modes => (
# FIXME figure out modes interfaces/storage
);


has _users => (
  # FIXME weakened User objs and their channel-related meta
  #  need add_user like User's add_channel
  # FIXME sane api for storing user status modes
  #  should probably be able to create objs containing status modes
  #  and their matching prefixes, then keep refs to those objs around
  #  same for other modes?
  #  take a gander at Toolkit::ISupport, figure it out from there
  #  possibly we can borrow the existing ISupport structs
  #  -> blocking on IRC::Toolkit::Modes change in git
  # also figure out wtf I was doing in i-s-pluggable
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  writer    => '_set_users',
  predicate => '_has_users',
  builder   => sub { hash },
);

method add_user (
  UserObject     $user,
  (Num | Undef)  $ts
) {
  my $obj = IRC::Server::Toolkit::Channel::PresentUser->new(
    user     => $user,
    maybe ts => $ts,
  );
  $self->_users->set( $self->lower($user) => $obj );
  $obj
}

method del_user ($user) {
  $self->_users->delete( $self->lower($user) )->has_any
}

method list_user_names { $self->_users->keys->all }
method list_user_objects { 
  $self->_values->map(sub { $_->user // () })->all
}


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

method has_list (Str $list) { $self->_lists->exists(lc $list) }

method host_is_banned ($host) {
  unless ($self->has_list('bans')) {
    carp "host_is_banned called but no 'Bans' list available";
    return
  }
  my $blist = $self->_lists->get('bans');
  $blist->is_banned($host)
}

method nick_is_invited ($nick) {
  unless ($self->has_list('invites')) {
    carp "nick_is_invited called but no 'Invites' list available";
    return
  }
  my $invlist = $self->_lists->get('invites');
  $invlist->is_invited($nick)
}

1;
