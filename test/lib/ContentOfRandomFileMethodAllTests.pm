package ContentOfRandomFileMethodAllTests;
use base qw/RandomFileMethodAllTests/;

use strict;
use warnings;

use File::Random;

# Replace random_file with calling content_of_random_file
# Analyze the content and return the file name because of the analysis
sub random_file {
	my ($self, %args) = @_;
	my @content;
	my $current_fname = undef;    # Have to know the filename on unknown files
	if (exists($args{-check}) and (ref($args{-check}) !~ /CODE|Regexp/)) {
		# Could be a test that shall fail
		@content = File::Random::content_of_random_file(%args);
	} else {
		my $old_check = $args{-check} || sub {1};
		my $new_check = sub { return 0 if /CVS/;  # no CVS subdirectories
							  return (ref($old_check) eq "Regexp")
							  	? /$old_check/ 
								: $old_check->(@_) 
							};
		@content = 
			File::Random::content_of_random_file(%args, -check => $new_check);
	}
	if ($_ = $content[0]) {
		/^Content: (.*)$/ && return $1;
	}
	if ($_ = $content[3]) {
		chomp;
		/^(\w\.dat)$/ && return $1;
	}
	return $current_fname;
}

1;
