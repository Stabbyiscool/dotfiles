#!/bin/bash

while true; do
    VOL=$(pamixer --get-volume-human)
    RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
    DATE=$(date +"%Y-%m-%d %H:%M")
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f%%", $2 + $4}')
    REC=$(pgrep -x "wf-recorder" > /dev/null && echo "RECORDING!")

    USRTXT=$(curl -s http://192.168.1.44:8252/ | jq -r .latest_text)
    [ -z "$USRTXT" ] && USRTXT="NAN"

    echo "$USRTXT${REC:+ | $REC} | $DATE | CPU: $CPU | RAM: $RAM | VOL: $VOL"

    sleep 1
done
