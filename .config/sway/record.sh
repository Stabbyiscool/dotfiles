#!/bin/bash

mkdir -p "$HOME/records"

while getopts "o" opt; do
  case $opt in
    o) full="-o" ;;
  esac
done

OGFP="$HOME/records/$(date +'%Y-%m-%d_%H-%M-%S').mp4"

if pgrep -x "wf-recorder" > /dev/null; then
    killall wf-recorder
else
    SELECTION=$(slurp $full)
    if [ -z "$SELECTION" ]; then
        exit 1
    fi
    wf-recorder -g "$SELECTION" -f "$OGFP" &
    REC_PID=$!
    wait $REC_PID
    if [ ! -f "$OGFP" ]; then
        exit 1
    fi
    ffmpeg -i "$OGFP" -vf "scale=-2:720" -vcodec libx264 -crf 32 -preset fast "${OGFP%.mp4}_comp720p.mp4"
    rm "$OGFP"
fi

