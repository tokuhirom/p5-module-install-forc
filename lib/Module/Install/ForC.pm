package Module::Install::ForC;
use strict;
use warnings;
our $VERSION = '0.07';
use 5.008000;
use Module::Install::ForC::Env;
use Config;              # first released with perl 5.00307
use File::Basename ();   # first released with perl 5
use FindBin;             # first released with perl 5.00307

use Module::Install::Base;
our @ISA     = qw(Module::Install::Base);

our @TARGETS;
our %OBJECTS;
our $POSTAMBLE;
our @TESTS;
our %INSTALL;

sub env_for_c {
    my $self = shift;
    $self->admin->copy_package('Module::Install::ForC::Env');
    Module::Install::ForC::Env->new(@_)
}
sub is_linux () { $^O eq 'linux'  }
sub is_mac   () { $^O eq 'darwin' }
sub is_win32 () { $^O eq 'MSWin32' }
sub WriteMakefileForC {
    my $self = shift;

    my $src = $self->_gen_makefile();

    open my $fh, '>', 'Makefile' or die "cannot open file: $!";
    print $fh $src;
    close $fh;
}

sub _gen_makefile {
    my $self = shift;
    $self->name(File::Basename::basename($FindBin::Bin)) unless $self->name;
    $self->version('') unless defined $self->version;

    (my $make = <<"...") =~ s/^[ ]{4}/\t/gmsx;
RM=$Config{rm}
NAME=@{[ $self->name ]}
FIRST_MAKEFILE=Makefile
NOECHO=@
TRUE = true
NOOP = \$(TRUE)
PERL = $^X
VERSION = @{[ $self->version ]}
DISTVNAME = \$(NAME)-\$(VERSION)
PREOP = \$(PERL) -I. "-MModule::Install::Admin" -e "dist_preop(q(\$(DISTVNAME)))"
TO_UNIX = \$(NOECHO) \$(NOOP)
TAR = tar
TARFLAGS = cvf
RM_RF = rm -rf
COMPRESS = gzip --best
POSTOP = \$(NOECHO) \$(NOOP)
DIST_DEFAULT = tardist
DIST_CP = best
PERLRUN = \$(PERL)
TEST_VERBOSE=0
TEST_FILES=@{[ $self->tests || '' ]}

all: @Module::Install::ForC::TARGETS

test: @TESTS
    PERL_DL_NONLAZY=1 \$(PERLRUN) "-MExtUtils::Command::MM" "-e" "test_harness(\$(TEST_VERBOSE), 'inc')" \$(TEST_FILES)

dist: \$(DIST_DEFAULT) \$(FIRST_MAKEFILE)

tardist: \$(NAME).tar.gz
    \$(NOECHO) \$(NOOP)

\$(NAME).tar.gz: distdir Makefile
    \$(PREOP)
    \$(TO_UNIX)
    \$(TAR) \$(TARFLAGS) \$(DISTVNAME).tar \$(DISTVNAME)
    \$(RM_RF) \$(DISTVNAME)
    \$(COMPRESS) \$(DISTVNAME).tar
    \$(POSTOP)

distdir:
    \$(RM_RF) \$(DISTVNAME)
    \$(PERLRUN) "-MExtUtils::Manifest=manicopy,maniread" \\
        -e "manicopy(maniread(),'\$(DISTVNAME)', '\$(DIST_CP)');"

clean:
	\$(RM) @Module::Install::ForC::TARGETS @{[ keys %Module::Install::ForC::OBJECTS ]}
	\$(RM) Makefile
	@{[ $Config{rm_try} || '' ]}

install: all
	@{[ join("\n\t", map { @{ $_ } } values %Module::Install::ForC::INSTALL) ]}

manifest:
	$^X -MExtUtils::Manifest -e 'ExtUtils::Manifest::mkmanifest()'

@{[ $Module::Install::ForC::POSTAMBLE || '' ]}
...
    $make;
}

1;
__END__

=head1 NAME

Module::Install::ForC - the power of M::I for C programs

=head1 SYNOPSIS

    # in your Makefile.PL
    use inc::Module::Install;

    my $env = env_for_c(CPPPATH => ['picoev/', 'picohttpparser/']);
    $env->program('testechoclient' => ["testechoclient.c"]);

    WriteMakefileForC();

    # then, you will get the Makefile:
    all: testechoclient

    clean:
        rm testechoclient testechoclient.o
        rm Makefile

    testechoclient: testechoclient.o
        cc   -fstack-protector -L/usr/local/lib -o testechoclient testechoclient.o

    testechoclient.o: testechoclient.c
        cc -DDEBUGGING -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -I picoev/ -I picohttpparser/ -c -o testechoclient.o testechoclient.c


=head1 DESCRIPTION

Module::Install::ForC is a extension library for Module::Install.

This module provides some useful functions for writing C/C++ programs/libraries, doesn't depend to Perl.

M::Install is useful for Perl/XS programming, but this module provides M::I power for C/C++ programs!You can use this module as replacement of autoconf/automake for easy case.

=head1 NOTE

This is a early BETA release! API will change later.

=head1 FUNCTIONS

=over 4

=item is_linux()

=item is_mac()

=item is_win32()

Is this the OS or not?

=item WriteMakefileForC()

Write makefile in M::I::ForC style.

=item my $env = env_for_c(CPPPATH => ['picoev/', 'picohttpparser/']);

env() returns the instance of M::I::ForC::Env.

$env contains the build environment variables.The key name is a generic value for C.If you want to know about key names, see also L<Module::Install::ForC::Env>.

=back

=head1 FAQ

=over 4

=item What is supported platform?

Currently GNU/Linux, OpenSolaris, Mac OSX, and MSWin32.

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

mattn(win32 port)

=head1 SEE ALSO

This module is inspired by SCons(L<http://www.scons.org/>).

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
