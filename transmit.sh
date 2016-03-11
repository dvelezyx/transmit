#!/bin/bash

#
## transmit.sh
#
#
## Created by Daniel Velez Schrod. <dvelezs(at)gmail(dot)com>
#
## Licenses
## All code is licensed under the [GPL version 3](http://www.gnu.org/licenses/gpl.html)
#
#

# echo $@

export TR_TORRENT_DIR="${1:-$TR_TORRENT_DIR}"
export TR_TORRENT_NAME="${2:-$TR_TORRENT_NAME}"
export TR_TORRENT_FILE="${TR_TORRENT_DIR}/${TR_TORRENT_NAME}"

export APPLICATIONS_PATH="/Users/${USER}/Applications"
export MEDIAINFO="/usr/local/bin/MEDIAINFO"
export MIN_MOVIE_DURATION="5400000"
export LOGFILE="/tmp/transmit.log"

export FILEBOT_APP="${APPLICATIONS_PATH}/FileBot.app/Contents/MacOS/filebot.sh"
export ACTION="-rename --action keeplink --lang en --conflict skip"
export DB="${3:-TheTVDB}"
export FORMAT="TV/{n}/{s.pad(2)}x/{n} - {s}x{e.pad(2)} - {t}"
export OUTPUT="/Volumes/My Passport Studio"


function format_time() {

 MILLISECONDS=$1

 hh=`expr $MILLISECONDS / 1000 / 60 / 60`
 mm=`expr $MILLISECONDS / 1000 / 60 % 60`
 ss=`expr $MILLISECONDS / 1000 % 60`

 printf "%02d:%02d:%02d" "$hh" "$mm" "$ss"

}


function analyze_file() {

 DURATION=`$MEDIAINFO "--Inform=Video;%Duration%" "${FILE}"`

 if [ ${DURATION:-0} -gt 0 ] ; then
 
  if [ $DURATION -ge $MIN_MOVIE_DURATION ] || [ "$DB" == "TheMovieDB" ] ; then
   
   # echo "It's a Movie!" >> $LOGFILE
   # echo "DURATION: `format_time ${DURATION}`" >> $LOGFILE
  
   export DB="TheMovieDB"
   export FORMAT="Movies/{n} ({y})"
  
  fi

  ${FILEBOT_APP} ${ACTION} --db $"{DB}" --output "${OUTPUT}" --format "${FORMAT}" -non-strict "${FILE}" --log-file "${LOGFILE}" --log info

 fi

}


clear

# echo "TR_TORRENT_DIR:  $TR_TORRENT_DIR"  >> $LOGFILE
# echo "TR_TORRENT_NAME: $TR_TORRENT_NAME" >> $LOGFILE

find "${TR_TORRENT_FILE}" -type f | while read FILE; do analyze_file; done
