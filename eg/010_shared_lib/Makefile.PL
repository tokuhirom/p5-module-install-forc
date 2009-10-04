use inc::Module::Install;
name 'test';
version 0.01;

my $env = env_for_c();
$env->shared_library('hello' => ['hoge.c']);

WriteMakefileForC;
