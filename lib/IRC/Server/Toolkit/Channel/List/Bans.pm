package IRC::Server::Toolkit::Channel::List::Bans;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use Moo; use MooX::late;

# Order matters:
with 'IRC::Server::Toolkit::Role::DefaultCaseMap';
with 'IRC::Toolkit::Role::CaseMap';
with 'IRC::Server::Toolkit::Role::CaseMappedList';


around add => sub {
  my ($orig, $self, %bans) = @_;
  for my $mask (keys %bans) {
    my $meta = $bans{$mask};
    # FIXME array-type objs for these?
    $self->$orig( normalize_mask($mask) => $meta )
  }
};

1;
