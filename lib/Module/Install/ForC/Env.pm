package Module::Install::ForC::Env;
use strict;
use warnings;
use Storable ();
use Config;

sub new {
    my $class = shift;
    my $opt = {
        CC       => $Config{cc},
        LD       => $Config{ld},
        LDFLAGS  => $Config{ldflags},
        OPTIMIZE => $Config{optimize},
        CCFLAGS  => $Config{ccflags},
        LIBS     => [],
        @_
    };
    $opt->{CPPPATH} = [$opt->{CPPPATH}] unless ref $opt->{CPPPATH};
    bless $opt, $class;
}

sub clone {
    my $self = shift;
    return Storable::dclone($self);
}

sub append {
    my ($self, $key, $val) = @_;

    if ((ref($self->{$key})||'') eq 'ARRAY') {
        push @{ $self->{$key} }, @{$val};
    } else {
        $self->{$key} = $val;
    }
}

sub program {
    my ($self, $bin, $srcs, %specific_opts) = @_;
    my %opts = do {
        my $clone = $self->clone;
        while (my ($key, $val) = each %specific_opts) {
            $clone->append($key => $val);
        }
        %$clone;
    };

    push @Module::Install::ForC::targets, $bin;

    my @objects = map { my $x = $_; $x =~ s/\.c$/\.o/; $x } @$srcs;
    my @libs = map { "-l$_" } @{$opts{LIBS}};

    $Module::Install::ForC::postamble .= <<"...";
$bin: @objects
	$opts{LD} @libs $opts{LDFLAGS} -o $bin @objects

...

    my @cppopts = map { "-I $_" } @{ $opts{CPPPATH} };
    for my $i (0..@$srcs-1) {
        next if $Module::Install::ForC::OBJECTS{$objects[$i]}++ != 0;
        $Module::Install::ForC::postamble .= <<"...";
$objects[$i]: $srcs->[$i]
	$opts{CC} $opts{CCFLAGS} @cppopts -c -o $objects[$i] $srcs->[$i]
...
    }
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
%env can take a generic vars.

The default value is following:

        CC       => $Config{cc},
        LD       => $Config{ld},
        LDFLAGS  => $Config{ldflags},
        OPTIMIZE => $Config{optimize},
        CCFLAGS  => $Config{ccflags},
        LIBS     => [],

You can use env() for shortcut, see L<Module::Install::ForC>.

=item $env->clone()

clone the instnace.

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
