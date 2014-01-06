use Test::More;
use strict; use warnings FATAL => 'all';

use IRC::Server::Toolkit::Channel::Topic;

my $topic = IRC::Server::Toolkit::Channel::Topic->new(
  string => 'this is a topic',
  setter => 'foo!bar@example.org',
  ts     => 0,
);

cmp_ok $topic->string, 'eq', 'this is a topic',
  'string ok';

cmp_ok $topic->setter, 'eq', 'foo!bar@example.org',
  'setter ok';

cmp_ok $topic->ts, '==', 0,
  'ts ok';

cmp_ok $topic, 'eq', 'this is a topic',
  'stringification ok';

done_testing
