package IRC::Server::Toolkit::Collection::Users;
use Defaults::Modern;

use IRC::Toolkit::Masks;

use Module::Runtime 'use_module';

use Moo; use MooX::late;

has casemap => (
  required => 1,
  is       => 'ro',
  isa      => sub {
    # FIXME validate casemap (IRC::Toolkit::Types?)
  },
);

with 'IRC::Toolkit::Role::CaseMap';


has _users => (
  # normalized nicks -> user objs
  lazy    => 1,
  is      => 'ro',
  isa     => HashObj,
  coerce  => 1,
  builder => sub { hash },
);

has user_class => (
  lazy    => 1,
  is      => 'ro',
  isa     => Str,
  builder => sub { use_module('IRC::Server::Toolkit::User') },
);

method create_and_add (@params) {
  $self->add_users( $self->user_class->new(@params) )
}

method add_users (@users) {
  my $user_class = $self->user_class;
  for my $user (@users) {
    confess "Expected an instance of $user_class but got $user"
      unless blessed $user and $user->isa($user_class);
    my $nick = $self->lower( $user->nick );
    confess "Attempted to add previously extant nick $nick"
      if $self->_users->exists($nick);
    $self->_users->set($nick => $user)
  }
  $self
}
{ no warnings 'once'; *add_user = *add_users }

method del_users (@users) {
  my @deleted;
  for my $user (@users) {
    my $nick = blessed $user ? $self->lower( $user->nick ) : $user;
    push @deleted, $nick if $self->_users->delete($nick)
  }
  @deleted
}
{ no warnings 'once'; *del_user = *del_users }

method as_list  { $self->_users->values->all }
method as_array { $self->_users->values }
method nickname_list { map {; $_->nick } $self->_users->values->all }
method nickname_array { $self->_users->values->map(sub { $_->nick }) }

method by_name (Str $nick) { $self->_users->get( $self->lower($nick) ) }
{ no warnings 'once'; *by_nick = *by_name }

method matching_nick (Str $mask) {
  my $cmap = $self->casemap;
  my $matches = array;
  for ($self->_users->kv->all) {
    my ($nick, $obj) = @$_;
    $matches->push($obj) if matches_mask( $mask, $nick, $cmap )
  }
  $matches->has_any ? $matches : ()
}

method matching_host (Str $mask) {
  my $cmap = $self->casemap;
  my $matches = array;
  $self->_users->values->visit(
    sub { $matches->push($_) if matches_mask( $mask, $_->host, $cmap ) }
  )
  $matches->has_any ? $matches : ()
}

method matching_user (Str $mask) {
  my $cmap = $self->casemap;
  my $matches = array;
  $self->_users->values->visit(
    sub { $matches->push($_) if matches_mask( $mask, $_->user, $cmap ) }
  )
  $matches->has_any ? $matches : ()
}

method matching_full (Str $mask) {
  my $cmap = $self->casemap;
  my $matches = array;
  $self->_users->values->visit(
    sub { $matches->push($_) if matches_mask( $mask, $_->full, $cmap ) }
  )
  $matches->has_any ? $matches : ()
}


1;

=pod

=head1 NAME

IRC::Server::Toolkit::Collection::Users - A set of User objects

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Attributes

=head2 Methods

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>


=cut
