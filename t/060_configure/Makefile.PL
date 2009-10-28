use inc::Module::Install;
name 'test';
version 0.01;
license 'perl';

my $env = env_for_c(CPPPATH => ['picoev/', 'picohttpparser/']);
$env->program('hello' => ["hello.c"]);

WriteMakefile();

