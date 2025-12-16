#!/bin/bash
LOCK_FILE="/var/lock/sentinelshell.lock"

exec 200>"$LOCK_FILE"
flock -n 200 || exit 0


bash bin/monitor_cpu.sh
bash bin/monitor_memory.sh
bash bin/monitor_disk.sh
bash bin/monitor_services.sh
bash bin/process_cleanup.sh
bash bin/analyze_logs.sh
bash bin/permission_violation_monitor.sh
bash bin/backup.sh
bash bin/generate_report.sh
