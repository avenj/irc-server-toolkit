use Test::More;
use strict; use warnings FATAL => 'all';

use IRC::Server::Toolkit::CaseMap;
use Scalar::Util 'refaddr';

my $rfc = IRC::Server::Toolkit::CaseMap->new('rfc1459');
isa_ok $rfc, 'IRC::Server::Toolkit::CaseMap';
ok "$rfc" eq 'rfc1459', 'stringify ok';

my $dupe = IRC::Server::Toolkit::CaseMap->new('rfc1459');
isa_ok $dupe, 'IRC::Server::Toolkit::CaseMap';
ok refaddr($rfc) == refaddr($dupe), 'flyweight ok';

my $ascii = IRC::Server::Toolkit::CaseMap->new('ascii');
cmp_ok $ascii, 'eq', 'ascii',
  'other types ok';

eval {; IRC::Server::Toolkit::CaseMap->new('foo') };
ok $@, 'invalid casemap dies ok';

done_testing
