use Test::More;
use strict; use warnings FATAL => 'all';
use List::Objects::WithUtils 'array';

use IRC::Server::Toolkit::User;
use IRC::Server::Toolkit::Collection::Users;

my $users = IRC::Server::Toolkit::Collection::Users->new(
  casemap => 'rfc1459',
);
cmp_ok $users->casemap, 'eq', 'rfc1459',
  'casemap ok';

# user_class
cmp_ok $users->user_class, 'eq', 'IRC::Server::Toolkit::User',
  'user_class ok';

# create_and_add
my $added = $users->create_and_add(
  nick => 'avenj',
  user => 'avenj',
  host => 'eris.oppresses.us'
);
cmp_ok $added->nick, 'eq', 'avenj',
  'create_and_add returned user obj';

# count
cmp_ok $users->count, '==', 1, '1 user in collection';

# add_user(s)
ok $users->add_users(
  IRC::Server::Toolkit::User->new(
    nick    => 'UC235',
    user    => 'thor',
    host    => 'foo.example.org',
  ),

  IRC::Server::Toolkit::User->new(
    nick    => 'Diziara',
    user    => 'diziara',
    host    => 'bar.example.org',
  ),
) == $users, 'add_users ok';

# as_list
my $as_list = array($users->as_list)->sort_by(sub { lc $_->nick });
is_deeply 
  [ $as_list->map(sub { $_->nick })->all ],
  [ 'avenj', 'Diziara', 'UC235' ],
  'as_list ok';

# as_array
my $as_array = $users->as_array->sort_by(sub { lc $_->nick });
is_deeply
  [ $as_array->map(sub { $_->nick })->all ],
  [ 'avenj', 'Diziara', 'UC235' ],
  'as_array ok';

# nickname_list
$as_list = array($users->nickname_list)->sort_by(sub { lc });
is_deeply
  [ $as_list->all ],
  [ 'avenj', 'Diziara', 'UC235' ],
  'nickname_list ok';

# nickname_array
$as_array = $users->nickname_array->sort_by(sub { lc });
is_deeply
  [ $as_array->all ],
  [ 'avenj', 'Diziara', 'UC235' ],
  'nickname_array ok';

# by_name/by_nick
my $avenj = $users->by_name('avenj');
cmp_ok $avenj->nick, 'eq', 'avenj',
  'by_name ok';
cmp_ok $users->by_nick('avenj'), 'eq', $users->by_name('avenj'),
  'by_nick ok';

# del_user(s)
my @deleted = $users->del_users('Diziara');
cmp_ok @deleted, '==', 1, '1 user deleted';
my $dizi = shift @deleted;
cmp_ok $dizi->nick, 'eq', 'Diziara',
  'del_users ok';
ok $users->add_user($dizi) == $users, 'add_user ok';
@deleted = $users->del_user('Diziara');
$dizi = shift @deleted;
cmp_ok $dizi->nick, 'eq', 'Diziara',
  'del_user ok';
$users->add_user($dizi);

# matching_nick
my $matches = $users->matching_nick('*a*');
is_deeply
  [ $matches->map(sub { "$_" })->sort_by(sub { lc })->all ],
  [ 'avenj', 'Diziara' ],
  'matching_nick ok';

# matching_host
$matches = $users->matching_host('*.example.org');
is_deeply
  [ $matches->map(sub { "$_"})->sort_by(sub { lc })->all ],
  [ 'Diziara', 'UC235' ],
  'matching_host ok';

# matching_user
$matches = $users->matching_user('*a*');
is_deeply
  [ $matches->map(sub { "$_" })->sort_by(sub { lc })->all ],
  [ 'avenj', 'Diziara' ],
  'matching_user ok';

# matching_full
$matches = $users->matching_full('*@*.example.org');
is_deeply
  [ $matches->map(sub { "$_" })->sort_by(sub { lc })->all ],
  [ 'Diziara', 'UC235' ],
  'matching_full ok';

# grep
$matches = $users->grep(sub { $_->nick =~ /a/ });
is_deeply
  [ $matches->map(sub { "$_" })->sort_by(sub { lc })->all ],
  [ 'avenj', 'Diziara' ],
  'grep ok';

# nick normalization / non-standard casemaps
# FIXME

# exceptions
# FIXME


done_testing
