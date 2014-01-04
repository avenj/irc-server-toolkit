package IRC::Server::Toolkit::Collection;
use Defaults::Modern;
use Module::Runtime 'use_module';

use Moo; use MooX::late;

has casemap => (
  required  => 1,
  is        => 'ro',
  isa       => Str,  # FIXME type check
  builder   => sub { 'rfc1459' },
);

has user_collection_class => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  builder   => sub { use_module( __PACKAGE__ .'::Users' },
);

has channel_collection_class => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  builder   => sub { use_module( __PACKAGE__ .'::Channels' },
);

has users => (
  lazy      => 1,
  is        => 'ro',
  isa       => Object,
  builder   => method { 
    $self->user_collection_class->new(
      casemap => $self->casemap,
    )
  },
);

has channels => (
  lazy      => 1,
  is        => 'ro',
  isa       => Object,
  builder   => method {
    $self->channel_collection_class->new(
      casemap => $self->casemap,
    )
  },
);

# FIXME sort out some sane top-level API?
#  settle out lower layers, add higher-level API calls w/ optional validation
#   etc?
#  (valid umodes, valid cmodes, mode/param maps, etc)

1;
