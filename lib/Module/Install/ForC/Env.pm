package Module::Install::ForC::Env;
use strict;
use warnings;
use Storable ();
use Config;

sub new {
    my $class = shift;
    my $opt = {
        CC        => $Config{cc},
        LD        => $Config{ld},
        LDFLAGS   => $Config{ldflags},
        OPTIMIZE  => $Config{optimize},
        CCFLAGS   => $Config{ccflags},
        LDDLFLAGS => $Config{lddlflags},
        CPPPATH   => [],
        LIBS      => [],
        LIBPATH   => [],
        CCCDLFLAGS => $Config{cccdlflags},
        LIBPREFIX  => ( $^O eq 'Win32' ? '' : 'lib'),
        SHLIBPREFIX  => ( $^O eq 'Win32' ? '' : 'lib'),
        @_
    };
    $opt->{CPPPATH} = [$opt->{CPPPATH}] unless ref $opt->{CPPPATH};
    bless $opt, $class;
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
    my $srcs = shift;
    map { my $x = $_; $x =~ s/\.c$/$Config{obj_ext}/; $x } @$srcs;
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
    my $cloned = $self->clone()->append(%specific_opts);

    push @Module::Install::ForC::targets, $bin;

    my @objects = _objects($srcs);

    $Module::Install::ForC::postamble .= <<"...";
$bin: @objects
	$cloned->{LD} @{[ $cloned->_libpath ]} @{[ $cloned->_libs ]} $cloned->{LDFLAGS} -o $bin @objects

...

    $cloned->_compile_objects($srcs, \@objects, '');
}

sub _compile_objects {
    my ($self, $srcs, $objects, $opt) = @_;
    my @cppopts = map { "-I $_" } @{ $self->{CPPPATH} };
    for my $i (0..@$srcs-1) {
        next if $Module::Install::ForC::OBJECTS{$objects->[$i]}++ != 0;
        $Module::Install::ForC::postamble .= <<"...";
$objects->[$i]: $srcs->[$i] Makefile
	$self->{CC} $opt $self->{CCFLAGS} @cppopts -c -o $objects->[$i] $srcs->[$i]

...
    }
}

sub shared_library {
    my ($self, $lib, $srcs, %specific_opts) = @_;
    my $clone = $self->clone->append(%specific_opts);

    my $target = "$clone->{SHLIBPREFIX}$lib.$Config{dlext}";

    push @Module::Install::ForC::targets, $target;

    my @objects = _objects($srcs);

    $Module::Install::ForC::postamble .= <<"...";
$target: @objects Makefile
	$clone->{LD} $clone->{LDDLFLAGS} @{[ $clone->_libpath ]} @{[ $clone->_libs ]} $clone->{LDFLAGS} -o $target @objects

...
    $clone->_compile_objects($srcs, \@objects, $self->{CCCDLFLAGS});
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
        OPTIMIZE => $Config{optimize},
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
