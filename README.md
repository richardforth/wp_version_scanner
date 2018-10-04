# wp_version_scanner
Wordpress Version Scanner 

Now with 9000% more status so you know whats going on!

```
usage example:

# perl wpscan.pl --verbose
|--| Latest wordpress version is: 4.9.8
|--| Searching /var/www for any wordpress installations, please wait...
|!!|     *  (4.9.7) [ PLEASE UPDATE ] /var/www/wptesting/wp2/version.php
|--|     *  [ NOT WORDPRESS ] /var/www/somesite/someshoppingcart/version.php
|OK|     *  (4.9.8) [ UP TO DATE    ] /var/www//wptesting/wp306/version.php
|--| Summary Report for /var/www:
|--| Found 3 'potential' wordpress installations:
|OK|  -> 1 up to date.
|!!|  -> 1 require updating.
|--|  -> 1 found not to be wordpress after closer inspection.
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
