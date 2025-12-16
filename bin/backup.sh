#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/common.sh"

mkdir -p "$BACKUP_DIR"
FILE="$BACKUP_DIR/backup_$(date '+%F_%H-%M').tar.gz"

tar -czf "$FILE" $BACKUP_SOURCES && log "Backup created $FILE" ||
send_alert "Backup failed on $(hostname)"

ls -1t "$BACKUP_DIR" | tail -n +$((BACKUP_KEEP+1)) | xargs -r rm
