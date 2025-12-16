#!/bin/bash

log() {
    local msg="$1"
    echo "$(date '+%F %T') | $msg" >> "$LOG_FILE"
}
