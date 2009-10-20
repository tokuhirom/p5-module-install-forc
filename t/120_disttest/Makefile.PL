BEGIN { unshift @INC, "../../lib"; }

use inc::Module::Install;

name 'Clib-disttestsample';
version 0.01;

my $env = env_for_c();
my $test = $env->test('t/01_simple', 't/01_simple.c');

tests('t/*.t');

WriteMakefileForC();
