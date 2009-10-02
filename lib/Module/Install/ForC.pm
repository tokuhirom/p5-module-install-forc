package Module::Install::ForC;
use strict;
use warnings;
our $VERSION = '0.01';
use 5.008000;
use Module::Install::ForC::Env;
use Config;

use Module::Install::Base;
our @ISA     = qw(Module::Install::Base);

our @targets;
our %OBJECTS;
our $postamble;

sub env_for_c {
    my $self = shift;
    Module::Install::ForC::Env->new(@_)
}
sub is_linux () { $^O eq 'linux'  }
sub is_mac   () { $^O eq 'darwin' }
sub WriteMakefileForC {
    my $self = shift;

    $self->requires_external_cc();
    $self->admin->copy_package('Module::Install::ForC::Env');

    open my $fh, '>', 'Makefile' or die "cannot open file: $!";
    print $fh <<"...";
all: @Module::Install::ForC::targets

clean:
	rm @Module::Install::ForC::targets @{[ keys %Module::Install::ForC::OBJECTS ]}
	rm Makefile
	$Config{rm_try}

$Module::Install::ForC::postamble
...
    close $fh;
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

=head1 FUNCTIONS

=over 4

=item is_linux()

=item is_mac()

Is this the OS or not?

=item WriteMakefileForC()

Write makefile in M::I::ForC style.

=item my $env = env_for_c(CPPPATH => ['picoev/', 'picohttpparser/']);

env() returns the instance of M::I::ForC::Env.

$env contains the build environment variables.The key name is a generic value for C.If you want to know about key names, see also L<Module::Install::ForC::Env>.

=back

=head1 FAQ

=over 4

=item How to check that a library is available.

You can use Module::Install::CheckLib.

    checklib lib => 'jpeg', header => 'jpeglib.h';

=item What's supported platforms?

Currently GNU/Linux, and other POSIX systems, and OSX.
(mattn-san add the win32 support soon :P)

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

=head1 SEE ALSO

This module is inspired by SCons(L<http://www.scons.org/>).

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
