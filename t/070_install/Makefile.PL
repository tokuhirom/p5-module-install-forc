use inc::Module::Install;

name('test');
version(0.01);
license 'perl';

my $env = env_for_c(PREFIX => './local/');
$env->install_bin($env->program('hello', 'hello.c'));
$env->install_lib($env->shared_library('hello', 'hello.c'));

WriteMakefile();
