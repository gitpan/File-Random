#!/usr/bin/perl -w

use strict;
use Test::More qw/no_plan/;
use Data::Dumper;
use Set::Scalar;

use File::Random qw/:all/;

use constant TESTDIR           => 't/dir/rec';

use constant FILES_NR_TOP      => (1 ..  3);
use constant FILES_NR_TOTAL    => (1 .. 12);

use constant TOP_FILES         => map {"file$_"} FILES_NR_TOP;
use constant TOP_FILES_SET     => Set::Scalar->new(TOP_FILES);

use constant ODD_FILES         => map {"file$_"} grep {$_ % 2} FILES_NR_TOTAL;
use constant ODD_FILES_SET     => Set::Scalar->new(ODD_FILES);

use constant ALL_FILES         => map {"file$_"} FILES_NR_TOTAL;
use constant ALL_FILES_SET     => Set::Scalar->new(ALL_FILES);

use constant TEST_RUNS         => 3 * (FILES_NR_TOTAL ** 2);

use constant REC_ON_ARGS       => (1, "on", "true", 9);
use constant REC_OFF_ARGS      => (0, undef, "0", '');

REC_ON_ARGS_TESTS: {
	foreach (REC_ON_ARGS()) {
		test_expected_set_known_params(ALL_FILES_SET, -recursive => $_);
	}
}

ODD_FILES_TESTS: {
	test_expected_set_known_params(ODD_FILES_SET, -recursive => 1,
	                                              -check     => qr/[13579]$/);
}

REC_OFF_ARGS_TEST_TEST: {
	foreach (REC_OFF_ARGS) {
		test_expected_set_known_params(TOP_FILES_SET, -recursive => $_);
	}
}

sub test_expected_set_known_params {
	my ($expected_set, @params) = @_;
	my $found = random_files_set(@params);
	$found->delete(qw/Entries Repository Root/);  # use a CVS system at home :-)
	ok $expected_set->is_equal($found)
	or diag "random_file(" . Dumper(@params) .")",
	        "expected: $expected_set",
			"found: $found";
}

sub random_files_set {
	my @args = (-dir => TESTDIR, @_);
	my $found = Set::Scalar->new();
	$found->insert(random_file(@args)) for (1 .. TEST_RUNS);
	return $found;
}

1;
