package IRC::Server::Toolkit::CaseMap;
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
  return $CaseMaps{$cmap} if exists $CaseMaps{$cmap};
  $CaseMaps{$cmap} = __PACKAGE__->_new($cmap)
}

1;
