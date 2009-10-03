use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;

plan skip_all => 'this test requires /usr/bin/tcc' unless -x '/usr/bin/tcc';

chdir(dirname(__FILE__));
for (qw/Makefile main.o main inc/) {
    unlink $_ if -f $_ || -d $_;
}

system $^X,  '-I../../lib/', 'Makefile.PL';
ok -e 'Makefile';
system $Config{make};
is `./main`, 'Hello, world!';

done_testing;
