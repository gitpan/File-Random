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
our $VERSION = '0.02';


sub random_file {
	my %args = (-dir => '.', @_);
	die "Argument to -dir is undefined" unless defined $args{-dir};
	$args{-dir} =~ s:/$::;
	opendir DIR, $args{-dir} or die "Can't open directory '$args{-dir}': .";
	my @files = grep {-f "$args{-dir}/$_"} (readdir DIR);
	closedir DIR;
	
	return undef unless @files;
	return $files[rand @files];
}

1;
__END__
=head1 NAME

File::Random - Perl module for random selecting of a file

=head1 SYNOPSIS

  use File::Random qw/random_file/;
 
  my $fname  = random_file();

  my $fname2 = random_file(-dir => $dir);

=head1 DESCRIPTION

This module simplifies the routine job of selecting a random file.
(As you can find at CGI scripts).

It's done, because it's boring (and errorprone), always to write something like

  my @files = (<*.*>);
  my $randf = $files[rand @files];
  
or 

  opendir DIR, " ... " or die " ... ";
  my @files = grep {-f ...} (readdir DIR);
  closedir DIR;
  my $randf = $files[rand @files];
 
  
=head2 FUNCTIONS

=over

=item random_file(-dir => $dir)

Returns a randomly selected file(name) from the specified directory
If the directory is empty, undef will be returned.

Is the -dir option missing,
a random file from the current directory will be used.
That means '.' is the default for the -dir option.

=back

=head2 EXPORT

None by default.

You can export the function random_file with
C<use File::Random qw/random_file/;> or with the more simple
C<use File::Random qw/:all/;>.

=head1 TODO

I think, I'll need some more options.
Instead of only one directory,
it should be possible to take a random file from some directories.
Even a recursive "search" should be included.

More important will be the -check option,
so you can define what regexp or subroutine should be valid,
for files randomly choosen.

So I want to make it possible to write:
  
  my $fname = random_file( -dir => '...', -recursive => 1, -check     => qr/\.html/ );

or even:

  my $fname = random_file( -dir => [$dir1, $dir2, $dir3, ...], -r => 1, -check => sub {-M < 7} );

I also want to add a method C<content_of_random_file> and C<random_line>.

The next thing, I'll implement is the -check option.

Just have a look some hours later.

=head1 COPYRIGHT

File::Random is free software.
You can change or redistribute it under the same condition as Perl itself.

(c) 2002, Janek Schleicher

=head1 AUTHOR

Janek Schleicher, E<lt>bigj@kamelfreund.deE<gt>

=head1 SEE ALSO

L<Tie::Pick> 
L<Tie::Select>
L<Data::Random>

=cut
