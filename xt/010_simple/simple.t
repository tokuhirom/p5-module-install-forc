use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;

for (qw/Makefile hello.o inc/) {
    unlink $_ if -f $_ || -d $_;
}

chdir(dirname(__FILE__));
system $^X,  '-I../../lib/', 'Makefile.PL';
ok -e 'Makefile';
system $Config{make};
is `./hello`, 'Hello, world!';

done_testing;