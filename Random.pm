package File::Random;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	random_file
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.01';


sub random_file {
	opendir DIR, "." or die "Can't open directory: .";
	my @files = grep {-f} (readdir DIR);
	closedir DIR;
	
	return undef unless @files;
	return $files[rand @files];
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

File::Random - Perl module for random selecting of a file

=head1 SYNOPSIS

  use File::Random qw/random_file/;
 
  my $fname = random_file();

=head1 DESCRIPTION

This module simplifies the routine job of selecting a random file.
(As you can find at CGI scripts).

It's done, because it's boring, always to write something like

  my @files = (<*.*>);
  my $randf = $files[rand @files];
  
or 

  opendir DIR, " ... " or die " ... ";
  my @files = grep {-f ...} (readdir DIR);
  closedir DIR;
  my $randf = $files[rand @files];
 
  
=head2 FUNCTIONS

=over

=item random_file

Returns a randomly selected file(name) from the current directory.
If the directory is empty, undef will be returned.

=back

=head2 EXPORT

None by default.

=head1 TODO

In this version, there's only a random file from the actual directory returned.
I also want to make it possible to write:
  
  my $fname = random_file( -dir => '...', -recursive => 1, -check     => qr/\.html/ );

or even:

  my $fname = random_file( -dir => [$dir1, $dir2, $dir3, ...], -r => 1, -check => sub {-M < 7} );

I also want to add a method C<content_of_random_file> and C<random_line>.

The next thing I'll do is to give the user the possibility of specifying the directory.					 

Just have a look some hours later.

=head1 AUTHOR

Janek Schleicher, E<lt>bigj@kamelfreund.deE<gt>

=head1 SEE ALSO

L<Tie::Pick> 
L<Tie::Select>.

=cut
