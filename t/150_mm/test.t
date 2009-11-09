use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use t::Utils;

plan skip_all => 'this test darwin' unless $^O eq 'darwin';

setup;

run_makefile_pl;
ok -e 'Makefile';
run_make();
is `./main`, 'Hello, world!';

done_testing;
