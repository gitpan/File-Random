package ContentOfRandomFileMethodAllTests;
use base qw/RandomFileMethodAllTests/;

use File::Random;

sub random_file {
	my ($self, @args) = @_;
	my @content = File::Random::content_of_random_file(@args);
	$content[0] =~ /Content: (.*)$/ && return $1;
	chomp $content[3];
	$content[3] =~ /\w.dat/ && return $content[3];
	return undef;
}

1;
