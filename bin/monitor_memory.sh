#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/common.sh"

MEM=$(free | awk '/Mem/ {printf "%.0f", $3/$2*100}')

if (( MEM > MEM_THRESHOLD )); then
    log "High Memory: $MEM%"
fi
