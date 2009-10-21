use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;
use t::Utils;

setup;
cleanup <assertlib*>;

unshift @INC, '../../lib';
require inc::Module::Install;
inc::Module::Install->import();

my $env = env_for_c();

ok $env->try_cc('int main () { }');
ok $env->have_header('stdio.h');
ok !$env->have_header('unknown-header.h');

ok $env->have_library('m');
ok !$env->have_library('unknown-library');

ok $env->have_type('pid_t', "#include <sys/types.h>\n") if $^O eq 'darwin' || $^O eq 'linux';
ok !$env->have_type('unkonwn_type_t');
ok !-f'a.out';

done_testing;
