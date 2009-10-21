package Module::Install::ForC::Command;
use strict;
use warnings;

sub mk_testfile {
    my ($src, $dst) = @ARGV;
    open my $fh, '>', $dst or die $!;
    print $fh "exec q{$src} or die \$!";
    close $fh;
}

1;
