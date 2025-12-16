#!/bin/bash
source ../utils/common.sh

CPU=$(top -bn1 | awk '/Cpu/ {print 100-$8}' | cut -d. -f1)

if (( CPU > CPU_THRESHOLD )); then
    log "High CPU: $CPU%"
    send_alert "High CPU usage detected: $CPU%"
fi
