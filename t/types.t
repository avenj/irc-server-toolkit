use Test::More;
use Test::TypeTiny;
use strict; use warnings FATAL => 'all';

use IRC::Server::Toolkit::Types -all;

# ValidCaseMap
should_pass 'rfc1459',        ValidCaseMap;
should_pass 'ascii',          ValidCaseMap;
should_pass 'strict-rfc1459', ValidCaseMap;
should_fail 'foo',            ValidCaseMap;
should_fail [],               ValidCaseMap;

# ChannelObject
# FIXME

# StateObject
# FIXME

# UserObject
# FIXME

# TopicObject
# FIXME

# ChannelCollection
# FIXME

# UserCollection
# FIXME

# ModeSet
use IRC::Mode::Set;
my $mset = IRC::Mode::Set->new(mode_string => '+s');
should_pass $mset,      ModeSet;
should_fail bless([]),  ModeSet;

# ModeSingle
use IRC::Mode::Single;
my $msingle = IRC::Mode::Single->new('+', 's');
should_pass $msingle,   ModeSingle;
should_fail bless([]),  ModeSingle;


done_testing
