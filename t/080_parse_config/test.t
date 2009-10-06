use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;

chdir(dirname(__FILE__));

{
    unshift @INC, '../../lib';
    require inc::Module::Install;
    inc::Module::Install->import();

    my $env = env_for_c(LIBS => ['foo'], );
    my $ret = $env->parse_config('-lm -L/usr/local/lib/ -I /usr/local/include');
    is ref($ret), ref($env);
    is_deeply $env->{LIBS}, ['foo', 'm'];
    is_deeply $env->{LIBPATH}, ['/usr/local/lib/'];
    is_deeply $env->{CPPPATH}, ['/usr/local/include'];
}

done_testing;
