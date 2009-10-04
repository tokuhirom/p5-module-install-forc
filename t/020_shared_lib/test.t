use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;

my $make = $Config{make};

chdir(dirname(__FILE__));

for (qw/Makefile hello.o inc libhi.so hi.o main/) {
    unlink $_ if -f $_ || -d $_;
}

system $^X,  '-I../../lib/', 'Makefile.PL';
ok -e 'Makefile';
system "$make";
is `LD_LIBRARY_PATH=. ./main`, "hi\n";
`$make clean`;

done_testing;
