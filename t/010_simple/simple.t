use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;

chdir(dirname(__FILE__));
for (qw/Makefile hello.o inc/) {
    unlink $_ if -f $_ || -d $_;
}

system $^X,  '-I../../lib/', 'Makefile.PL';
ok -e 'Makefile';
system $Config{make};
is `./hello`, 'Hello, world!';
`make clean`;
ok !-e'hello.o';

done_testing;
