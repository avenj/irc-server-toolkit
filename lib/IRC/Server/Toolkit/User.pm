package IRC::Server::Toolkit::User;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];


use Moo; use MooX::late;
use overload
  bool     => sub { 1 },
  '""'     => sub { shift->nick },
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
  builder   => sub { 
    my ($self) = @_;
    $self->nick .'!'. $self->user .'@'. $self->host 
  },
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

has server => (
  lazy     => 1,
  is       => 'ro',
  isa      => Str,
  writer   => 'set_server',
  builder  => sub { '' },
);


has _chans => (
  is       => 'ro',
  isa      => HashObj,
  coerce   => 1,
  writer   => '_set_chans',
  builder  => sub { hash },
);

method add_channel (
  ChannelObject $channel
) {
  $self->_chans->set( $self->lower($channel) => $channel );
  Scalar::Util::weaken($self->_chans->{$channel});
  $self
}

method del_channel ($channel) { 
  $self->_chans->delete( $self->lower($channel) )->has_any
}

method list_channel_names { $self->_chans->keys->all }
method list_channel_objects { $self->_chans->values->all }


has modes => (
  lazy    => 1,
  is      => 'ro',
  isa     => HashObj,
  coerce  => 1,
  writer  => '_set_modes',
  builder => sub { hash },
);

method set_mode (
  ModeSet $modes
) {
  # FIXME still needs some cute mode validation bits
  # and a way to feed IRC::Mode::Set from Collection::Users perhaps
  my @changed;
  MSET: while (my $mset = $modes->next) {
    my ($flag, $mode, $param) = @$mset;
    sswitch ($flag) {
      case '+': {
        $param //= -1;
        my $extant = $self->modes->get($mode);
        next MSET if defined $extant and $extant eq $param;
        $self->modes->set($mode => $param);
        push @changed, [ $flag, $mode, $param ]
      }

      case '-': {
        my $extant = $self->modes->get($mode);
        if (defined $extant) {
          push @changed, [ $flag, $mode, $extant ];
          $self->modes->delete($mode)
        }
      }
    
      default: { confess "Unknown mode flag '$flag'" }
    }
  }
  $modes->reset;
  state $guard = do { require IRC::Mode::Set };
  IRC::Mode::Set->new(mode_array => \@changed)
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


=pod

=for Pod::Coverage set_\w+

=head1 NAME

IRC::Server::Toolkit::User - Base class for connected IRC users

=head1 SYNOPSIS

FIXME

=head1 DESCRIPTION

A base class for objects representing an IRC user.

These objects stringify to the value of the L</nick> attribute.

Also see L<IRC::Server::Toolkit::Collection::Users>.

=head2 Attributes

=head3 nick

Required.

The user's nickname.

Can be set via B<set_nick>

=head3 user

The user's ident ('username') string.

Can be set via B<set_user>

=head3 host

The user's host address.

Can be set via B<set_host>

=head3 full

The user's full 'nick!user@host' IRC identifier.

Also see L</nick>, L</user>, L</host>

=head3 realname

The user's GECOS ('realname') string.

Can be set via B<set_realname>

=head3 server

The server name the user belongs to.

Can be set via B<set_server>

=head3 modes

  if ( $user->modes->exists('w') ) {
    # ...
  }

  my $snomask = $user->modes->get('s');

A L<List::Objects::WithUtils::Hash> mapping mode characters to their params
(or -1 for paramless modes).

=head2 Methods

=head3 Channels

=head4 add_channel

Takes an L<IRC::Server::Toolkit::Channel> and adds a weak reference to the
channel to the user's channel list.

See L</del_channel>, L</list_channels>.

=head4 del_channel

Takes the name of a channel or an L<IRC::Server::Toolkit::Channel> instance.
Returns boolean true if the channel was deleted.

=head4 list_channel_names

Returns the names of the channels the user is present on as a plain list.

=head4 list_channel_objects

Returns the objects representing the channels the user is present on as a
plain list.

=head3 Modes

=head4 set_mode

Takes an L<IRC::Mode::Set> containing user mode changes and adjusts L</modes>
accordingly.

Returns a new L<IRC::Mode::Set> containing the modes that were actually changed.

=head3 Flags

=head4 list_flags

Returns all currently enabled flags (as a plain list).

=head4 add_flags

Enables the given list of flags (which can be arbitrary strings).

=head4 del_flags

Removes the given list of flags.

=head4 has_flags

Takes a list of flags and returns a new list containing the flags that are
currently enabled.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>


=cut

