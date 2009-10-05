use strict;
use warnings;
use Test::More;
use File::Basename;
use Config;
use FindBin;

chdir(dirname(__FILE__));
unlink '100_dist_noconf-.tar.gz' if -f '100_dist_noconf-.tar.gz';

`$^X -I../../lib/ Makefile.PL`;
`make manifest`;
`make dist`;
ok -f '100_dist_noconf-.tar.gz';

done_testing;
