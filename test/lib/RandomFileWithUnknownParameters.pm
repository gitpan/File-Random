package RandomFileWithUnknownParameters;
use base qw/RandomFileMethodBase/;
use TestConstants;

use strict;
use warnings;

use Test::More;

use constant UNKNOWN_PARAMS => (-verzeichnis => SIMPLE_DIR,
                                -ueberpruefe => qr/deutsch/,
                                -DIR         => SIMPLE_DIR,
                                dir          => SIMPLE_DIR,
                                -Check       => sub {1},
                                check        => sub {1},
                                -RECURSIVE   => 1,
                                recursive    => 1);
                                
sub warning_when_unknown_param : Test(8) {
    my $self = shift;
    my %params = UNKNOWN_PARAMS;
    while (my @args = each %params) {
        warns_ok( sub {$self->random_file(@args)}, "Arguments: @args");
    }
}

sub warns_ok {
    my ($sub, $testname) = @_;
    my $has_warned = 0;
    local $SIG{__WARN__} = sub {$has_warned = 1};
    $sub->();
    ok $has_warned, "Expected warning failed: $testname";
}

1;
