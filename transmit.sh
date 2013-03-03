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

export TR_TORRENT_DIR=${1:-"${TR_TORRENT_DIR}"}
export TR_TORRENT_NAME=${2:-"${TR_TORRENT_NAME}"}
export TR_TORRENT_FILE="${TR_TORRENT_DIR}/${TR_TORRENT_NAME}"
export TEST=${3:-"LIVE"}

function set_default_values() {
 export APPLICATIONS_PATH="/Applications"
 export FILEBOT_APP="${APPLICATIONS_PATH}/FileBot.app/Contents/MacOS/filebot"
 export MEDIAINFO="/usr/local/bin/mediainfo"
 export ACTION="-rename --action copy --lang en"
 export MIN_MOVIE_SIZE=2147483648
 export MIN_MOVIE_DURATION=5400000
 export MIN_MOVIE_STARS=4
 export LOGFILE=/tmp/transmit.log
 export OUTPUT="--output /Volumes/PLEX"
 export MOVIEFORMAT="Movies/{n} ({y})"
 export MOVIEDB=IMDb
 export SERIESFORMAT="TV/{n}/{s.pad(2)}x/{n} - {s}x{e.pad(2)} - {t}"
 export SERIESDB=TheTVDB
}

function tv_or_movie() {
 export MOVIE_STARS=0

 if [ $DURATION -ge $MIN_MOVIE_DURATION ]; then
  export MOVIE_STARS=`expr ${MOVIE_STARS} + 4`
 fi
	
 if [ $ASPECT_RATIO != "16:9" -a $ASPECT_RATIO != "4:3" ]; then
  export MOVIE_STARS=`expr ${MOVIE_STARS} + 2`
 fi
	
 if [ $FRAME_RATE == "23.976" ]; then
  export MOVIE_STARS=`expr ${MOVIE_STARS} + 2`
 fi

 if [ $FILESIZE -gt $MIN_MOVIE_SIZE ]; then
  export MOVIE_STARS=`expr ${MOVIE_STARS} + 2`
 fi

  echo Stars: $MOVIE_STARS >> $LOGFILE
}

function analyze_file() {
 export DURATION=`$MEDIAINFO "--Inform=Video;%Duration%" "${FILE}"`
 export FILESIZE=`$MEDIAINFO "--Inform=General;%FileSize%" "${FILE}"`
 export ASPECT_RATIO=`$MEDIAINFO "--Inform=Video;%DisplayAspectRatio/String%" "${FILE}"`
 export FRAME_RATE=`$MEDIAINFO "--Inform=Video;%FrameRate%" "${FILE}"`

 echo "${FILE}: ${DURATION}" ms    >> $LOGFILE
 echo "${FILE}: ${FILESIZE}" bytes >> $LOGFILE
 echo "${FILE}: ${ASPECT_RATIO}"   >> $LOGFILE
 echo "${FILE}: ${FRAME_RATE}" fps >> $LOGFILE

 if [ ${DURATION:-0} -le 0 ]; then
  echo "It's NOT a media file!" >> $LOGFILE
  return
 fi
 
 tv_or_movie
 
 if [ ${MOVIE_STARS:-0} -ge $MIN_MOVIE_STARS ]; then
  echo "It's a Movie!" >> $LOGFILE
  export DB="--db $MOVIEDB"
  export FORMAT=$MOVIEFORMAT
  export QUERY=""
 else
  echo "It's a TV Show!" >> $LOGFILE
  export DB="--db $SERIESDB"
  export FORMAT=$SERIESFORMAT
  export QUERY=""
fi
 
 if [ $TEST == "TEST" ]; then
  export ACTION="-rename --action test --lang en"
 fi

 export OPTIONS="${ACTION} ${DB} ${OUTPUT}"
 
 if [ "${QUERY}" != "" ]; then
  echo ${FILEBOT_APP} ${OPTIONS} --format "${FORMAT}" --q "${QUERY}" "${FILE}" >> $LOGFILE
  ${FILEBOT_APP} ${OPTIONS} --format "${FORMAT}" --q "${QUERY}" "${FILE}" >> $LOGFILE
 else
  echo ${FILEBOT_APP} ${OPTIONS} --format "${FORMAT}" -non-strict "${FILE}" >> $LOGFILE
  ${FILEBOT_APP} ${OPTIONS} --format "${FORMAT}" -non-strict "${FILE}" >> $LOGFILE
 fi
}

clear

set_default_values

echo "TR_TORRENT_DIR:  $TR_TORRENT_DIR"  >> $LOGFILE
echo "TR_TORRENT_NAME: $TR_TORRENT_NAME" >> $LOGFILE
echo "TR_TORRENT_FILE: $TR_TORRENT_FILE" >> $LOGFILE

find "${TR_TORRENT_FILE}" -type f | while read FILE; do
 analyze_file
done
