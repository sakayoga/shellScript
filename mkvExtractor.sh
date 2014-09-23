#!/bin/bash
# extract audio,video,subtitles,font,chapter dari file mkv
# perlu di ketahui attachment dalam mkv dimulai dari nomor 1 bukan 0
# disarankan berada pada direktori yang sama dengan file
# batasan : untuk h264 video, subtitle hanya ass dan srt

# check kebutuhan
DEPEN="mkvextract mkvinfo"
for a in $DEPEN
do
    which $a > /dev/null 2>&1
    [ $? -eq 1 ] && printf "perintah $a tidak ditemukan, mkvtoolnix-cli belum terinstall\n" && exit 1
done
# end check

font () {
    mkvinfo "$SourceFile" |grep "File name"|awk -F": " '{print $2}' > /tmp/attlist
    totalFont=`cat /tmp/attlist|wc -l`
    if [ $totalFont -eq 0 ]; then
      printf "Tidak ditemukan font pada file\n"
    else
      printf "Jumlah Font yang ditemukan : $totalFont\n"
      let batasBawah=1
      while read line
      do
	mkvextract attachments "$SourceFile" $batasBawah:"$line"
	let batasBawah=batasBawah+1
      done < /tmp/attlist
      rm /tmp/attlist
    fi
}

chapter () {
   mkvinfo "$SourceFile"|grep Chapters >/dev/null
   if [ $? -eq 0 ]; then
      mkvextract chapters "$SourceFile" > "$SourceFileSplit.xml"
      printf "chapter save as $SourceFileSplit.xml\n"
   else
      printf "Tidak ditemukan chapter pada file\n"
   fi
}

audio () {
  audioNumber=1
  trackE=0
  while [ $trackE -ne $JumlahTrack ]; do
      mkvinfo "$SourceFile" |grep -A 7 "mkvextract: $trackE" |grep "type: audio" >/dev/null
      if [ $? -eq 0 ]; then
	      audiotype=`mkvinfo "$SourceFile" |grep -A 11 "mkvextract: $trackE"|grep "Codec ID:"|awk -F: '{print $2}'|awk -F_ '{print $2}'| tr '[:upper:]' '[:lower:]'`
	      mkvextract tracks "$SourceFile" $trackE:"${SourceFileSplit}_0${audioNumber}.${audiotype}"
	      let audioNumber=$audioNumber+1
      fi
      let trackE=$trackE+1
  done

}

video () {
  videoNumber=1
  trackE=0
  while [ $trackE -ne $JumlahTrack ]; do
      mkvinfo "$SourceFile" |grep -A 7 "mkvextract: $trackE" |grep "type: video" >/dev/null
      if [ $? -eq 0 ]; then
	      mkvextract tracks "$SourceFile" $trackE:"${SourceFileSplit}_0${videoNumber}.264"
	      let videoNumber=$videoNumber+1
      fi
      let trackE=$trackE+1
  done
}

subtitle ()  {
  subtitleNumber=1
  trackE=0
  while [ $trackE -ne $JumlahTrack ]; do
      mkvinfo "$SourceFile" |grep -A 7 "mkvextract: $trackE" |grep "type: subtitles" >/dev/null
      if [ $? -eq 0 ]; then
	      subtitletype=`mkvinfo "$SourceFile" |grep -A 7 "mkvextract: $trackE"|grep "Codec ID:"|awk -F/ '{print $2}'| tr '[:upper:]' '[:lower:]'`
	      mkvextract tracks "$SourceFile" $trackE:"${SourceFileSplit}_0${subtitleNumber}.${subtitletype}"
	      let subtitleNumber=$subtitleNumber+1
      fi
      let trackE=$trackE+1
  done
}

case "$1" in
 video|audio|subtitle|chapter|font|all)
    [ -z "$2" ] && printf "usage $0 [video|audio|subtitle|chapter|font|all] sumber_file\n" && exit 1
    [ ! -f "$2" ] && printf "file tidak dapat ditemukan.\n" && exit 1
    Options="$1"
    SourceFile="$2"
    SourceFileSplit="`echo "${SourceFile%.*}"`"
    JumlahTrack=`mkvinfo "$SourceFile" |grep "mkvextract: "|wc -l`
    if [ "$Options" == "all" ]; then
      video
      audio
      subtitle
      chapter
      font
    else
      $Options
    fi
    exit 0
 ;;
 *)
    echo "usage $0 [video|audio|subtitle|font|all] sumber_file"
    exit 1
esac
