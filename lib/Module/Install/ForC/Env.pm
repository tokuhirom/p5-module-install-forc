package Module::Install::ForC::Env;
use strict;
use warnings;
use Storable ();
use Config;
use File::Temp;
use POSIX;

sub new {
    my $class = shift;

    # platform specific vars
    my %platformvars = do {
        my %unix = (
            CC            => 'gcc',
            CPP           => 'cpp',
            CXX           => 'g++',
            LIBPREFIX     => 'lib',
            LIBSUFFIX     => '.a',
            SHLIBPREFIX   => 'lib',
            LDMODULEFLAGS => ['-shared'],
        );
        my %win32 = (
            CC          => 'gcc',
            CXX         => 'g++',
            LIBPREFIX   => '',
            LIBSUFFIX   => '.lib',
            SHLIBPREFIX => '',
        );
        my %darwin = ( LDMODULEFLAGS => ['-dynamiclib'], );

          $^O eq 'MSWin32' ? %win32
        : $^O eq 'darwin'  ? (%unix, %darwin)
        : %unix;
    };
    my $opt = {
        LD            => $Config{ld},
        LDFLAGS       => '',
        CCFLAGS       => [],
        CPPPATH       => [],
        LIBS          => [],
        LIBPATH       => [],
        CCCDLFLAGS    => [], # TODO: rename
        SHLIBSUFFIX   => '.' . $Config{so},
        RANLIB        => 'ranlib',
        PROGSUFFIX    => ( $Config{exe_ext} ? ( '.' . $Config{exe_ext} ) : '' ),
        CXXFILESUFFIX => [ '.c++', '.cc', '.cpp', '.cxx' ],
        CFILESUFFIX   => ['.c'],
        AR            => $Config{ar},
        %platformvars,
        @_
    };
    for my $key (qw/CPPPATH LIBS CLIBPATH LDMODULEFLAGS CCFLAGS/) {
        $opt->{$key} = [$opt->{$key}] unless ref $opt->{$key};
    }
    my $self = bless $opt, $class;

    # fucking '.C' extension support.
    if ($^O eq 'Win32' || $^O eq 'darwin') {
        # case sensitive fs.Yes, I know the darwin supports case-sensitive fs.
        # But, also supports case-insensitive one :)
        push @{$self->{CFILESUFFIX}}, '.C';
    } else {
        push @{$self->{CXXFILESUFFIX}}, '.C';
    }

    return $self;
}

sub try_cc {
    my ($self, $src) = @_;
    my ( $ch, $cfile ) = File::Temp::tempfile(
        'assertlibXXXXXXXX',
        SUFFIX => '.c'
        UNLINK => 1,
    );
    print $ch $src;
    my $exit_status = system "$self->{CC} @{[ $self->_cpppath ]} @{ $self->{CCFLAGS} } $cfile";
    WIFEXITED($exit_status) && WEXITSTATUS($exit_status) == 0 ? 1 : 0;
}

sub have_header {
    my ($self, $header,) = @_;
    $self->try_cc("#include <$header>\nint main() { return 0; }");
}

sub require_header {
    my ($self, $header,) = @_;
    $self->have_header($header) or die "Missing required header: '$header'";
}

sub clone {
    my ($self, ) = @_;
    return Storable::dclone($self);
}

sub append {
    my $self = shift;
    while (my ($key, $val) = splice(@_, 0, 2)) {
        if ((ref($self->{$key})||'') eq 'ARRAY') {
            push @{ $self->{$key} }, @{$val};
        } else {
            $self->{$key} = $val;
        }
    }
    return $self; # for chain
}

sub _objects {
    my ($self, $srcs) = @_;
    my @objects;
    my $regex = join('|', map { quotemeta($_) } @{$self->{CXXFILESUFFIX}}, @{$self->{CFILESUFFIX}});
    for my $src (@$srcs) {
        if ((my $obj = $src) =~ s/$regex/$Config{obj_ext}/) {
            push @objects, $obj;
        } else {
            die "unknown src file type: $src";
        }
    }
    @objects;
}

sub _libs {
    my $self = shift;
    return map { "-l$_" } @{$self->{LIBS}};
}

sub _libpath {
    my $self = shift;
    return join ' ', map { "-L$_" } @{$self->{LIBPATH}};
}

sub program {
    my ($self, $bin, $srcs, %specific_opts) = @_;
    my $clone = $self->clone()->append(%specific_opts);

    my $target = "$bin" . $clone->{PROGSUFFIX};
    push @Module::Install::ForC::targets, $target;
    push @Module::Install::ForC::TESTS, $target if $target =~ m{^t/};

    my @objects = $clone->_objects($srcs);

    my $ld = $clone->_ld(@$srcs);

    $self->_push_postamble(<<"...");
$target: @objects
	$ld $clone->{LDFLAGS} -o $target @objects @{[ $clone->_libpath ]} @{[ $clone->_libs ]}

...

    $clone->_compile_objects($srcs, \@objects, '');
}

sub _is_cpp {
    my ($self, $src) = @_;
    my $pattern = join('|', map { quotemeta($_) } @{$self->{CXXFILESUFFIX}});
    $src =~ qr/$pattern$/ ? 1 : 0;
}

sub _push_postamble {
    $Module::Install::ForC::postamble .= $_[1];
}

sub _cpppath {
    my $self = shift;
    join ' ', map { "-I $_" } @{ $self->{CPPPATH} };
}

sub _compile_objects {
    my ($self, $srcs, $objects, $opt) = @_;
    $opt ||= '';

    for my $i (0..@$srcs-1) {
        next if $Module::Install::ForC::OBJECTS{$objects->[$i]}++ != 0;
        my $compiler = $self->_is_cpp($srcs->[$i]) ? $self->{CXX} : $self->{CC};
        $self->_push_postamble(<<"...");
$objects->[$i]: $srcs->[$i] Makefile
	$compiler $opt @{ $self->{CCFLAGS} } @{[ $self->_cpppath ]} -c -o $objects->[$i] $srcs->[$i]

...
    }
}

sub _ld {
    my ($self, @srcs) = @_;
    (scalar(grep { $self->_is_cpp($_) } @srcs) > 0) ? $self->{CXX} : $self->{LD};
}

sub shared_library {
    my ($self, $lib, $srcs, %specific_opts) = @_;
    my $clone = $self->clone->append(%specific_opts);

    my $target = "$clone->{SHLIBPREFIX}$lib$clone->{SHLIBSUFFIX}";

    push @Module::Install::ForC::targets, $target;

    my @objects = $clone->_objects($srcs);

    my $ld = $clone->_ld(@$srcs);
    $self->_push_postamble(<<"...");
$target: @objects Makefile
	$ld @{ $clone->{LDMODULEFLAGS} } @{[ $clone->_libpath ]} @{[ $clone->_libs ]} $clone->{LDFLAGS} -o $target @objects

...
    $clone->_compile_objects($srcs, \@objects, @{$self->{CCCDLFLAGS}});
}

sub static_library {
    my ($self, $lib, $srcs, %specific_opts) = @_;
    my $clone = $self->clone->append(%specific_opts);

    my $target = "$clone->{LIBPREFIX}$lib$clone->{LIBSUFFIX}";

    push @Module::Install::ForC::targets, $target;

    my @objects = $clone->_objects($srcs);

    $self->_push_postamble(<<"...");
$target: @objects Makefile
	$clone->{AR} rc $target @objects
	$clone->{RANLIB} $target

...
    $clone->_compile_objects($srcs, \@objects, @{$self->{CCCDLFLAGS}});
}

1;
__END__

=head1 NAME

Module::Install::ForC::Env - build environment object for M::I::ForC

=head1 DESCRIPTION

This class expression the build environments.

=head1 METHODS

=over 4 

=item M::I::ForC::Env->new(%env)

This method create the new instance of M::I::ForC::Env.
%env can take a generic variables.

The default value is following:

        CC       => $Config{cc},
        LD       => $Config{ld},
        LDFLAGS  => $Config{ldflags},
        CCFLAGS  => $Config{ccflags},
        LIBS     => [],

You can use env() for shortcut, see L<Module::Install::ForC>.

=item $env->clone()

clone the instance.

=item $env->append($key, $val)

append the data for $env.

=item $env->program($binary, \@src, %opts)

make executable program named $binary from \@src.

You can specify the environment variables for each program.

    $env->program('foo', ['foo.c'], LIBS => ['pthread']);

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
