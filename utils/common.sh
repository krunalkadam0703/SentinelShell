#!/bin/bash

#This script used for send alert via email when certain conditiions are raised.

source ../config/toolkit.conf
source logger.sh

send_alert(){
    local msg="$1"
    if ["$ALERTS_ENABLED" = true]; then
    echo "$msg"|mail -s "Server Alert - $(hostname)" "$ALERT_EMAIL"
    
    log "Alert sent: $msg"
    fi    
}