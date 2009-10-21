use strict;
use warnings;
use Test::More;
use FindBin;
use t::Utils;

setup;
cleanup 'test-0.01';

run_makefile_pl;
run_make('manifest');
run_make('dist');
ok -f 'test-0.01.tar.gz';

done_testing;
