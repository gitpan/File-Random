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
    random_line
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.12';

sub _standard_dir($);
sub _dir(%);

sub random_file {
	my @params = my ($dir, $check, $recursive) = _params_random_file(@_);
	
	return $recursive ? _random_file_recursive    (@params)
	                  : _random_file_non_recursive(@params);
}

sub content_of_random_file {
	my %args = @_;
	my $rf = random_file(%args) or return undef;
	my $dir = _standard_dir _dir %args;
	
	open RANDOM_FILE, "<", "$dir/$rf" 
		or die "Can't open the randomly selected file '$dir/$rf'";
	my @content = (<RANDOM_FILE>);
	close RANDOM_FILE;
	return wantarray ? @content : join "", @content;
}

sub random_line {
    my ($fname) = @_;
    defined $fname or die "Need a defined filename to read a random line";
	# Algorithm from Cookbook, chapter 8.6
    my $line = undef;
    open FILE, '<', $fname or die "Can't open '$fname' to read random_line";
    rand($.) < 1 && ($line = $_) while (<FILE>);
    close FILE;
    return $line;
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

sub _dir (%) {
    my %args = @_;
    return $args{-d} || $args{-dir} || $args{-directory};
}

sub _params_random_file {
	my %args  = @_;
	
	for (qw/-d -dir -directory -c -check/) {
		exists $args{$_} and ! $args{$_} and 
		die "Parameter $_ is declared with a false value";
	}
    
    foreach (keys %args) {
        /^\-(d|dir|directory|
             c|check|
             r|rec|recursive)$/x or warn "Unknown option '$_'";
    }
    
	my $dir   = _standard_dir _dir %args;    
	my $check = $args{-c} || $args{-check} || sub {"always O.K."};
	my $recursive = $args{-r} || $args{-rec} || $args{-recursive};

	unless (!defined($check) or (scalar ref($check) =~ /^(Regexp|CODE)$/)) {
		die "-check Parameter has to be either a Regexp or a sub routine,".
		    "not a '" . ref($check) . "'";
	}
		
	return ($dir, $check, $recursive);
}

sub _standard_dir($) {    
	my $dir = shift() || '.';
	$dir =~ s:[/\\]+$::;
	return $dir;
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
  
  my $word_of_the_day = random_line('/usr/share/dict/words');

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

The simple standard job of selecting a random line from a file is implemented, too.
  
=head2 FUNCTION random_file

Returns a randomly selected file(name) from the specified directory
If the directory is empty, undef will be returned. There 3 options:

  my $file = random_file(
     -dir         => $dir, 
	 -check       => qr/.../, # or sub { .... }
	 -recursive   => 1        # or 0
  );

=over

=item -dir (-d or -directory)

Specifies the directory where file has to come from.

Is the -dir option missing,
a random file from the current directory will be used.
That means '.' is the default for the -dir option.

=item -check (-c)

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

=item -recursive (-r or -rec)

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

=item unknown options

Gives a warning.
Unknown options are ignored.
Note, that upper/lower case makes a difference.
(Maybe, once a day I'll change it)

=head2 FUNCTION content_of_random_file

Returns the content of a randomly selected random file.
In list context it returns an array of the lines of the selected file,
in scalar context it returns a multiline string with whole the file.
The lines aren't chomped.

This function has the same parameter and a similar behaviour to the
random_file method. 
Note, that -check still gets the filename and not the filecontent.

=head2 FUNCTION random_line($filename)

Returns a random_line from a (existing) file.

If the file is empty, undef is returned.

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

=head1 DEPENDENCIES

This module requires these other modules and libraries:

  Test::More
  Test::Exception
  Test::Class
  Set::Scalar
  File::Temp
  
Test::Class itselfs needs the following additional modules:
  Attribute::Handlers             
  Class::ISA                      
  IO::File                        
  Storable
  Test::Builder
  Test::Builder::Tester
  Test::Differences    

All these modules are needed only for the tests.
You can work with the module even without them. 
These modules are only needed for my test routines,
not by the File::Random itself.
(However, it's a good idea most to install most of the modules anyway).


=head1 TODO

The -check option doesn't except a string looking like a regexp.
In future versions there should be the possibility of passing a string
like '/..../' instead of the regexp qr/.../';

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