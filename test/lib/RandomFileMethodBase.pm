package RandomFileMethodBase;
use base qw/Test::Class/;
use TestConstants;

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Set::Scalar;

use File::Random;

sub expected_files_found_ok {
	my ($self, $exp_files, $args, $testname) = @_;
	my $exp    = Set::Scalar->new(@$exp_files);
	my $found  = Set::Scalar->new( grep defined, $self->sample(@$args) );
	
	__remove_cvs_files( $found );
	ok $exp->is_equal($found), $testname     
	or diag "found: $found", 
	        "expected $exp",
	        "called with " . join (", " => @$args);
}

# I use a CVS System at home,
# so there are always some files more than needed
# that's why I delete them from the found files
sub __remove_cvs_files($) {
	my $f = shift;
	foreach ($f->members) {
		$f->delete($_) if defined($_) && ($_ =~ /Repository|CVS|Entries/);
	}
}

sub sample {
	my ($self, %arg) = @_;
	my @sample;
	push @sample, $self->call_random_file(%arg) for (1 .. SAMPLE_SIZE);
	return @sample;
}

sub random_file {
	my $self = shift;
	return File::Random::random_file(@_);
}

sub call_random_file {
	my ($self, %arg) = @_;
	
	my ($path, $home) = @arg{'-path', '-home'};
	#delete @arg{'-path', '-home'};

	# either we know the directory directly
	return $self->random_file(%arg) if $arg{-dir};

	# or have to go to the path itself
	chdir $path;
	my $rf = $self->random_file(%arg);
	chdir $home;
	return $rf;
}


1;

