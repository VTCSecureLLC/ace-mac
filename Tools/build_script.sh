#!/bin/bash

set -xe

python prepare.py -G Ninja -DENABLE_WEBRTC_AEC=ON -DENABLE_H263=YES -DENABLE_FFMPEG=YES -DENABLE_NON_FREE_CODECS=ON  -DENABLE_GPL_THIRD_PARTIES=ON -DENABLE_AMRWB=YES -DENABLE_AMRNB=YES -DENABLE_OPENH264=YES -DENABLE_G729=YES -DENABLE_MPEG4=YES -DENABLE_H263P=YES -DENABLE_ILBC=YES -DENABLE_ISAC=YES -DENABLE_SILK=YES -DENABLE_VCARD=ON -p

LOGFILE=/tmp/build_script.out

echo "Building"

touch $LOGFILE

(
  COUNTER=0
  while [  $COUNTER -lt 30 ]; do
    echo The counter is $COUNTER
    let COUNTER=COUNTER+1
    sleep 60
    echo "Muted, but still building. Last 100 lines:"
    tail -100 $LOGFILE
  done
  echo "Timing out after 30 minutes."
) &
MUTED_PID=$!

echo "Running make for dependencies"
make -j 8 >> $LOGFILE 2>&1

MAKE_RESULT=$?

tail -1000 $LOGFILE
kill $MUTED_PID

echo exit $MAKE_RESULT
exit $MAKE_RESULT
