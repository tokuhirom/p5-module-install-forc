use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;

chdir(dirname(__FILE__));
for (qw(./local/bin/hello/ Makefile)) {
    unlink $_ if -e $_;
}

mkdir './local/' unless -d './local/';
mkdir './local/bin/' unless -d './local/bin/';

ok !-e './local/bin/hello';

{
    unshift @INC, '../../lib';
    require inc::Module::Install;
    inc::Module::Install->import();

    my $env = env_for_c(PREFIX => './local/');
    $env->program('hello', 'hello.c');
    $env->install_bin('hello');
    WriteMakefileForC();
}
`make install`;

ok -e './local/bin/hello';

done_testing;
