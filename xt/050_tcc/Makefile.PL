use inc::Module::Install;

my $env = env_for_c(CC => 'tcc');
$env->program('main' => ["main.c"]);

WriteMakefileForC();

