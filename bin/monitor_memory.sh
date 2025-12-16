#!/bin/bash
source ../utils/common.sh

MEM=$(free | awk '/Mem/ {printf "%.0f", $3/$2*100}')

if (( MEM > MEM_THRESHOLD )); then
    log "High Memory: $MEM%"
    send_alert "High memory usage detected: $MEM%"
fi
