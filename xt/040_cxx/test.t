use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;

chdir(dirname(__FILE__));
for (qw/Makefile test test.o inc/) {
    unlink $_ if -f $_ || -d $_;
}

system $^X,  '-I../../lib/', 'Makefile.PL';
ok -e 'Makefile';
system $Config{make};
is `./test`, "hoge\n";

done_testing;
