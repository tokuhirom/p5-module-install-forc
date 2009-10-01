use inc::Module::Install;

my $env = env_for_c();
$env->shared_library('hello' => ['hoge.c']);

WriteMakefileForC;
