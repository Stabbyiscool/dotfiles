#!/bin/bash

while true; do
    VOL=$(pamixer --get-volume-human)
    RAM=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
    DATE=$(date +"%Y-%m-%d %H:%M:%S")
    CPU=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f%%", $2 + $4}')
    REC=$(pgrep -x "wf-recorder" > /dev/null && echo "RECORDING!")

    RESPONSE=$(curl -s -m 10 -w "%{http_code}" -o /dev/null https://stabosa.fun)
    if [ "$RESPONSE" != "200" ]; then
        echo "MAKAN SERVERS ARE DOWN!"
        sleep 1
        continue
    fi

    USRTXT=$(curl -s http://192.168.1.44:8252/ | jq -r .latest_text)
    [ -z "$USRTXT" ] && USRTXT="NAN"

    echo "$USRTXT${REC:+ | $REC} | $DATE | CPU: $CPU | RAM: $RAM | VOL: $VOL"

    sleep 1
done
