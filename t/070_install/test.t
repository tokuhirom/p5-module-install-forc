use strict;
use warnings;
use Test::More;
use t::Utils;

setup;
cleanup('local/bin/hello', <./local/lib/*>, <./local/bin/*>);

mkdir './local/'     unless -d './local/';
mkdir './local/bin/' unless -d './local/bin/';
mkdir './local/lib/' unless -d './local/lib/';

is scalar(<./local/bin/*>), undef;
is scalar(<./local/lib/*>), undef;

run_makefile_pl;
run_make('install');
run_make('clean');

isnt scalar(<./local/bin/*>), undef;
isnt scalar(<./local/lib/*>), undef;

done_testing;
