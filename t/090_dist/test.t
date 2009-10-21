use strict;
use warnings;
use Test::More;
use FindBin;
use t::Utils;

plan skip_all => "This test requires tar, but win32 doesn't have it" if $^O eq 'MSWin32';

setup;
cleanup 'test-0.01';

run_makefile_pl;
run_make('manifest');
run_make('dist');
ok -f 'test-0.01.tar.gz';

done_testing;
