use inc::Module::Install;

my $env = env_for_c();
$env->program('test' => ["test.cc"]);

WriteMakefileForC();

