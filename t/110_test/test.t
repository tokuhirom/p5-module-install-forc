use strict;
use warnings;
use Test::More;
use t::Utils;

setup;

run_makefile_pl;
run_make();
my $x = `$make test`;
like $x, qr/All tests successful/;

done_testing;
