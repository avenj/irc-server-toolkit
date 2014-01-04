package IRC::Server::Toolkit::Collection::Users;
use Defaults::Modern;


use Moo; use MooX::late;

has casemap => (
  required => 1,
  is       => 'ro',
  isa      => sub {
    # FIXME validate casemap
  },
);

with 'IRC::Toolkit::Role::CaseMap';


has _users => (
  # normalized nicks -> user objs
  lazy    => 1,
  is      => 'ro',
  isa     => HashObj,
  coerce  => 1,
  default => sub { hash },
);

method add_users (@users) {
  # FIXME
}
{ no warnings 'once'; *add_user = *add_users }

method del_users (@users) {
  # FIXME take strs or objs
}
{ no warnings 'once'; *del_user = *del_users }

method as_list  { $self->_users->values->all }
method as_array { $self->_users->values }
method nickname_list { map {; $_->nick } $self->_users->values->all }
method nickname_array { $self->_users->values->map(sub { $_->nick }) }

method by_name (Str $nick) { $self->_users->get( $self->lower($nick) ) }
{ no warnings 'once'; *by_nick = *by_name }

method nick_matching (Str $mask) {
  # FIXME
}

method host_matching (Str $mask) {
  # FIXME
}

method user_matching (Str $mask) {
  # FIXME
}

method full_matching (Str $mask) {
  # FIXME
}


1;
