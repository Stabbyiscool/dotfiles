#!/bin/bash

VPN_CACHE_FILE="/tmp/vpn_country.cache"

get_vpn_location() {
    WG_INTERFACES=$(wg show interfaces)
    
    if [ -n "$WG_INTERFACES" ]; then
        if [ -f "$VPN_CACHE_FILE" ]; then
            COUNTRY=$(<"$VPN_CACHE_FILE")
        else
            PUBLIC_IP=$(curl -s --max-time 2 ifconfig.me)
            COUNTRY=$(curl -s --max-time 2 "https://iplookup.stab.ing/lookup?ip=$PUBLIC_IP" | jq -r .country)
            [ -n "$COUNTRY" ] && echo "$COUNTRY" > "$VPN_CACHE_FILE"
        fi
        echo "VPN: ${COUNTRY:-Unknown}"
    else
        [ -f "$VPN_CACHE_FILE" ] && rm -f "$VPN_CACHE_FILE"
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
    TEXT="${REC:+$REC | }${VPN_STATUS:+$VPN_STATUS | }"

    echo "${TEXT}$DATE | CPU: $CPU | RAM: $RAM | VOL: $VOL_PADDED"

    sleep 1
done
