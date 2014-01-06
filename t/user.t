use Test::More;
use strict; use warnings FATAL => 'all';

use IRC::Mode::Set;
use List::Objects::WithUtils;

use IRC::Server::Toolkit::User;

my $usr = IRC::Server::Toolkit::User->new(
  nick    => 'avenj',
  user    => 'silentj',
  host    => 'eris.oppresses.us',
);

# stringify
cmp_ok "$usr", 'eq', 'avenj', 'stringify ok';

# defaults
cmp_ok $usr->realname, 'eq', '', 'default realname ok';
cmp_ok $usr->server,   'eq', '', 'default server ok';

# full + set_(nick, user, host) triggers
cmp_ok $usr->full, 'eq', 'avenj!silentj@eris.oppresses.us',
  'full composed ok';

$usr->set_nick('Avenj');
cmp_ok $usr->full, 'eq', 'Avenj!silentj@eris.oppresses.us',
  'full rebuilt on nick trigger ok';
$usr->set_nick('avenj');

$usr->set_user('avenj');
cmp_ok $usr->full, 'eq', 'avenj!avenj@eris.oppresses.us',
  'full rebuilt on user trigger ok';
$usr->set_user('silentj');

$usr->set_host('eris.cobaltirc.org');
cmp_ok $usr->full, 'eq', 'avenj!silentj@eris.cobaltirc.org',
  'full rebuilt on host trigger ok';
$usr->set_host('eris.oppresses.us');

# user modes
ok $usr->modes->keys->is_empty, 'modes() ok';
my $change = $usr->set_mode(
  IRC::Mode::Set->new(
    mode_array => [
      [ '+', 'w' ],
      [ '+', 'i' ],
      [ '-', 's' ],
      [ '+', 'f', 'foo' ],
    ],
  )
);
isa_ok $change, 'IRC::Mode::Set';
my $mode_result = array(@{ $change->mode_array })->sort_by(sub { $_->[1] });
is_deeply
  [ $mode_result->all ],
  [
    [ '+', 'f', 'foo' ],
    [ '+', 'i', -1 ],
    [ '+', 'w', -1 ],
  ],
  'set_mode ok' or diag explain $mode_result;

# FIXME
# channels, requires working Channel objs

# exceptions
eval {; IRC::Server::Toolkit::User->new };
ok $@, 'missing required init args dies';

# FIXME channel-related exceptions
#   bad args to add_channel

done_testing
