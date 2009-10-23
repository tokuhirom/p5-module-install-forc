use inc::Module::Install;

my $env = env_for_c();
my $test = $env->test('t/01_simple', 't/01_simple.c');

tests('t/*.t');

WriteMakefileForC();

