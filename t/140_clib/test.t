use strict;
use warnings;
use Test::More;
use t::Utils;
use Test::Requires 'Module::Install::Clib';

setup;
cleanup 'inst';

run_makefile_pl;
run_make();
ok -f './blib/arch/auto/Clib/include/test/foo.h', 'blib';
run_make('install');
ok -f './inst/auto/Clib/include/test/foo.h', 'inst';

done_testing;
