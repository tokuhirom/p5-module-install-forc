use strict;
use warnings;
use Test::More;
use t::Utils;

setup();
cleanup('main');

run_makefile_pl();
ok -e 'Makefile';
run_make();
my $prefix = $^O eq 'linux' ? 'LD_LIBRARY_PATH=.' : '';
is `$prefix ./main`, "hi\n";
run_make('clean');

done_testing;
