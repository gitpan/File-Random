#!/usr/bin/perl -w

use strict;
use Test::More qw/no_plan/;
use Data::Dumper;
use Set::Scalar;

use File::Random qw/:all/;

use constant TESTDIR           => 't/dir/rec/';
use constant HOME              => '../../..';

use constant ALL_FILES         => qw(file1 file2 file3
                                     sub1/file4 sub1/file5 sub1/file6
									 sub1/subsub/file7 sub1/subsub/file8
									                   sub1/subsub/file9
									 sub2/file10 sub2/file11 sub2/file12);
use constant ALL_FILES_SET     => Set::Scalar->new(ALL_FILES);

use constant ODD_FILES         => grep {/[13579]$/} ALL_FILES;
use constant ODD_FILES_SET     => Set::Scalar->new(ODD_FILES);

use constant TOP_FILES         => grep {! m:sub:} ALL_FILES;
use constant TOP_FILES_SET     => Set::Scalar->new(TOP_FILES);

use constant TEST_RUNS         => 2 * (ALL_FILES_SET()->size() ** 2);

use constant REC_ON_ARGS       => (1, "on", "true", 9);
use constant REC_OFF_ARGS      => (0, undef, "0", '');

REC_ON_ARGS_TESTS: {
	foreach (REC_ON_ARGS()) {
		test_expected_set_known_params(ALL_FILES_SET, -recursive => $_);
	}
}

REC_IN_CURRENT_DIR: {
	chdir TESTDIR;
	test_expected_set_known_params(ALL_FILES_SET, -dir => '.', -recursive => 1);
	chdir HOME;
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
	__remove_cvs_files( $found ); # use a CVS system at home irritating my tests
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

sub __remove_cvs_files($) {
	my $f = shift;
	foreach ($f->members) {
		$f->delete($_) if /Repository|CVS|Entries/;
	}
}

1;
