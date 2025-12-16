#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$PROJECT_ROOT/utils/common.sh"

mkdir -p "$PROJECT_ROOT/reports"

OUT_FILE="$PROJECT_ROOT/reports/ssh_bruteforce.txt"

grep "Failed password" /var/log/auth.log \
| awk '{print $(NF-3)}' \
| sort | uniq -c | sort -nr | head -n "$TOP_SSH_IPS" > "$OUT_FILE"

log "SSH brute force analysis completed → $OUT_FILE"
