use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use t::Utils;

setup;
cleanup 'main';

run_makefile_pl;
ok -e 'Makefile';
run_make();
is `./main`, "hi\n";
run_make('clean');

done_testing;
