package IRC::Server::Toolkit::Types;
use strict; use warnings FATAL => 'all';

use Type::Library     -base;
use Type::Utils       -all;
use Types::Standard   -types;
use Types::TypeTiny   ();

declare ValidCaseMap =>
  as Str(),
  where {
    $_ eq 'rfc1459' || $_ eq 'ascii' || $_ eq 'strict-rfc1459'
  },
  inline_as {
    my ($constraint, $cmap) = @_;
    $constraint->parent->inline_check($cmap) . qq{
      && ($cmap eq 'rfc1459' || $cmap eq 'ascii' || $cmap eq 'strict-rfc1459')
    }
  };


declare ChannelObject =>
  as InstanceOf['IRC::Server::Toolkit::Channel'];

declare UserObject =>
  as InstanceOf['IRC::Server::Toolkit::User'];
  
declare ChannelCollection =>
  as InstanceOf['IRC::Server::Toolkit::Collection::Channels'];

declare UserCollection =>
  as InstanceOf['IRC::Server::Toolkit::Collection::Users'];


declare ModeSet =>
  as InstanceOf['IRC::Mode::Set'];

1;
