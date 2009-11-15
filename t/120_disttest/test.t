use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;
use t::Utils;

setup;
cleanup('Clib-disttestsample-0.01');

unshift @INC, "../../lib";

run_makefile_pl;
run_make;
run_make('manifest');
my $x = `$make disttest`;
like $x, qr/All tests successful/;

done_testing;
