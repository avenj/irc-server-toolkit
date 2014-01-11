package IRC::Server::Toolkit::Collection::Channels;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use Module::Runtime 'use_module';

use Moo; use MooX::late;

has casemap => (
  lazy      => 1,
  is        => 'ro',
  isa       => ValidCaseMapObject,
  coerce    => 1,
  predicate => 'has_casemap',
  builder   => sub { 'rfc1459' },
);
with 'IRC::Toolkit::Role::CaseMap';

has _chans => (
  lazy      => 1,
  is        => 'ro',
  isa       => HashObj,
  coerce    => 1,
  writer    => '_set_chans',
  builder   => sub { hash },
);

has channel_class => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  builder   => sub { use_module('IRC::Server::Toolkit::Channel') },
);

method create_and_add (@arg) {
  my %params = @arg ? @arg == 1 ? %{ $arg[0] } : @arg : ();
  if ($self->has_casemap && $self->casemap ne 'rfc1459') {
    $params{casemap} = $self->casemap
  }
  $self->add_channels(
    $self->channel_class->new(%params)
  )
}

method add_channels (@channels) {
  my $chan_class = $self->channel_class;
  for my $chan (@channels) {
    confess "Expected an instance of $chan_class but got $chan"
      unless blessed $chan and $chan->isa($chan_class);

    my $cname = $self->lower( $chan->name );
    confess "Attempted to add previously extant channel $cname"
      if $self->_chans->exists($cname);

    unless ((my $cmap = $chan->casemap) eq (my $orig = $self->casemap)) {
      carp "casemap mismatch: channel '$cname' mapped '$cmap' - ",
           "collection is '$orig'";
    }

    $self->_chans->set($cname => $chan)
  }
  $self
}
{ no warnings 'once'; *add_channel = *add_channels }

method del_channels (@channels) {
  my @deleted;
  for my $chan (@channels) {
    my $cname = blessed $chan ? 
      $self->lower( $chan->name ) : $self->lower( $chan );
    push @deleted, $cname if $self->_chans->delete($cname);
  }
  @deleted
}
{ no warnings 'once'; *del_channel = *del_channels }

method as_list  { $self->_chans->values->all }
method as_array { $self->_chans->values }
method names_list  { map {; $_->name } $self->_chans->values->all }
method names_array { $self->_chans->values->map(sub { $_->name }) }

method by_name (Str $chan) { $self->_chans->get( $self->lower($chan) ) }

method matching_mask (Str $mask) {
  my $cmap = $self->casemap;
  my $matches = $self->_chans->keys->grep(
    sub { matches_mask( $mask, $_, $cmap ) }
  );
  $matches->has_any ? $matches : ()
}

method grep (CodeRef $sub) { $self->_chans->values->grep($sub) }

1;
