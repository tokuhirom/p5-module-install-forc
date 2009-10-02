use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;

for (qw/Makefile hello.o/) {
    unlink $_ if -f $_;
}

my $dir = dirname(__FILE__);
chdir($dir);
system $^X,  '-I../../lib/', 'Makefile.PL';
ok -e 'Makefile';
system $Config{make};
is `./hello`, 'Hello, world!';

done_testing;
