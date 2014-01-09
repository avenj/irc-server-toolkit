package IRC::Server::Toolkit;
use Defaults::Modern;

state @modules = qw/
  User
  Collection::Users
  Channel
  Collection::Channels
/;

sub import {
  my (undef, @load) = @_;
  @load = @modules unless @load;
  my $pkg = caller;
  my @failed;
  for my $mod (@load) {
    my $ld = "package $pkg; use IRC::Server::Toolkit::$mod";
    local $@;
    eval $ld and not $@ or carp $@ and push @failed, $mod;
  }
  confess "Failed to import ".join ' ', @failed if @failed;
  1
}

1;

# vim: ts=2 sw=2 et sts=2 ft=perl
