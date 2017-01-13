#!/usr/bin/perl
eval "use diagnostics; 1"  or die("\n[ FATAL ] Could not load the Diagnostics module.\n\nTry:\n\n      sudo apt-get install perl-modules\n\nThen try running this script again.\n\n");
use Getopt::Long qw(:config no_ignore_case bundling pass_through);
use POSIX;
use strict;
use warnings;
use File::Find;
use HTTP::Tiny;

our $VERBOSE = "";
our $NOCOLOR = 0;
our $LIGHTBG = 0;
our $BBCODE = 0;
my $help = "";

sub usage {
	our $usage_output = <<'END_USAGE';
Usage: wpscan.pl [space delimited list of directories] [OPTIONS]
If no options are specified, the basic tests will be run.
	-h, --help		Print this help message
	-L, --light-term	Show colours for a light background terminal.
	-n, --nocolor		Use default terminal color, dont try to be all fancy! 
	-v, --verbose		Use verbose output (display list of wordpress versions found and where, and what version)

END_USAGE
	print $usage_output;
}

our $RED;
our $GREEN;
our $YELLOW;
our $BLUE;
our $PURPLE;
our $CYAN;
our $ENDC = "\033[0m"; # reset the terminal color
our $BOLD;
our $ENDBOLD; # This is for the BBCODE [/b] tag
our $UNDERLINE;
our $ENDUNDERLINE; # This is for BBCODE [/u] tag

our $STARTDIR;


GetOptions(
	'help|h' => \$help,
	'bbcode|b' => \$BBCODE,
	'light-term|L' => \$LIGHTBG,
	'nocolor|n' => \$main::NOCOLOR,
	'verbose|v' => \$VERBOSE
);


if ($help) {
	usage();
	exit;
}

if ($NOCOLOR) {
	$RED = ""; # SUPPRESS COLORS
	$GREEN = ""; # SUPPRESS COLORS
	$YELLOW = ""; # SUPPRESS COLORS
	$BLUE = ""; # SUPPRESS COLORS
	$PURPLE = ""; # SUPPRESS COLORS
	$CYAN = ""; # SUPPRESS COLORS
	$ENDC = ""; # SUPPRESS COLORS
	$BOLD = ""; # SUPPRESS COLORS
	$ENDBOLD = ""; # SUPPRESS COLORS
	$UNDERLINE = ""; # SUPPRESS COLORS
	$ENDUNDERLINE = ""; # SUPPRESS COLORS
} elsif ($LIGHTBG) {
	$RED = "\033[1m"; # bold all the things!
	$GREEN = "\033[1m"; # bold all the things!
	$YELLOW = "\033[1m"; # bold all the things!
	$BLUE = "\033[1m"; # bold all the things!
	$PURPLE = "\033[1m"; # bold all the things!
	$CYAN = "\033[1m";  # bold all the things!
	$BOLD = "\033[1m"; # Default to ANSI codes.     
	$ENDBOLD = ""; # Default to ANSI codes.     
	$UNDERLINE = "\033[4m"; # Default to ANSI codes.     
	$ENDUNDERLINE = ""; # Default to ANSI codes.     
	$ENDC = "\033[0m"; # Default to ANSI codes
} elsif ($BBCODE) {
	$RED = "[color=#FF0000]"; # 
	$GREEN = "[color=#0000FF]"; # Make GREEN appear as BLUE, as green looks horrid on forums, hard to read. 
	$YELLOW = ""; # 
	$BLUE = "[color=#0000FF]"; # 
	$PURPLE = ""; # 
	$CYAN = ""; # 
	$BOLD = "[b]"; # 
	$ENDBOLD = "[/b]"; # 
	$UNDERLINE = "[u]"; # 
	$ENDUNDERLINE = "[/u]"; # 
	$ENDC = "[/color]"; # SUPPRESS COLORS
} else {
	$RED = "\033[91m"; # Default to ANSI codes.
	$GREEN = "\033[92m"; # Default to ANSI codes. 
	$YELLOW = "\033[93m"; # Default to ANSI codes. 
	$BLUE = "\033[94m"; # Default to ANSI codes.  
	$PURPLE = "\033[95m"; # Default to ANSI codes.     
	$CYAN = "\033[96m"; # Default to ANSI codes.     
	$BOLD = "\033[1m"; # Default to ANSI codes.     
	$ENDBOLD = ""; # Default to ANSI codes.     
	$UNDERLINE = "\033[4m"; # Default to ANSI codes.     
	$ENDUNDERLINE = ""; # Default to ANSI codes.     
	$ENDC = "\033[0m"; # Default to ANSI codes
}

sub info_print {
	print "|${BOLD}${BLUE}--${ENDC}${ENDBOLD}| $_[0]\n";
}

sub good_print_item {
	print "|${BOLD}${GREEN}OK${ENDC}${ENDBOLD}|${GREEN}     *  $_[0]${ENDC}\n";
}

sub bad_print {
	print "|${BOLD}${RED}!!${ENDC}${ENDBOLD}|${RED} $_[0]${ENDC}\n";
}

sub bad_print_item {
	print "|${BOLD}${RED}!!${ENDC}${ENDBOLD}|${RED}     *  $_[0]${ENDC}\n";
}

sub info_print_item {
	print "|${BOLD}${BLUE}--${ENDC}${ENDBOLD}|     *  $_[0]\n";
}


sub get_latest_wordpress_version {
	our $url = "https://wordpress.org/latest";
        our $response = `curl -sILk wordpress.org/latest | grep Content-Disposition`;
        our ($wp_latest_version) = $response =~ /(\d+.\d+(.\d+)?)/;
        return $wp_latest_version;
}

sub systemcheck_wordpress_versions {
	my ($STARDIR) = @_;
        info_print("Searching ${BLUE}$STARTDIR${ENDC} for any wordpress installations, please wait...");
	our @wordpress_version_files_list;
	find(sub {push @wordpress_version_files_list, $File::Find::name  if $_ eq "version.php"},  $STARTDIR);
        our $wordpress_installations_count = @wordpress_version_files_list;
        if ($wordpress_installations_count eq 0) {
                info_print("No wordpress installations detected.")
        } else {
                if (! $VERBOSE) {
                        info_print("Found $wordpress_installations_count 'potential' wordpress installations ${ENDC}(use ${CYAN}--verbose${ENDC} for details).");
                } else {
                        info_print("Found $wordpress_installations_count 'potential' wordpress installations:");
                }
                my $wp_latest = get_latest_wordpress_version();
                info_print("Latest wordpress version is: $wp_latest");
                if ($VERBOSE) {
                        my $wp_latest = get_latest_wordpress_version();
                        foreach my $file (@wordpress_version_files_list) {
                                my $version = `grep "^\\\$wp_version" $file`;
                                chomp($version);
                                if ($version) {
                                        if ($version =~ /$wp_latest/) {
                                                good_print_item("$file ($version) <-- UP TO DATE");
                                        } else {
                                                bad_print_item("$file ($version) <-- PLEASE UPDATE");
                                        }
                                } else {
                                        info_print_item("$file (not wordpress)");
                                }
                        }
                }
        }
}

if ( @ARGV > 0 ) {
	foreach (@ARGV) {
		if ( -d $_) {
			$STARTDIR = $_;
			systemcheck_wordpress_versions($STARTDIR);
		} else { 
			bad_print("Doesnt appear to be a valid directory: ");
			bad_print_item($_);
		}
	}
} else {
	$STARTDIR = "/var/www";	
	info_print("Defaulting to " . $STARTDIR);
	systemcheck_wordpress_versions($STARTDIR);
}
print "Done.\n\n";
