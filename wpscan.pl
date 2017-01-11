#!/usr/bin/perl
eval "use diagnostics; 1"  or die("\n[ FATAL ] Could not load the Diagnostics module.\n\nTry:\n\n      sudo apt-get install perl-modules\n\nThen try running this script again.\n\n");
use Getopt::Long qw(:config no_ignore_case bundling pass_through);
use POSIX;
use strict;
use warnings;

our $VERBOSE = "";
our $NOCOLOR = 0;
my $LIGHTBG = 0;


our $RED;
our $GREEN;
our $YELLOW;
our $BLUE;
our $PURPLE;
our $CYAN;
our $ENDC;
our $BOLD;
our $UNDERLINE;
if ( ! $NOCOLOR ) {
	if ( ! $LIGHTBG ) {
		$RED = "\033[91m";
		$GREEN = "\033[92m"; # Like a light green color, not good for light terminals, but perfect for dark, eg PuTTY, terminals.
		$YELLOW = "\033[93m"; # Like a yellow color, not good for light terminals, but perfect for dark, eg PuTTY, terminals.
		$BLUE = "\033[94m";
		$PURPLE = "\033[95m"; # technically its Magento... 
		$CYAN = "\033[96m"; # Like a light blue color, not good for light terminals, but perfect for dark, eg PuTTY, terminals.
	} else {
		$RED = "\033[1m"; # bold all the things!
		$GREEN = "\033[1m"; # bold all the things!
		$YELLOW = "\033[1m"; # bold all the things!
		$BLUE = "\033[1m"; # bold all the things!
		$PURPLE = "\033[1m"; # bold all the things!
		$CYAN = "\033[1m";  # bold all the things!
	}
	$ENDC = "\033[0m"; # reset the terminal color
	$BOLD = "\033[1m"; # what it says on the tin, you can double up eg make a bold red: ${BOLD}${RED}Something${ENDC}
	$UNDERLINE = "\033[4m"; # again you can double this one up.
} else {
	$RED = ""; # SUPPRESS COLORS
	$GREEN = ""; # SUPPRESS COLORS
	$YELLOW = ""; # SUPPRESS COLORS
	$BLUE = ""; # SUPPRESS COLORS
	$PURPLE = ""; # SUPPRESS COLORS
	$CYAN = ""; # SUPPRESS COLORS
	$ENDC = ""; # SUPPRESS COLORS
	$BOLD = ""; # SUPPRESS COLORS
	$UNDERLINE = ""; # SUPPRESS COLORS
}


GetOptions(
	'light-term|L' => \$LIGHTBG,
	'nocolor|n' => \$main::NOCOLOR,
	'verbose|v' => \$VERBOSE,
);

sub info_print {
	print "[${BOLD}${BLUE}--${ENDC}] $_[0]\n";
}

sub good_print_item {
	print "[${BOLD}${GREEN}OK${ENDC}]${GREEN}     *  $_[0]${ENDC}\n";
}

sub bad_print_item {
	print "[${BOLD}${RED}!!${ENDC}]${RED}     *  $_[0]${ENDC}\n";
}

sub info_print_item {
	print "[${BOLD}${BLUE}--${ENDC}]     *  $_[0]\n";
}


sub get_latest_wordpress_version {
        our $response = `curl -sILk wordpress.org/latest | grep Content-Disposition`;
        our ($wp_latest_version) = $response =~ /(\d+.\d+(.\d+)?)/;
        return $wp_latest_version;
}

sub systemcheck_wordpress_versions {
        info_print("Searching for any wordpress installations, please wait...");
        our $wordpress_version_files_rawlist = `find /var/www -type f -name "version.php"`;
        our @wordpress_version_files_list = split('\n', $wordpress_version_files_rawlist);
        our $wordpress_installations_count = @wordpress_version_files_list;
        if ($wordpress_installations_count eq 0) {
                info_print("Skipping wordpress tests due to no installations detected.")
        } else {
                if (! $VERBOSE) {
                        info_print("Found $wordpress_installations_count 'potential' wordpress installations ${ENDC}(use ${CYAN}--verbose${ENDC} for details).");
                        my $wp_latest = get_latest_wordpress_version();
                        info_print("Latest wordpress version is: $wp_latest");
                } else {
                        info_print("Found $wordpress_installations_count 'potential' wordpress installations:");
                        my $wp_latest = get_latest_wordpress_version();
                        info_print("Latest wordpress version is: $wp_latest");
                }
                if ($VERBOSE) {
                        my $wp_latest = get_latest_wordpress_version();
                        foreach my $file (@wordpress_version_files_list) {
                                my $version = `grep "^\\\$wp_version" $file`;
                                chomp($version);
                                if ($version) {
                                        if ($version =~ /$wp_latest/) {
                                                good_print_item("$file ($version) <-- UP TO DATE");
                                        } else {
                                                bad_print_item("$file ($version) <-- PLEASE UPDATE URGENTLY");
                                        }
                                } else {
                                        info_print_item("$file (not wordpress)");
                                }
                        }
                }
        }
}

systemcheck_wordpress_versions();
