#!/bin/bash

# Resolve script paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load configuration and common functions
source "$PROJECT_ROOT/config/toolkit.conf"
source "$PROJECT_ROOT/utils/common.sh"

# List of services to monitor (currently only Docker)
SERVICES="docker"

# Loop over services
for svc in $SERVICES; do
    if ! systemctl is-active --quiet $svc; then
        log "$svc is down. Restarting..."
        sudo systemctl restart $svc

    fi
done
