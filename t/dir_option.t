#!/usr/bin/perl

use strict;

use Test::More       tests => 18;
use Test::Exception;
use File::Random     qw/random_file/;

use constant     HOMEDIR             => "../../";
use constant     TESTDIR             => "t/dir/";
use constant	 EMPTY_SUBDIR        => "t/dir/empty/";
use constant     EMPTY_HOMEDIR       => "../../../";

use constant	 TESTARGUMENTS       => ({},
                                         {-dir => "t/dir"},
								         {-dir => "t/dir/"});
								   
use constant 	 EMPTY_TESTARGUMENTS => ({},
                                         {-dir => "t/dir/empty"},
										 {-dir => "t/dir/empty"});

my @all_files;
SETUP: {
	opendir DIR, TESTDIR or die "Can't open Test directory: $!";
	@all_files = grep {-f TESTDIR . $_} (readdir DIR);
	closedir DIR;
}

foreach my $arg (TESTARGUMENTS) {
	
	$arg->{-path} = TESTDIR;
	$arg->{-home} = HOMEDIR;

	NO_UNKNOWN_FILE_IS_SELECTED: {
		my %known = map {$_ => 1} @all_files;
		foreach (sample($arg)) {
			$known{$_} or fail(),
		    	          diag("random_file() -> $_ isn't a file in the directory"),
						  diag("called with ",%$arg),
						  last NO_UNKNOWN_FILE_IS_SELECTED;
		}
		pass("all files from random_file() are in the directory");
	}

	ALL_FILES_ARE_RANDOMIZED_SELECTED_ANYWHEN: {
		my %choosen = map {$_ => 0} @all_files;
		$choosen{$_}++ foreach sample($arg);
	
		my @untouched_files = grep {! $choosen{$_}} keys %choosen;
		ok (0 == @untouched_files, 
	    	"random_file() returns every file anywhen")
		or diag("These files wasn't selected: @untouched_files"),
		   diag("called with @{$arg}");
	}

	RANDOM_FILES_ARE_DIFFERENT: {
		ok ! eq_array( [sample($arg)], [sample($arg)] )
		or diag "Called with @{$arg}";
	}


}

foreach my $arg (EMPTY_TESTARGUMENTS) {
	
	$arg->{-path} = EMPTY_SUBDIR;
	$arg->{-home} = EMPTY_HOMEDIR;

	EMPTY_FOLDER: {
		ok ! defined call_random_file($arg), 
		    "Empty folder returns an undef value"
		or diag "called with @{$arg}";
	}

}

TEST_WRONG_DIR_PARAMETERS: {
	foreach my $false_dir (undef, '', 0, "/foo/bar/nonsens/reallynonsens/", [], {}) {
		dies_ok {random_file(-dir => $false_dir)}, "-dir $false_dir";
	}
}

sub sample($) {
	my $arg = shift;
	my @sample = ();
	for (1 .. 3 * (scalar @all_files) ** 2) {
		push @sample, call_random_file($arg);
	}
	return @sample;
}

sub call_random_file($) {
	my $arg = shift;
	# either we know the directory directly
	return random_file(-dir => $arg->{-dir}) if $arg->{-dir};
	# or have to go to the path itself
	chdir $arg->{-path};
	my $rf = random_file();
	chdir $arg->{-home};
	return $rf;
}


1;
