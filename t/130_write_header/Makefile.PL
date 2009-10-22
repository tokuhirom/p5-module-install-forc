use inc::Module::Install;
name 'test';
version 0.01;

my $env = env_for_c();
$env->have_library('c');
$env->have_header('stdio.h');

WriteHeaderForC('test_config.h');
