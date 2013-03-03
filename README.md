#
## README.md
#
#
## Created by Daniel Velez Schrod. <dvelezs(at)gmail(dot)com>
#
## Licenses
## All code is licensed under the [GPL version 3](http://www.gnu.org/licenses/gpl.html)
#
#


A command line tool that renames and copies media files, movies and tv shows, to a given path. Optionally it can be used as endscript for the Transmission BT Client.

### Initial Thoughts
The script uses 4 tests in order to determine if it's rather a tv show or a movie:

These tests are: 
* duration
* aspect ratio
* frame rate
* file size

Any mediafile with a duration longer than 90 minutes will be considered automatically as a movie.

In case of a shorter duration, the aspect ratio, frame rate and file size will be analyzed and in case of positive match of at least 2 of these tests, the file will be considered a movie aswell. Otherwise, the file will be processed as tv show. 

The positive match occurs when: 
* aspect ratio is not 4:3 or 16:9
* frame rate is 23.976 (24p)
* file size is above 2GB

The output path is set per default (initial setup is a big TODO) to:
* /Volumes/PLEX/TV
* /Volumes/PLEX/Movies

The output format, based on the filebot syntaxis is as follows:
* Movies:	"{n} ({y})"
* => Avatar (2009)

The shows are copied  into a sepparate folder per tv show and season:
* TV Shows:	"{n}/{s.pad(2)}x/{n} - {s}x{e.pad(2)} - {t}"
* => Firefly/01x/Firefly - 1x01 - Serenity

More information related this syntaxis can be found at: 
* http://filebot.sourceforge.net/naming.html

### Requirements
*  mediainfo (http://mediainfo.sourceforge.net)
* filebot-cli (http://filebot.sourceforge.net)

### How to use
./transmit.sh <<path_to_file>> <<file>> [TEST]

### Example
./transmit.sh /Users/daniel/Downloads/Transmission drive.mkv
or - test run
./transmit.sh /Users/daniel/Downloads/Transmission drive.mkv TEST

The output will be logged as default to /tmp/transmit.log
