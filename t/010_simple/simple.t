use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use t::Utils;

setup;
cleanup(qw/Makefile hello.o inc/);

run_makefile_pl();
ok -e 'Makefile';
run_make();
is `./hello`, 'Hello, world!';
run_make('clean');
ok !-e'hello.o';

done_testing;
