use inc::Module::Install;

my $env = env_for_c();
$env->static_library( 'hi' => ["hi.c"] );
$env->program( 'test' => ["test.c"], LIBS => ['hi'], LIBPATH => ['.'] );

WriteMakefileForC();

