use inc::Module::Install;
name 'test';
version 0.01;
license 'perl';

my $env = env_for_c(CC => 'tcc');
$env->program('main' => ["main.c"]);

WriteMakefileForC();

