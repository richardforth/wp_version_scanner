# wp_version_scanner
Wordpress Version Scanner 

```
usage example:

# perl wpscan.pl /home /var/www /mnt/san --verbose
|--| Searching /home for any wordpress installations, please wait...
|--| No wordpress installations detected.
|--| Searching /var/www for any wordpress installations, please wait...
|--| Found 2 'potential' wordpress installations:
|--| Latest wordpress version is: 4.7.1
|OK|     *  /var/www/html/wordpress1/wp-includes/version.php ($wp_version = '4.7.1';) <-- UP TO DATE
|!!|     *  /var/www/html/wordpress/wp-includes/version.php ($wp_version = '4.7';) <-- PLEASE UPDATE
[!!] Doesnt appear to be a valid directory:
|!!|     *  /mnt/san
Done.


# perl wpscan.pl --help
Usage: wpscan.pl [space delimited list of directories] [OPTIONS]
If no options are specified, the basic tests will be run.
        -h, --help              Print this help message
        -L, --light-term        Show colours for a light background terminal.
        -n, --nocolor           Use default terminal color, dont try to be all fancy!
        -v, --verbose           Use verbose output (display list of wordpress versions found and where, and what version)

default to /var/www if no argument found
default to ANSI colors unless --bbcode option is used
```
