use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;
use File::Path 'remove_tree';

chdir(dirname(__FILE__));

unshift @INC, "../../lib";

for (qw/a.out Makefile MANIFEST/) {
    unlink $_ if -f $_;
}
remove_tree('Clib-disttestsample-0.01') if -d 'Clib-disttestsample-0.01';

`make clean` if -f 'Makefile';
print `$^X -I../../lib/ Makefile.PL`;
`make`;
`make manifest`;
my $x = `make disttest`;
like $x, qr/All tests successful/;

done_testing;
