package IRC::Server::Toolkit::Channel::Topic;
use Defaults::Modern;
use Moo; use MooX::late;
use overload
  bool => sub { 1 },
  '""' => sub { shift->string },
  fallback => 1;

has string => (
  required  => 1,
  is        => 'ro',
  isa       => Str,
  writer    => 'set_string',
);

has setter => (
  lazy      => 1,
  is        => 'ro',
  isa       => Str,
  writer    => 'set_setter',
  builder   => sub { '' },
);

has ts     => (
  is        => 'ro',
  isa       => Num,
  writer    => 'set_ts',
  builder   => sub { time },
);

1;

=pod

=for Pod::Coverage set_\w+

=head1 NAME

IRC::Server::Toolkit::Channel::Topic

=head1 SYNOPSIS

FIXME

=head1 DESCRIPTION

A topic belonging to an L<IRC::Server::Toolkit::Channel>.

These objects stringify to the L</string> attribute.

=head2 Attributes

=head3 string

The topic string.

Required at construction time.

Can be set via B<set_string>

=head3 setter

The topic's setter (usually an IRC host identifier).

Defaults to the empty string.

Can be set via B<set_setter>

=head3 ts

The topic's timestamp.

Defaults to the current C<time()> (as of object construction).

Can be set via B<set_ts>

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut
