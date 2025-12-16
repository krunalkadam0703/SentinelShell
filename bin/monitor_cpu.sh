#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/common.sh"

CPU=$(top -bn1 | awk '/Cpu/ {print 100-$8}' | cut -d. -f1)

if (( CPU > CPU_THRESHOLD )); then
    log "High CPU: $CPU%"
  
fi
