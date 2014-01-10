package IRC::Server::Toolkit::Channel::List::Invites;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use Moo; use MooX::late;


with 'IRC::Server::Toolkit::Role::DefaultCaseMap';
with 'IRC::Toolkit::Role::CaseMap';
with 'IRC::Server::Toolkit::Role::CaseMappedList';

around add => sub {
  my ($orig, $self, %inv) = @_;
  for my $nick (keys %inv) {
    my $meta = $inv{$nick};
    # FIXME array-type objs for these?
    $self->orig( $self->lower($nick) => $meta )
  }
};

1;
