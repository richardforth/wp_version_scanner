# wp_version_scanner
Wordpress Version Scanner 

Please note the example below is out of date as the output has changed slightly but gives you a good idea of what it does, I'll get a more up to date example shortly.

```
usage example:

# perl wpscan.pl /var/www /mnt /home --verbose
|--| Latest wordpress version is: 4.7.3
|--| Searching /var/www for any wordpress installations, please wait...
|--| Summary Report for /var/www:
|--| Found 3 'potential' wordpress installations:
|OK|     *  /var/www/website1/wp-includes/version.php (4.7.3) <-- UP TO DATE
|--|     *  /var/www/website2/version.php (not wordpress)
|!!|     *  /var/www/website3/version.php (4.7.1) <-- PLEASE UPDATE
|OK|  -> 1 up to date.
|!!|  -> 1 require updating.
|--|  -> 1 found not to be wordpress installations after closer inspection.
|--| Searching /mnt for any wordpress installations, please wait...
|--| Summary Report for /mnt:
|OK| No wordpress installations detected.
|--| Searching /home for any wordpress installations, please wait...
|--| Summary Report for /home:
|OK| No wordpress installations detected.
Done.

# perl wpscan.pl --help
Usage: wpscan.pl [space delimited list of directories] [OPTIONS]
If no options are specified, the basic tests will be run.
        -b, --bbcode            Print output in BBCODE style (useful for forums or ticketing systems that support bbcode)
        -h, --help              Print this help message
        -L, --light-term        Show colours for a light background terminal.
        -n, --nocolor           Use default terminal color, dont try to be all fancy!
        -v, --verbose           Use verbose output (display list of wordpress versions found and where, and what version)

default to /var/www if no argument found
default to ANSI colors unless --bbcode option is used
```
