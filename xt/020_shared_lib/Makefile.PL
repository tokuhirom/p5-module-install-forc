use inc::Module::Install;

my $env = env_for_c();
$env->shared_library( 'hi' => ["hi.c"] );
$env->program( 'main' => ["main.c"], LIBS => ['hi'], LIBPATH => ['.'] );

WriteMakefileForC();

