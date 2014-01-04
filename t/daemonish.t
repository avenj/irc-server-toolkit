use Test::More;
use strict; use warnings FATAL => 'all';

use IRC::Toolkit;
use IRC::Server::Toolkit;


##  IRC::Server::Toolkit
##    ::User
#       - stringifies to nick
#       - has nick (required)
#       - has user (required)
#       - has host (required)
#       - has full (builder/trigger)
#       - has realname (default empty str)
#       - has server   (default empty str)
#       - has ts       (default time())
#       - has channels (hash, strings or weak refs to objs?)
#       - has _valid_modes (hash, see existing)
#       - has _modes (hash? needs some sanity)
#       - has _flags (hash)
##    ::Collection::Users
#       - has casemap
#       - has _users (hash_of normalized nicks -> User objs)
##    ::Channel
#       - stringifies to name
#       - has name  (required)
#       - has ts    (default time())
#       - has _valid_modes (hash, mode classes to modes)
#       - has _nicknames (hash, strings to per-user metadata)
#       - has _lists (hash, strings to list objs)
#       - has _list_classes (hash, strings to class names)
#       - has _topic
##      >::Role::List
##       ::List::Invites
##       ::List::Bans
##       ::List::InvEx?
##       ::List::BanEx?
##    ::Collection::Channels
#       - has casemap (default rfc1459)
#       - has _channels (hash_of normalized chans -> Chan objs)
#       - has _status_mode_map (hash_of chars to symbols)
##  lower-priority:
##    ::Peer
##    ::Collection::Peers

done_testing
