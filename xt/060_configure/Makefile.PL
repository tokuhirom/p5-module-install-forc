use inc::Module::Install;

my $env = env_for_c(CPPPATH => ['picoev/', 'picohttpparser/']);
$env->program('hello' => ["hello.c"]);

WriteMakefileForC();

