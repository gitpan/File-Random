#!/usr/bin/perl -w

use strict;

use Test::More   tests => 4;
use File::Random qw/random_file/;

use constant TESTDIR => "t/dir/";

our @all_files;

SETUP: {
	opendir DIR, TESTDIR or die "Can't open Test directory: $!";
	@all_files = grep {-f TESTDIR . $_} (readdir DIR);
	closedir DIR;

	chdir TESTDIR;
}

NO_UNKNOWN_FILE_IS_SELECTED: {
	my %known = map {$_ => 1} @all_files;
	foreach (sample()) {
		$known{$_} or fail(),
		              diag("random_file() -> $_ isn't a file in the directory"),
					  last NO_UNKNOWN_FILE_IS_SELECTED;
	}
	pass("all files from random_file() are in the directory");
}

ALL_FILES_ARE_RANDOMIZED_SELECTED_ANYWHEN: {
	my %choosen = map {$_ => 0} @all_files;
	$choosen{$_}++ foreach sample();
	
	my @untouched_files = grep {! $choosen{$_}} keys %choosen;
	ok (0 == @untouched_files, 
	    "random_file() returns every file anywhen")
	or diag("These files wasn't selected: @untouched_files");
}

RANDOM_FILES_ARE_DIFFERENT: {
	my @s1 = sample();
	my @s2 = sample();
	my @differences = grep {$s1[$_] ne $s2[$_]} (0 .. $#s1);
	ok @differences, "Two samples must be different";
}

EMPTY_FOLDER: {
	chdir "empty";
	ok ! defined random_file(), "Empty folder returns an undef value";
}

sub sample {
	my @sample = ();
	push @sample, random_file() for (1 .. 3 * (scalar @all_files) ** 2);
	return @sample;
}


1;
