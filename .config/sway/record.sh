#!/bin/bash

while getopts "o" opt; do
  case $opt in
    o) full="-o" ;;
  esac
done

OGFP="/home/$USER/records/$(date +'%Y-%m-%d_%H-%M-%S').mp4"

if pgrep -x "wf-recorder" > /dev/null; then
    killall wf-recorder
else
    wf-recorder -g "$(slurp $full)" -f "$OGFP" --audio=bluez_output.44_73_D6_F8_90_3C.1.monitor &
    REC_PID=$!
    wait $REC_PID
    ffmpeg -i "$OGFP" -vcodec libx264 -crf 28 -preset fast "${OGFP%.mp4}_comp.mp4"
    rm "$OGFP"
fi
