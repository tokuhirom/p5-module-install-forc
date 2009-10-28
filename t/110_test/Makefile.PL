use inc::Module::Install;
license 'perl';
name '110_test';
version 0.01;

my $env = env_for_c();
my $test = $env->test('t/01_simple', 't/01_simple.c');

tests('t/*.t');

WriteMakefile();

