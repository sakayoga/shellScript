#!/bin/bash
# convert dmesg time dari unix timestamp menjadi human readable
# harus dilakukan di lokasi melakukan dmesg
ut=`cut -d' ' -f1 < /proc/uptime`
ts=`date +%s`
realtime_date=`date -d"70-1-1 + $ts sec - $ut sec + $1 sec" +"%F %T"`
echo $realtime_date
