package RandomLine;
use base qw/Test::Class/;

use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Temp qw/tempfile/;
use Set::Scalar;

use File::Random qw/random_line/;

use constant LINES => <<'EOF';
Random
Lines
can
contain
randomly
appearing things like
PI = 3.1415926535
EOF

use constant WRONG_PARAMS => (undef, '', '&');

use constant SAMPLE_SIZE => 200;

sub fill_tempfile : Test(setup) {
    my $self = shift;
    (my $normal_fh, $self->{normal_file}) = tempfile();
    (undef,         $self->{empty_file})  = tempfile();
    print $normal_fh LINES;
}

sub clear_tempfile : Test(teardown) {
    my $self = shift;
    close $self->{'normal_file'};
    close $self->{'empty_file'};
}

sub empty_file_returns_undef : Test(1) {
    my $self = shift;
    is random_line($self->{empty_file}), undef, "random_file( Empty file )";
}

sub lines_are_the_expected_ones : Test(1) {
    my $self = shift;
    my $exp = Set::Scalar->new( map {"$_\n"} split /\n/, LINES);
    my $got = Set::Scalar->new();
    $got->insert( random_line($self->{normal_file}) ) for (1 .. SAMPLE_SIZE);
    is $got, $exp, "random_line( Normal File )";
}

sub wrong_parameters : Test(3) {
    no warnings;    # $_ shall be undefined for a moment !
    dies_ok(sub {random_line($_)}, "random_line( '$_' )") for WRONG_PARAMS;
}

1;
