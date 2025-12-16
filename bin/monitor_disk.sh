#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/common.sh"

df -H | awk 'NR>1 {gsub("%","",$5); if($5>'"$DISK_THRESHOLD"') print $1,$5}' |
while read fs usage; do
    log "High Disk Usage on $fs: $usage%"

done
