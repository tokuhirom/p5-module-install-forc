use inc::Module::Install;

my $env = env();
$env->shared_library('hello' => ['hoge.c']);

WriteMakefileForC;
