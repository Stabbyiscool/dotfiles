#!/bin/sh

PID_FILE="/tmp/autoclicker.pid"

if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")"
    rm "$PID_FILE"
    notify-send "StabClicker999" "Autoclicker disabled!" -i dialog-information -h int:transient:1
else
    (while true; do wlrctl pointer click "$1"; done) & echo $! > "$PID_FILE"
    notify-send "StabClicker999" "$1 Autoclicker enabled" -i dialog-information -h int:transient:1
fi
