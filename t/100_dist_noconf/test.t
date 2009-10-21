use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;
use t::Utils;

setup;

run_makefile_pl;
run_make('manifest');
run_make('dist');
ok -f '100_dist_noconf-.tar.gz';

done_testing;
