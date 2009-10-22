use strict;
use warnings;
use Test::More;
use t::Utils;

setup();
cleanup('test_config.h');

run_makefile_pl();
ok -e 'test_config.h';
open my $fh, '<', 'test_config.h' or die $!;
my $src = do { local $/; <$fh> };
like $src, qr/#define HAVE_STDIO_H 1/;
like $src, qr/#define HAVE_LIBC 1/;

done_testing;
