#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/common.sh"

[ "$AUDIT_ENABLED" != true ] && exit 0

for path in $WATCH_PATHS; do
    auditctl -w "$path" -p rwa -k "$AUDIT_KEY"
done

echo "Audit rules configured"
