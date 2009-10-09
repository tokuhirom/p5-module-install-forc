use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;

chdir(dirname(__FILE__));

unshift @INC, "../../lib";
require inc::Module::Install;
inc::Module::Install->import();

for (qw/a.out Makefile/) {
    unlink $_ if -f $_;
}

{
    my $env = env_for_c();
    my $test = $env->test('t/01_simple', 't/01_simple.c');

    tests('t/*.t');

    WriteMakefileForC();
}

`make`;
my $x = `make test`;
like $x, qr/All tests successful/;

done_testing;
