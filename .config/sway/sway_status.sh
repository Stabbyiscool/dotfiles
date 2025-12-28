#!/bin/bash

VPN_CACHE_FILE="/tmp/vpn_country.cache"

get_vpn_location() {
    WG_INTERFACES=$(wg show interfaces 2>/dev/null | xargs)

    if [ -n "$WG_INTERFACES" ]; then
        COUNTRY=""
        if [ -f "$VPN_CACHE_FILE" ]; then
            COUNTRY=$(<"$VPN_CACHE_FILE")
        fi

        if [ -z "$COUNTRY" ]; then
            for i in {1..5}; do
                PUBLIC_IP=$(curl -s --max-time 2 https://ifconfig.me)
                COUNTRY=$(curl -s --max-time 2 "https://iplookup.stab.ing/api/v1/lookup?ip=$PUBLIC_IP" | jq -r .country)
                [ -n "$COUNTRY" ] && break
                sleep 1
            done
            [ -n "$COUNTRY" ] && echo "$COUNTRY" > "$VPN_CACHE_FILE"
        fi

        echo "VPN: ${COUNTRY:-Unknown}"
    else
        [ -f "$VPN_CACHE_FILE" ] && rm -f "$VPN_CACHE_FILE"
        echo ""
    fi
}

get_battery_status() {
    if [ -d "/sys/class/power_supply/BAT0" ]; then
        CAPACITY=$(<"/sys/class/power_supply/BAT0/capacity")
        STATUS=$(<"/sys/class/power_supply/BAT0/status")
        echo "BAT: $CAPACITY% ($STATUS)"
    else
        echo ""
    fi
}

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

    VPN_STATUS=$(get_vpn_location)
    BATTERY_STATUS=$(get_battery_status)
    TEXT="${REC:+$REC / }${VPN_STATUS:+$VPN_STATUS / }${BATTERY_STATUS:+$BATTERY_STATUS / }"

    echo "CPU: $CPU / RAM: $RAM / VOL: $VOL_PADDED/ ${TEXT}$DATE"

    sleep 1
done
