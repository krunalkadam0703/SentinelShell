#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/common.sh"

ZOMBIES=$(ps aux | awk '$8=="Z" {print $2}')

if [ -n "$ZOMBIES" ]; then
    log "Zombie processes: $ZOMBIES"
    kill -9 $ZOMBIES
    send_alert "Zombie processes killed: $ZOMBIES"
fi
