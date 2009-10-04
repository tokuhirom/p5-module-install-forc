use inc::Module::Install;
name 'test';
version 0.01;

my $env = env_for_c();
$env->program('main' => ["main.cc"]);

WriteMakefileForC();

