package File::Random;

use 5.006;
use strict;
use warnings;

use File::Find;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	random_file
	content_of_random_file
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.07';


sub random_file {
	my @params = my ($dir, $check, $recursive) = _params_random_file(@_);
	
	return $recursive ? _random_file_recursive    (@params)
	                  : _random_file_non_recursive(@params);
}

sub content_of_random_file {
	my %arg = @_;
	my $rf = random_file(%arg) or return undef;
	(my $dir = $arg{-dir} || '.') =~ s:[/\\]*$::;
	
	open RANDOM_FILE, "<", "$dir/$rf" 
		or die "Can't open the randomly selected file $rf";
	my @content = (<RANDOM_FILE>);
	close RANDOM_FILE;
	return wantarray ? @content : join "", @content;
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
		
		# Calculate filename with relative path
		my ($f) = $File::Find::name =~ m:^$dir[/\\]*(.*)$:;
		return unless _valid_file($check,$f);
		# Algorithm from Cookbook, chapter 8.6
		# similar to selecting a random line from a file
		if (rand($i++) < 1) {
			$fname = $f;
		}
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
	
	unless (!defined($check) or (scalar ref($check) =~ /^(Regexp|CODE)$/)) {
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
							   
  my @jokes_of_the_day = content_of_random_file(-dir => '/usr/lib/jokes');
  my $joke_of_the_day  = content_of_random_file(-dir => '/usr/lib/jokes');

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
The filename includes the relative path 
(from the -dir directory or the current directory).

Note, that -check doesn't accept anything else
than a regexp or a subroutine.
A string like '/.../' won't work.
I still work on that.

The default is no checking (undef).

=item -recursive

Enables, that subdirectories are scanned for files, too.
Every file, independent from its position in the file tree,
has the same chance to be choosen.
Now the relative path from the given subdirectory or the current directory
of the randomly choosen file is included to the file name.

Every true value sets recursive behaviour on,
every false value switches off.
The default if false (undef).

Note, that I programmed the recursive routine very defendly
(using File::Find).
So switching -recursive on, slowers the program a bit :-)

=head2 FUNCTION content_of_random_file

Returns the content of a randomly selected random file.
In list context it returns an array of the lines of the selected file,
in scalar context it returns a multiline string with whole the file.
The lines aren't chomped.

This function has the same parameter and a similar behaviour to the
random_file method. 
Note, that -check still gets the filename and not the filecontent.

=back

=head2 EXPORT

None by default.

You can export the function random_file with
C<use File::Random qw/random_file/;>,
C<use File::Random qw/content_of_random_file/> or with the more simple
C<use File::Random qw/:all/;>.

I didn't want to pollute namespaces as I could imagine,
users write methods random_file to create a file with random content.
If you think I'm paranoid, please tell me,
then I'll take it into the export.

=head1 TODO

I think, I'll need to expand the options.
Instead of only one directory,
it should be possible to take a random file from some directories.

The -check option doesn't except a string looking like a regexp.
In future versions there should be the possibility of passing a string
like '/..../' instead of the regexp qr/.../';

To create some aliases for the params is a good idea, too.
I thought to make -d == -dir, -r == -recursive and -c == -check.
(Only a lazy programmer is a good programmer).

So I want to make it possible to write:
  
  my $fname = random_file( -dir => '...', -recursive => 1, -check     => '/\.html/' );

or even:

  my $fname = random_file( -d => [$dir1, $dir2, $dir3, ...], -r => 1, -c => sub {-M < 7} );

A C<-firstline> or C<-lines => [1 .. 10]> option for the
C<content_of_random_file> could be useful. 
Later something like C<-randomline> option should be implemented, too.
(Making the same as C<random_line( random_file( ... ) )>)
C<content_of_random_file> is very long,
perhaps I'll implement a synonym C<corf>.

Also speed could be improved,
as I tried to write the code very readable,
but wasted sometimes a little bit speed.
(E.g. missing -check is translated to something like -check => sub{1})
As Functionality and Readability is more important than speed,
I'll wait a little bit with speeding up :-)

Using unknown params should bring a warning.
At the moment they are ignored.

The next thing, I'll implement is the C<random_line> function.

Please feel free to suggest me anything what could be useful.

=head1 BUGS

Oh, I hope none. I still have more test lines than function code.
However, it's still BETA code.

Well, but because I want some random data, it's a little bit hard to test.
So a test could be wrong, allthough everything is O.K..
To avoid it, I let many tests run,
so that the chances for misproofing should be < 0.0000000001% or so.
Even it has the disadvantage that the tests need really long :-(

I'm not definitly sure whether my test routines runs on OS,
with path seperators different of '/', like in Win with '\\'.
Perhaps anybody can try it and tell me the result.
[But remember Win* is definitly the greater bug.]

=head1 COPYRIGHT

This Program is free software.
You can change or redistribute it under the same condition as Perl itself.

Copyright (c) 2002, Janek Schleicher, E<lt>bigj@kamelfreund.deE<gt>

=head1 AUTHOR

Janek Schleicher, E<lt>bigj@kamelfreund.deE<gt>

=head1 SEE ALSO

L<Tie::Pick> 
L<Data::Random>

=cut
