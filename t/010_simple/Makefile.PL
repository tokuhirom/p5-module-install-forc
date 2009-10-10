use inc::Module::Install;
name 'test';
version 0.01;

my $env = env_for_c(CPPPATH => ['picoev/', 'picohttpparser/']);
$env->enable_warnings();
$env->program('hello' => ["hello.c"]);

WriteMakefileForC();

