package IRC::Server::Toolkit::User;
use Defaults::Modern;


use Moo; use MooX::late;
use overload
  bool     => sub { 1 },
  '""'     => 'nick',
  fallback => 1;


has nick => (
  required => 1,
  is       => 'ro',
  isa      => Str,
  writer   => 'set_nick',
  trigger  => 1,
);

has user => (
  required => 1,
  is       => 'ro',
  isa      => Str,
  writer   => 'set_user',
  trigger  => 1,
);

has host => (
  required => 1,
  is       => 'ro',
  isa      => Str,
  writer   => 'set_host',
  trigger  => 1,
);

has full => (
  init_arg  => undef,
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  writer    => '_set_full',
  predicate => '_has_full',
  builder   => method { $self->nick .'!'. $self->user .'@'. $self->host },
);

method _reset_full {
  $self->_set_full( $self->_build_full ) if $self->_has_full
}
{ no warnings 'once';
  *_trigger_nick = *_reset_full;
  *_trigger_user = *_reset_full;
  *_trigger_host = *_reset_full;
}


has realname => (
  lazy     => 1,
  is       => 'ro',
  isa      => Str,
  writer   => 'set_realname',
  builder  => sub { '' },
);


has _chans => (
  is       => 'ro',
  isa      => HashObj,
  coerce   => 1,
  writer   => '_set_chans',
  builder  => sub { hash },
);

method add_channel ($channel) { $self->_chans->set($channel => 1) }
method del_channel ($channel) { $self->_chans->delete($channel) }
method list_channels { $self->_chans->keys->all }


1;
