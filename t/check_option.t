#!/usr/bin/perl -w

use strict;

use Test::More       tests => 10;
use Test::Exception;

use File::Random     qw/:all/;
use Set::Scalar;
use Data::Dumper;

use constant TESTDIR       => "t/dir";

use constant FILES_FOR_RE  => (qr/\d$/ => [qw/file1 file2 file3 file4 file5/],
		                       qr/\./  => [qw/x.dat y.dat z.dat/]);

use constant TEST_RUNS     => 500;	# should be enough to find the files

use constant WRONG_PARAMS  => (undef, '', '/./', {}, [], 0);

CHECK_STANDARD: {
	my %files = FILES_FOR_RE;
	foreach my $re (keys %files) {
		my $realre = qr/$re/;   # ugly, but $re only looks like a string :-( (asking ref)
		my $exp_files = Set::Scalar->new( @{$files{$re}} );
		my $rfiles_re  = Set::Scalar->new();
		my $rfiles_sub = Set::Scalar->new();
		for (1 .. TEST_RUNS) {
			$rfiles_re ->insert( random_file(-dir => TESTDIR, 
			                                 -check => $realre) );
			$rfiles_sub->insert( random_file(-dir => TESTDIR, 
			                                 -check => sub { /$realre/ }) );
		}
		ok $exp_files->is_equal($rfiles_re)
		or diag "$re should force to find the right files, but doesn't:",
		        "expected: $exp_files, found: $rfiles_re";
		ok $exp_files->is_equal($rfiles_sub)
		or diag "sub{ $re } should force to find the right files, but doesn't:",
		        "expected: $exp_files, found: $rfiles_sub";
	}
}

WRONG_PARAMETERS: {
	foreach (WRONG_PARAMS) {
		dies_ok sub {random_file(-dir => TESTDIR, -check => $_)}
	    or diag "-check has wrong Parameter '" . Dumper($_) .
		        "', but random_file didn't die";
	}	
}

1;
