#!/bin/bash

clear

export APPLICATIONS_PATH="/Applications"
export FILEBOT_APP="${APPLICATIONS_PATH}/FileBot.app/Contents/MacOS/filebot"

export OUTPUT_BASEDIR="/Volumes/PLEX"

export TR_TORRENT_DIR=${1:-"${TR_TORRENT_DIR}"}
export TR_TORRENT_NAME=${2:-"${TR_TORRENT_NAME}"}
export TR_TORRENT_FILE="${TR_TORRENT_DIR}/${TR_TORRENT_NAME}"
export ACTION="-rename --action test -get-subtitles --lang en"
export ACTION="-rename --action copy --lang en"
export MIN_MOVIE_SIZE=2390107730
export LOGFILE=/tmp/transmit.log

echo "TR_TORRENT_DIR:  $TR_TORRENT_DIR"  >> $LOGFILE
echo "TR_TORRENT_NAME: $TR_TORRENT_NAME" >> $LOGFILE
echo "TR_TORRENT_FILE: $TR_TORRENT_FILE" >> $LOGFILE

function analyze_file() {
 export FILESIZE=`stat -f "%z" "${FILE}"`
 
 echo "${FILE}: ${FILESIZE}" >> $LOGFILE
 
 if [ $FILESIZE -gt $MIN_MOVIE_SIZE ]; then
  echo "It's a Movie!" >> $LOGFILE

  export OUTPUT="--output ${OUTPUT_BASEDIR}/Movies"
  export DB="--db TheMovieDB"
  export FORMAT="{n} ({y})"
  export QUERY=`basename "${FILE}" | cut -d . -f1`
  
 else
  echo "It's a TV Show!" >> $LOGFILE

  export OUTPUT="--output ${OUTPUT_BASEDIR}/TV"
  export DB="--db TheTVDB"
  export FORMAT="{n}/{s.pad(2)}x/{n} - {s}x{e.pad(2)} - {t}"
  export QUERY=""
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

if [ -d "${TR_TORRENT_FILE}" ]; then
 echo "It's a [D]irectory!"  >> $LOGFILE
 cd "${TR_TORRENT_FILE}"
 for FILE in *; do
  analyze_file
 done
 cd -
else
 cd "${TR_TORRENT_DIR}"
 FILE="${TR_TORRENT_FILE}"
 analyze_file
 cd -
fi

