#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/logger.sh"

# Resolve absolute paths safely
LOG_FILE="$PROJECT_ROOT/$LOG_FILE"
REPORT_FILE="$PROJECT_ROOT/$REPORT_FILE"
BACKUP_DIR="$PROJECT_ROOT/$BACKUP_DIR"

send_alert() {
    local msg="$1"

    # Skip if alerts disabled
    [ "$ALERT_ENABLED" != true ] && return

    # Check if msg is empty
    if [ -z "$msg" ]; then
        msg="⚠️ Empty alert message"
    fi

    # msmtp config based on user
    local msmtp_config="$HOME/.msmtprc"
    [ "$EUID" -eq 0 ] && msmtp_config="/root/.msmtprc"

    # Send email
    echo "$msg" | msmtp --file="$msmtp_config" "$ALERT_EMAIL"

    # Log the alert
    log "Alert sent to [$ALERT_EMAIL] | Message: $msg"
}
