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

# $ECHO $@
export ECHO="echo -e $(date '+%Y-%m-%d %H:%M:%S')"
export UNAME=$(uname)
export TR_TORRENT_DIR="${1:-$TR_TORRENT_DIR}"
export TR_TORRENT_NAME="${2:-$TR_TORRENT_NAME}"
export TR_TORRENT_FILE="${TR_TORRENT_DIR}"

if [ "${TR_TORRENT_NAME}" != "" ] ; then
 export TR_TORRENT_FILE="${TR_TORRENT_DIR}/${TR_TORRENT_NAME}"
fi

export FILEBOT_APP=/usr/local/bin/filebot
export MEDIAINFO=/usr/local/bin/mediainfo
export MIN_MOVIE_DURATION="5400000"
export LOGFILE="/tmp/transmit.log"

export ACTION="-rename --action ${3:-"keeplink"} --lang en --conflict skip"
export DB="${4:-TheTVDB}"
export FORMAT="TV/{n}/{s.pad(2)}x/{n} - {s}x{e.pad(2)} - {t}"
export OUTPUT="/Volumes/My Passport Studio"

if [ "$UNAME" == "Linux" ] ; then
 export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games
 export MEDIAINFO="/usr/bin/mediainfo"
 export FILEBOT_APP="/usr/bin/filebot"
fi

function format_time() {

 MILLISECONDS=$1

 hh=`expr $MILLISECONDS / 1000 / 60 / 60`
 mm=`expr $MILLISECONDS / 1000 / 60 % 60`
 ss=`expr $MILLISECONDS / 1000 % 60`

 printf "%02d:%02d:%02d" "$hh" "$mm" "$ss"

}

function syncVolumes() {

 #if [[ "$(uname)"=="Linux" ]] ; then 
 #  $ECHO "syncing to My Passport Studio." ;
 #  rsync -av --log-file=/tmp/rsync_$$.log "/Volumes/My Passport Studio/TV" "/Volumes/My Passport Studio/Movies" -e ssh daniel@mac-mini:/Volumes/My\\\ Passport\\\ Studio/
 #elif [[ "$(uname)"=="Darwin" ]]; then
   $ECHO "syncing to My Raspberry Pi." ;
   readlink "${TR_TORRENT_FILE}" "${TR_TORRENT_FILE}"/* | while read LINK ; do rsync -avh --exclude=/Volumes --log-file=/tmp/rsync_$$.log --omit-dir-times --relative --progress "$(echo "/Volumes/My Passport Studio/"$LINK | sed 's/\.\.\///g')" -e ssh pi@raspberry:/ ; done
 #else
 #  $ECHO "syncing unwatched files from My Passport Studio." ;
 #fi

}

function analyze_file() {

 echo "*********************************************************************************************************************************************" | tee -a $LOGFILE
 
 FILE="$1"
 
 $ECHO "analyze_file" "${FILE}" | tee -a $LOGFILE

 VIDEO_DURATION=$($MEDIAINFO "--Inform=Video;%Duration%" "$FILE")
 GENERAL_DURATION=$($MEDIAINFO "--Inform=General;%Duration%" "$FILE")
 DURATION=${VIDEO_DURATION:-$GENERAL_DURATION}
 
 $ECHO "Duration: ${DURATION}"   | tee -a $LOGFILE

 if [ ${DURATION:-0} -gt 0 ] ; then
 
  if [ $DURATION -ge $MIN_MOVIE_DURATION ] || [ "$DB" == "TheMovieDB" ] ; then
     
   DB="TheMovieDB"
   FORMAT="Movies/{n} ({y})"
  
  fi

  # $ECHO "${FILEBOT_APP} ${ACTION} --db "${DB}" --output "${OUTPUT}" --format "${FORMAT}" -non-strict "${FILE}" --log all" | tee -a "${LOGFILE}"
  ${FILEBOT_APP} ${ACTION} --db "${DB}" --output "${OUTPUT}" --format "${FORMAT}" -non-strict "${FILE}" --log all | tee -a "${LOGFILE}"  # --log-file "${LOGFILE}" 
  
  $ECHO "syncing to My Raspberry Pi." | tee -a $LOGFILE
  # $ECHO "readlink "${FILE}" | while read LINK ; do rsync -avh --exclude=/Volumes --log-file=/tmp/rsync_$$.log --omit-dir-times --relative --progress "$(echo "/Volumes/My Passport Studio/"$LINK | sed 's/\.\.\///g')" -e ssh pi@raspberry:/ ; done" | tee -a $LOGFILE
  readlink "${FILE}" | while read LINK ; do rsync -avh --exclude=/Volumes --log-file=/tmp/rsync_$$.log --omit-dir-times --relative --progress "$(echo "/Volumes/My Passport Studio/"$LINK | sed 's/\.\.\///g')" -e ssh pi@raspberry:/ ; done

 fi

}

clear

cd "${TR_TORRENT_DIR}"

echo "*********************************************************************************************************************************************" | tee -a $LOGFILE

$ECHO PWD: $(pwd) | tee -a $LOGFILE
$ECHO "TR_TORRENT_DIR:  $TR_TORRENT_DIR"  | tee -a $LOGFILE
$ECHO "TR_TORRENT_NAME: $TR_TORRENT_NAME" | tee -a $LOGFILE
$ECHO "TR_TORRENT_FILE: $TR_TORRENT_FILE" | tee -a $LOGFILE

if [ -f "${TR_TORRENT_FILE}" ] ; then
  analyze_file "${TR_TORRENT_FILE}"
else  
 # $ECHO "find \""${TR_TORRENT_FILE}"\" -type f ! -type l ! -name *.part ! -name *.pdf ! -name *.txt ! -name *.url ! -name .DS* -print | while read FILE; do analyze_file "$FILE"; done" | tee -a $LOGFILE
 find "${TR_TORRENT_FILE}" -type f ! -type l ! -name *.part ! -name *.pdf ! -name *.txt ! -name *.url ! -name .DS* -print | while read FILE; do analyze_file "$FILE"; done

fi

#syncVolumes
