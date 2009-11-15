use strict;
use warnings;
use Test::More;
use t::Utils;

# this test fails if c++ compiler is not installed

setup();

run_makefile_pl();
ok -e 'Makefile';
run_make();
is `./main`, "hoge\n";

done_testing;
