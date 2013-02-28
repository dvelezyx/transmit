#!/bin/bash

clear

export TR_TORRENT_DIR=${1:-"${TR_TORRENT_DIR}"}
export TR_TORRENT_NAME=${2:-"${TR_TORRENT_NAME}"}
export TEST=${3:-"LIVE"}

export APPLICATIONS_PATH="/Applications"
export FILEBOT_APP="${APPLICATIONS_PATH}/FileBot.app/Contents/MacOS/filebot"
# export ACTION="-rename --action test -get-subtitles --lang en"
export ACTION="-rename --action copy --lang en"
export MIN_MOVIE_SIZE=2147483648
export MIN_MOVIE_DURATION=5400000
export MIN_MOVIE_STARS=4
export LOGFILE=/tmp/transmit.log
export OUTPUT_BASEDIR="/Volumes/PLEX"
export TR_TORRENT_FILE="${TR_TORRENT_DIR}/${TR_TORRENT_NAME}"

echo "TR_TORRENT_DIR:  $TR_TORRENT_DIR"  >> $LOGFILE
echo "TR_TORRENT_NAME: $TR_TORRENT_NAME" >> $LOGFILE
echo "TR_TORRENT_FILE: $TR_TORRENT_FILE" >> $LOGFILE

function tv_or_movie() {
 export MOVIE_STARS=0

 if [ $DURATION -ge $MIN_MOVIE_DURATION ]; then
  export MOVIE_STARS=`expr ${MOVIE_STARS} + 4`
 fi
	
 if [ $ASPECT_RATIO != "16:9" ]; then
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
 export DURATION=`mediainfo "--Inform=Video;%Duration%" "${FILE}"`
 export FILESIZE=`mediainfo "--Inform=General;%FileSize%" "${FILE}"`
 export ASPECT_RATIO=`mediainfo "--Inform=Video;%DisplayAspectRatio/String%" "${FILE}"`
 export FRAME_RATE=`mediainfo "--Inform=Video;%FrameRate%" "${FILE}"`
 
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

  export OUTPUT="--output ${OUTPUT_BASEDIR}/Movies"
  export DB="--db IMDb"
  export FORMAT="{n} ({y})"
  export QUERY=`basename "${FILE}" | cut -d . -f1`
  export QUERY=""

 else
  echo "It's a TV Show!" >> $LOGFILE

  export OUTPUT="--output ${OUTPUT_BASEDIR}/TV"
  export DB="--db TheTVDB"
  export FORMAT="{n}/{s.pad(2)}x/{n} - {s}x{e.pad(2)} - {t}"
  export QUERY=""
 fi
 
 if [ $TEST == "TEST" ]; then
  return
 fi

 export OPTIONS="${ACTION} ${DB} ${OUTPUT}"
 
 if [ "${QUERY}" != "" ]; then
  echo ${FILEBOT_APP} ${OPTIONS} --format "${FORMAT}" --q "${QUERY}" "${FILE}" >> $LOGFILE
  ${FILEBOT_APP} ${OPTIONS} --format "${FORMAT}" --q "${QUERY}" "${FILE}">> $LOGFILE
 else
  echo ${FILEBOT_APP} ${OPTIONS} --format "${FORMAT}" -non-strict "${FILE}" >> $LOGFILE
  ${FILEBOT_APP} ${OPTIONS} --format "${FORMAT}" -non-strict "${FILE}" >> $LOGFILE
 fi
}

find "${TR_TORRENT_FILE}" -type f | while read FILE; do
 analyze_file
done
