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


has _modes => (
  lazy    => 1,
  is      => 'ro',
  isa     => HashObj,
  coerce  => 1,
  writer  => '_set_modes',
  builder => sub { hash },
);

method set_mode (
  InstanceOf['IRC::Mode::Set'] $modes
) {
  # FIXME still needs some cute mode validation bits
  # and a way to feed IRC::Mode::Set from Collection::Users perhaps
  my @changed;
  MSET: while (my $mset = $modes->next) {
    my ($flag, $mode, $param) = @$mset;
    if ($flag eq '+') {
      $param //= 1;
      my $extant = $self->_modes->get($mode);
      next MSET if defined $extant and $extant eq $param;
      $self->_modes->set($mode => $param);
      push @changed, [ $flag, $mode, $param ]
    } elsif ($flag eq '-') {
      my $extant = $self->_modes->get($mode);
      if (defined $extant) {
        push @changed, [ $flag, $mode, $extant ];
        $self->_modes->delete($mode)
      }
    } else {
      confess "Unknown mode flag '$flag'"
    }
  }
  $modes->reset;
  array(@changed)
}


has _flags => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  builder   => sub { hash },
);

method list_flags { $self->_flags->keys->all }
method add_flags (@flags) { $self->_flags->set(map {; $_ => 1 } @flags) }
method del_flags (@flags) { $self->_flags->delete(@flags) }
method has_flags (@flags) {
  my @res;
  for (@flags) {
    push @res, $_ if $self->_flags->exists($_)
  }
  @res
}



1;
