package Module::Install::ForC;
use strict;
use warnings;
our $VERSION = '0.10';
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
    Module::Install::ForC::Env->new($self, @_)
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

    my $mm = ExtUtils::MM->new(
        {
            NAME         => $self->name,
            VERSION      => $self->version,
        }
    );
    my $mm_params = join("\n", map { $_.'='.($mm->{$_} || '') } qw/FIRST_MAKEFILE MOD_INSTALL ABSPERL ABSPERLRUN VERBINST UNINST PERM_DIR PERL PREOP TRUE TAR RM_F RM_RF NOECHO NOOP INSTALLARCHLIB INSTALL_BASE DIST_CP DIST_DEFAULT POSTOP COMPRESS TARFLAGS TO_UNIX PERLRUN DISTVNAME VERSION NAME ECHO MAKE MV SUFFIX ZIP SHAR FULLPERLRUN FULLPERL/);
    (my $make = <<"...") =~ s/^[ ]{4}/\t/gmsx;
$mm_params
TEST_VERBOSE=0
TEST_FILES=@{[ $self->tests || '' ]}

.PHONY: all config static dynamic test linkext manifest blibdirs clean realclean disttest distdir

all: @Module::Install::ForC::TARGETS

config :: \$(FIRST_MAKEFILE)
    \$(NOECHO) \$(NOOP)

test: @TESTS
    @{[ $mm->test_via_harness('\$(FULLPERLRUN)', '\$(TEST_FILES)') ]}

dist: \$(DIST_DEFAULT) \$(FIRST_MAKEFILE)

clean:
	\$(RM_F) @Module::Install::ForC::TARGETS @{[ keys %Module::Install::ForC::OBJECTS ]}

realclean :: clean
	\$(RM_F) Makefile
    \$(RM_RF) \$(DISTVNAME)
	@{[ $Config{rm_try} || '' ]}

install: all config
	@{[ join("\n\t", map { @{ $_ } } values %Module::Install::ForC::INSTALL) ]}
    \$(NOECHO) \$(NOOP)

@{[ $mm->metafile_target ]}

@{[ $mm->distmeta_target ]}

@{[ $mm->distdir ]}

@{[ $mm->dist_test ]}

# dist_basics
@{[ $mm->dist_basics ]}

# dist_core
@{[ $mm->dist_core ]}

@{[ $Module::Install::ForC::POSTAMBLE || '' ]}

@{[ $self->postamble || '' ]}
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
