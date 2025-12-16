#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/logger.sh"

# Resolve absolute paths safely
LOG_FILE="$PROJECT_ROOT/$LOG_FILE"
REPORT_FILE="$PROJECT_ROOT/$REPORT_FILE"
BACKUP_DIR="$PROJECT_ROOT/$BACKUP_DIR"

# Create required directories
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$REPORT_FILE")"
mkdir -p "$BACKUP_DIR"


send_alert() {
    local msg="$1"

    [ "$ALERT_ENABLED" != true ] && return

    echo "$msg" | mail -s "Server Alert - $(hostname)" "$ALERT_EMAIL"

    log "Alert sent to [$ALERT_EMAIL] | Message: $msg"
}
