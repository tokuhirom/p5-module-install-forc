use inc::Module::Install;

my $env = env_for_c();
$env->static_library( 'hi' => ["hi.c"] );
$env->program( 'main' => ["main.c"], LIBS => ['hi'], LIBPATH => ['.'] );

WriteMakefileForC();

