package IRC::Server::Toolkit::Types;
use strict; use warnings FATAL => 'all';

use Type::Library     -base;
use Type::Utils       -all;
use Types::Standard   -types;
use Types::TypeTiny   ();

use List::Objects::Types -types;

use Module::Runtime 'use_module';

use IRC::Mode::Set;
use IRC::Mode::Single;

declare ValidCaseMap =>
  as Str(),
  where {
    $_ eq 'rfc1459' || $_ eq 'ascii' || $_ eq 'strict-rfc1459'
  },
  inline_as {
    my ($constraint, $cmap) = @_;
    $constraint->parent->inline_check($cmap) . 
    qq[ && ($cmap eq 'rfc1459' ]             .
    qq[ || $cmap eq 'ascii' ]                .
    qq[ || $cmap eq 'strict-rfc1459') ]
  };

declare ValidCaseMapObject =>
  as InstanceOf['IRC::Server::Toolkit::CaseMap'];

coerce ValidCaseMapObject =>
  from ValidCaseMap() =>
    via { use_module('IRC::Server::Toolkit::CaseMap')->new($_) };


declare ChannelObject =>
  as InstanceOf['IRC::Server::Toolkit::Channel'];

declare ChannelListObject =>
  as ConsumerOf['IRC::Server::Toolkit::Role::CaseMappedList'];

declare TopicObject =>
  as InstanceOf['IRC::Server::Toolkit::Channel::Topic'];
 

declare StateObject =>
  as InstanceOf['IRC::Server::Toolkit::State'];


declare UserObject =>
  as InstanceOf['IRC::Server::Toolkit::User'];
 

declare ChannelCollection =>
  as InstanceOf['IRC::Server::Toolkit::Collection::Channels'];

declare UserCollection =>
  as InstanceOf['IRC::Server::Toolkit::Collection::Users'];


declare ModeSet =>
  as InstanceOf['IRC::Mode::Set'];

coerce ModeSet =>
  from ArrayRef() => via { IRC::Mode::Set->new(mode_array => $_) },
  from ArrayObj() => via { IRC::Mode::Set->new(mode_array => $_->unbless) };


declare ModeSingle =>
  as InstanceOf['IRC::Mode::Single'];

coerce ModeSingle =>
  from ArrayRef() => via { IRC::Mode::Single->new(@$_) },
  from ArrayObj() => via { IRC::Mode::Single->new($_->all) };

1;
