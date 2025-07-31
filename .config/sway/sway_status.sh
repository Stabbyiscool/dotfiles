#!/bin/bash

while true; do
    VOL=$(pamixer --get-volume-human)
    VOL_PADDED=$(printf "%-4s" "$VOL") 

    read total _ _ _ _ available < <(free -m | awk '/^Mem:/ {print $2, $3, $4, $5, $6, $7}')
    used_real=$((total - available))
    used_gib=$((used_real / 1024))
    total_gib=$((total / 1024))
    RAM="$(printf "%2dGiB/%2dGiB" "$used_gib" "$total_gib")"

    DATE=$(date +"%Y-%m-%d %I:%M %p")

    CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f", $2 + $4}')
    CPU="$(printf "%5s%%" "$CPU_LOAD")"

    REC=$(pgrep -x "wf-recorder" > /dev/null && echo "RECORDING!")

    USERNAME=$(whoami)
    if [ "$USERNAME" = "stabosa" ]; then
        USRTXT=$(curl -s http://192.168.1.44:8252/ | jq -r .latest_text)
        [ -z "$USRTXT" ] && USRTXT="NAN"
        TEXT="$USRTXT${REC:+ | $REC} | "
    else
        TEXT="${REC:+$REC | }"
    fi

    echo "${TEXT}$DATE | CPU: $CPU | RAM: $RAM | VOL: $VOL_PADDED"

    sleep 1
done
