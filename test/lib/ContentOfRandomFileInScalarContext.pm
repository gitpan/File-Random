package ContentOfRandomFileInScalarContext;
use base qw/RandomFileMethodBase/;
use TestConstants;

use Test::More;

use File::Random;

sub random_file {
	my ($self, @args) = @_;
	my $content = scalar File::Random::content_of_random_file(@args);
	$content =~ s/\s*$//s;    # ignore whitespaces at the end of the files
	return $content;
}

sub content_of_random_file_in_scalar_context : Test(2) {
	my $self = shift;
	my @arg  = (-check => sub { ! /CVS/ });   # Ignore files in CVS directories
	$self->expected_files_found_ok( [SIMPLE_CONTENTS()],
	                                [@arg, -dir => SIMPLE_DIR],
									"Simple Contents in scalar context" );
	$self->expected_files_found_ok( [REC_CONTENTS()],
	                                [@arg, -dir => REC_DIR, -recursive => 1],
									"Recursive Contents in scalar context" );
}

1;
