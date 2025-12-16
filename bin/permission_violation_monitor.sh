#!/bin/bash

# Get script and project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common functions/config using absolute paths
source "$PROJECT_ROOT/utils/common.sh"

# Exit if audit monitoring is disabled
[ "$AUDIT_ENABLED" != true ] && exit 0

REPORT="$PROJECT_ROOT/reports/permission_violations.txt"
> "$REPORT"

# Search for denied audit logs
ausearch -k "$AUDIT_KEY" | grep denied >> "$REPORT"

# Send alert if report is not empty
if [ -s "$REPORT" ]; then
    log "Unauthorized access detected"

$(tail -n 10 "$REPORT")"
fi
