package File::Random;

use 5.006;
use strict;
use warnings;

use File::Find;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	random_file
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.04';


sub random_file {
	my @params = my ($dir, $check, $recursive) = _params_random_file(@_);
	
	return $recursive ? _random_file_recursive    (@params)
	                  : _random_file_non_recursive(@params);
}

sub _random_file_non_recursive {
	my ($dir, $check) = @_;

	opendir DIR, $dir or die "Can't open directory '$dir'";
	my @files = grep {-f "$dir/$_" and _valid_file($check, $_)} (readdir DIR);
	closedir DIR;

	return undef unless @files;
	return $files[rand @files];
}

sub _random_file_recursive {
	my ($dir, $check) = @_;

	my $i = 1;
	my $fname;

	my $accept_routine = sub {
		return unless -f; 
		return unless _valid_file($check,$_);
		$fname = $_ if rand($i++) < 1;	# Algorithm from Cookbook, chapter 8.6
	};
	find($accept_routine, $dir);
	
	return $fname;
}

sub _valid_file {
	my ($check, $name) = @_; 
	for (ref($check)) {
		    /Regexp/ && return $name =~ /$check/
		or  /CODE/   && ($_ = $name, return $check->($name));
	}
}

sub _params_random_file {
	my %args  = @_;
	
	for ('-dir', '-check') {
		exists $args{$_} and ! $args{$_} and 
		die "Parameter $_ is declared with a false value";
	}
	
	my $dir   = $args{-dir}   || '.';    
	my $check = $args{-check} || sub {"always O.K."};
	my $recursive = $args{-recursive};   # defaults to undef, already default

	$dir =~ s:[/\\]+$::;                 # /home/xyz != /home/xyz/
	
	unless ((scalar ref $check) =~ /^(Regexp|CODE)$/) {
		die "-check Parameter has to be either a Regexp or a sub routine,".
		    "not a '" . ref($check) . "'";
	}
		
	return ($dir, $check, $recursive);
}

1;
__END__

=head1 NAME

File::Random - Perl module for random selecting of a file

=head1 SYNOPSIS

  use File::Random qw/random_file/;
 
  my $fname  = random_file();

  my $fname2 = random_file(-dir => $dir);
  
  my $random_gif = random_file(-dir       => $dir,
                               -check     => qr/\.gif$/,
							   -recursive => 1);
							   
  my $no_exe     = random_file(-dir   => $dir,
                               -check => sub {! -x});

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
 
It also becomes very boring and very dangerous to write 
randomly selection for subdirectory searching with special check-routines.
  
=head2 FUNCTION random_file

Returns a randomly selected file(name) from the specified directory
If the directory is empty, undef will be returned. There 3 options:

  my $file = random_file(
     -dir         => $dir, 
	 -check       => qr/.../, # or sub { .... }
	 -recursive   => 1        # or 0
  );

=over

=item -dir

Specifies the directory where file has to come from.

Is the -dir option missing,
a random file from the current directory will be used.
That means '.' is the default for the -dir option.

=item -check

With the -check option you can either define
a regex every filename has to follow,
or a sub routine which gets the filename as argument.

Note, that -check doesn't accept anything else
than a regexp or a subroutine.
A string like '/.../' won't work.
I still work on that.

The default is no checking (undef).

=item -recursive

Enables, that subdirectories are scanned for files, too.
Every file, independent from its position in the file tree,
has the same chance to be choosen.

Every true value sets recursive behaviour on,
every false value switches off.
The default if false (undef).

Note, that I programmed the recursive routine very defendly
(using File::Find).
So switch recursive on slowers the program a bit :-)

=back

=head2 EXPORT

None by default.

You can export the function random_file with
C<use File::Random qw/random_file/;> or with the more simple
C<use File::Random qw/:all/;>.

=head1 TODO

I think, I'll need to expand the options.
Instead of only one directory,
it should be possible to take a random file from some directories.

The -check option doesn't except a string looking like regexp.
In future versions there should be the possibility of passing a string
like '/..../' instead of the regexp qr/.../';

To create some aliases for the params is a good idea, too.
I thought to make -d == -dir, -r == -recursive and -c == -check.
(Only a lazy programmer is a good programmer).

So I want to make it possible to write:
  
  my $fname = random_file( -dir => '...', -recursive => 1, -check     => '/\.html/' );

or even:

  my $fname = random_file( -d => [$dir1, $dir2, $dir3, ...], -r => 1, -c => sub {-M < 7} );

I also want to add a method C<content_of_random_file> and C<random_line>.

The next thing, I'll implement is the content_of_random_file method.

Just have a look some hours later.

=head1 BUGS

Oh, I hope none. I still have more test lines than function code.

Well, but because I want some random data, it's a little bit hard to test.
So a test could be wrong, allthough everything is O.K..
To avoid it, I let many tests run,
so that the chances for misproofing should be < 0.0000000001% or so.
Even it has the disadvantage that the tests need really long :-(

=head1 COPYRIGHT

This Program is free software.
You can change or redistribute it under the same condition as Perl itself.

Copyright (c) 2002, Janek Schleicher, E<lt>bigj@kamelfreund.deE<gt>

=head1 AUTHOR

Janek Schleicher, E<lt>bigj@kamelfreund.deE<gt>

=head1 SEE ALSO

L<Tie::Pick> 
L<Tie::Select>
L<Data::Random>

=cut
