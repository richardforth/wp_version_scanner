#!/usr/bin/perl
use diagnostics;
use Getopt::Long qw(:config no_ignore_case bundling pass_through);
use POSIX;
use strict;
use warnings;
use File::Find;
# use LWP::UserAgent;

our $VERBOSE = "";
our $NOCOLOR = 0;
our $LIGHTBG = 0;
our $BBCODE = 0;
my $help = "";

sub usage {
	our $usage_output = <<'END_USAGE';
Usage: wpscan.pl [space delimited list of directories] [OPTIONS]
If no options are specified, the basic tests will be run.
	-b,--bbcode		Print output in BBCODE style (useful for forums or ticketing systems that support bbcode)
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
our $WHITE;
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
	$WHITE = ""; # SUPPRESS COLORS
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
	$WHITE = "\033[1m";  # bold all the things!
	$BOLD = "\033[1m"; # Default to ANSI codes.     
	$ENDBOLD = "\033[0m"; # Default to ANSI codes.     
	$UNDERLINE = "\033[4m"; # Default to ANSI codes.     
	$ENDUNDERLINE = "\033[0m"; # Default to ANSI codes.     
	$ENDC = "\033[0m"; # Default to ANSI codes
} elsif ($BBCODE) {
	$RED = "[color=#FF0000]"; # 
	$GREEN = "[color=#0000FF]"; # Make GREEN appear as BLUE, as green looks horrid on forums, hard to read. 
	$YELLOW = ""; # 
	$BLUE = "[color=#0000FF]"; # 
	$PURPLE = ""; # 
	$CYAN = ""; # 
	$WHITE = ""; # 
	$BOLD = "[b]"; # 
	$ENDBOLD = "[/b]"; # 
	$UNDERLINE = "[u]"; # 
	$ENDUNDERLINE = "[/u]"; # 
	$ENDC = "[/color]"; # 
} else {
	$RED = "\033[91m"; # Default to ANSI codes.
	$GREEN = "\033[92m"; # Default to ANSI codes. 
	$YELLOW = "\033[93m"; # Default to ANSI codes. 
	$BLUE = "\033[94m"; # Default to ANSI codes.  
	$PURPLE = "\033[95m"; # Default to ANSI codes.     
	$CYAN = "\033[96m"; # Default to ANSI codes.     
	$WHITE = "\033[97m"; # Default to ANSI codes.     
	$BOLD = "\033[1m"; # Default to ANSI codes.     
	$ENDBOLD = "\033[0m"; # Default to ANSI codes.     
	$UNDERLINE = "\033[4m"; # Default to ANSI codes.     
	$ENDUNDERLINE = "\033[0m"; # Default to ANSI codes.     
	$ENDC = "\033[0m"; # Default to ANSI codes
}

sub info_print {
	print "|${BOLD}${BLUE}--${ENDC}${ENDBOLD}| $_[0]\n";
}

sub good_print {
	print "|${BOLD}${GREEN}OK${ENDC}${ENDBOLD}|${GREEN} $_[0]${ENDC}\n";
}

sub bad_print {
	print "|${BOLD}${RED}!!${ENDC}${ENDBOLD}|${RED} $_[0]${ENDC}\n";
}

sub info_print_item {
	print "|${BOLD}${BLUE}--${ENDC}${ENDBOLD}|     *  $_[0]\n";
}

sub good_print_item {
	print "|${BOLD}${GREEN}OK${ENDC}${ENDBOLD}|${GREEN}     *  $_[0]${ENDC}\n";
}

sub bad_print_item {
	print "|${BOLD}${RED}!!${ENDC}${ENDBOLD}|${RED}     *  $_[0]${ENDC}\n";
}

sub get_latest_wordpress_version {
        #my $url = 'http://wordpress.org/latest';
	#my $ua = 'LWP::UserAgent'->new;
	
	#if (my $header = $ua->head($url)) {
    	#	my ($wp_latest_version) = $header->header('Content-Disposition') =~ /(\d+\.\d+(?:\.\d+)?)/;
    	our $url = "https://wordpress.org/latest";
	our $response = `curl -sILk wordpress.org/latest | grep Content-Disposition`;
	our ($wp_latest_version) = $response =~ /(\d+.\d+(.\d+)?)/;
    	return $wp_latest_version;
    	#	return $wp_latest_version;
	#} else {
    	#	die "Can't retrieve the header from '$url'.\n";
	#}
}

sub systemcheck_wordpress_versions {
	my ($STARTDIR) = @_;
	our @wordpress_version_files_list = (); # reset the counter = see issue #18
	our $uptodate_counter = 0;
	our $requiresupdate_counter = 0;
	our $notwordpress_counter = 0;
        info_print("Searching ${BLUE}$STARTDIR${ENDC} for any wordpress installations, please wait...");
	find(sub {push @wordpress_version_files_list, $File::Find::name  if $_ eq "version.php"},  $STARTDIR);
	info_print("${BOLD}${UNDERLINE}Summary Report for $STARTDIR:${ENDUNDERLINE}${ENDBOLD}");
        our $wordpress_installations_count = @wordpress_version_files_list;
        if ($wordpress_installations_count eq 0) {
                good_print("No wordpress installations detected.")
        } else {
                if (! $VERBOSE) {
                        info_print("Found ${BOLD}$wordpress_installations_count${ENDBOLD} '${UNDERLINE}potential${ENDUNDERLINE}' wordpress installations ${ENDC}(use ${CYAN}--verbose${ENDC} for details).");
                } else {
                        info_print("Found ${BOLD}$wordpress_installations_count${ENDBOLD} '${UNDERLINE}potential${ENDUNDERLINE}' wordpress installations:");
                }
                my $wp_latest = get_latest_wordpress_version();
                foreach my $file (@wordpress_version_files_list) {
			our $raw_version;
			if ($raw_version) {
				undef $raw_version;
			}
			if ( -f $file) {
				open my $fh, '<', $file or die $!;
				my @lines = <$fh>;
				foreach my $line (@lines) {
					if ($line =~ m/^\$wp_version/) {
						$raw_version = $line;
						last; # no point processing any more lines
					}
				} 
                               	if ($raw_version) {
					chomp($raw_version);
                               	        my ($version) = $raw_version =~ /(\d+.\d+(.\d+)?)/; 
					if ($version =~ /$wp_latest/) {
						$uptodate_counter++;
                              		        if ($VERBOSE) { good_print_item("($version) [ UP TO DATE    ] ${WHITE}$file${ENDC}") }
                        	        } else {
						$requiresupdate_counter++;
                                       	        if ($VERBOSE) { bad_print_item("($version) [ PLEASE UPDATE ] ${WHITE}$file${ENDC}") }
                                 	}
                                } else {
					$notwordpress_counter++;
                                	if ($VERBOSE) { info_print_item("[ ${CYAN}NOT WORDPRESS${ENDC} ] ${WHITE}$file${ENDC}") }
                                }
			} 
		}
		if ($uptodate_counter eq 0) {
			bad_print(" -> None up to date.")
		} else {
			good_print(" -> ${BOLD}$uptodate_counter${ENDBOLD} up to date.")
		}
		if ($requiresupdate_counter eq 0) {
			good_print(" -> ${BOLD}None${ENDBOLD} require updating.")
		} else {
			bad_print(" -> ${BOLD}$requiresupdate_counter${ENDBOLD} require updating.")
		}
		if ($notwordpress_counter gt 0) {
			info_print(" -> ${BOLD}$notwordpress_counter${ENDBOLD} found not to be wordpress after closer inspection.")
		}
	}
}	


#########################################
## MAIN SCRIPT EXECUTION STARTS HERE
#########################################
my $wp_latest = get_latest_wordpress_version();
info_print("Latest wordpress version is: ${BOLD}$wp_latest${ENDBOLD}");
if ( @ARGV > 0 ) {
	foreach (@ARGV) {
		if ( -d $_) {
			my $STARTDIR = $_;
			systemcheck_wordpress_versions($STARTDIR);
		} else { 
			bad_print("Doesnt appear to be a valid directory: ");
			bad_print_item($_);
		}
	}
} else {
	my $STARTDIR = "/var/www";	
	info_print("Defaulting to " . $STARTDIR);
	if ( -d $STARTDIR) {
		systemcheck_wordpress_versions($STARTDIR);
	} else { 
		bad_print("Doesnt appear to be a valid directory: ");
		bad_print_item($STARTDIR);
	}
}
print "Done.\n\n";
