use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;

chdir(dirname(__FILE__));
unlink 'test-0.01.tar.gz' if -f 'test-0.01.tar.gz';

`$^X -I../../lib/ Makefile.PL`;
`make manifest`;
`make dist`;
ok -f 'test-0.01.tar.gz';

done_testing;
