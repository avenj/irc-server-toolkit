package IRC::Server::Toolkit::CaseMaps;
use Defaults::Modern
  -with_types => [
    'IRC::Server::Toolkit::Types'
  ];

use overload
  bool => sub { 1 },
  '""' => sub { shift->as_string },
  fallback => 1;

method _new ($class: $cmap) { bless \$cmap, $class }
method as_string { $$self }

our %CaseMaps;

method new ($class: ValidCaseMap $cmap) {
  exists $CaseMaps{$cmap} ? $CaseMaps{$cmap}
    : $CaseMaps{$cmap} = IRC::Server::Toolkit::_CMAP->new($cmap)
}

1;
