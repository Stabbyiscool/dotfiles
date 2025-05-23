#!/bin/bash

while true; do
    VOL=$(pamixer --get-volume-human)

    read total _ _ _ _ available < <(free -m | awk '/^Mem:/ {print $2, $3, $4, $5, $6, $7}')
    used_real=$((total - available))
    used_gib=$((used_real / 1024))
    total_gib=$((total / 1024))
    RAM="${used_gib}GiB/${total_gib}GiB"

    DATE=$(date +"%Y-%m-%d %I:%M %p")
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f%%", $2 + $4}')
    REC=$(pgrep -x "wf-recorder" > /dev/null && echo "RECORDING!")

    USERNAME=$(whoami)
    if [ "$USERNAME" = "stabosa" ]; then
        USRTXT=$(curl -s http://192.168.1.44:8252/ | jq -r .latest_text)
        [ -z "$USRTXT" ] && USRTXT="NAN"
        TEXT="$USRTXT${REC:+ | $REC} | "
    else
        TEXT="${REC:+$REC | }"
    fi

    echo "${TEXT}$DATE | CPU: $CPU | RAM: $RAM | VOL: $VOL"

    sleep 1
done
