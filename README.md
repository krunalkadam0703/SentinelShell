# SentinelShell

SentinelShell is a modular **Linux security, monitoring, and backup automation toolkit** built with Bash. It monitors system health, detects unauthorized file access using `auditd`, analyzes SSH attacks, performs automated backups, and generates HTML/email reports. It is lightweight, config‑driven, and designed to be cron‑friendly.

---

## Features

### 🔍 System Health Monitoring
- **CPU Monitoring**: Monitors CPU usage and alerts when it exceeds the configured threshold
- **Memory Monitoring**: Tracks RAM usage and logs warnings for high memory consumption
- **Disk Monitoring**: Checks disk space across all filesystems and alerts on high usage
- **Service Monitoring**: Automatically monitors and restarts critical services (e.g., Docker) if they go down
- **Zombie Process Cleanup**: Detects and kills zombie processes automatically

### 🛡️ Security Monitoring
- **Unauthorized Access Detection**: Uses Linux `auditd` to monitor sensitive directories (`/etc`, `/root`, `/var/www`) for unauthorized read/write/access attempts
- **SSH Brute Force Analysis**: Analyzes `/var/log/auth.log` to identify top IP addresses attempting SSH brute force attacks
- **Permission Violation Tracking**: Logs all denied access attempts and generates violation reports

### 💾 Backup & Recovery
- **Automated Backups**: Creates compressed tar.gz backups of critical files and directories
- **Backup Rotation**: Automatically manages backup retention (keeps N most recent backups)
- **Configurable Sources**: Easy configuration of what to backup via `config/toolkit.conf`

### 📊 Reporting & Alerts
- **HTML Reports**: Generates beautiful HTML daily reports with system health, security events, and backup summaries
- **Email Alerts**: Sends email notifications for critical events and daily reports
- **Centralized Logging**: All events logged to a single log file with timestamps

---

## Directory Structure

```
SentinelShell/
├── orchestrator.sh          # Main runner script (call this from cron)
├── bin/                     # Individual monitoring scripts
│   ├── monitor_cpu.sh
│   ├── monitor_memory.sh
│   ├── monitor_disk.sh
│   ├── monitor_services.sh
│   ├── process_cleanup.sh
│   ├── analyze_logs.sh      # SSH brute force analysis
│   ├── permission_violation_monitor.sh  # Auditd monitoring
│   ├── backup.sh
│   ├── generate_report.sh
│   └── setup_audit_rules.sh # Initial auditd setup
├── config/
│   └── toolkit.conf         # Main configuration file
├── utils/
│   ├── common.sh           # Shared functions (alerts, logging)
│   └── logger.sh            # Logging utility
├── logs/                    # Generated log files
├── reports/                 # Generated reports (HTML, SSH analysis, etc.)
└── backups/                 # Backup archives
```

---

## Requirements

### Essential
- **OS**: Linux with `bash` (tested on Ubuntu, Debian, CentOS, RHEL)
- **Tools**: `awk`, `tar`, `df`, `free`, `systemctl`, `ps`, `grep`, `sort`, `uniq`, `top`

### Optional (for full functionality)
- **auditd**: For security violation monitoring (see setup below)
- **msmtp**: For email alerts and reports (see Gmail setup below)
- **cron/systemd**: For automated scheduling

---

## Step-by-Step Setup Guide

### 1. Installation

```bash
# Clone the repository
git clone <repo-url> SentinelShell
cd SentinelShell

# Make scripts executable
chmod +x orchestrator.sh bin/*.sh
```

### 2. Configuration Setup

Edit `config/toolkit.conf` to customize SentinelShell for your environment:

```bash
nano config/toolkit.conf
```

#### Key Configuration Options:

**System Thresholds** (adjust based on your system capacity):
```bash
CPU_THRESHOLD=80        # Alert if CPU usage exceeds 80%
MEM_THRESHOLD=85        # Alert if memory usage exceeds 85%
DISK_THRESHOLD=90       # Alert if disk usage exceeds 90%
```

**Services to Monitor** (space-separated list):
```bash
SERVICES="docker nginx mysql"  # Services to monitor and auto-restart
```

**Backup Configuration**:
```bash
BACKUP_SOURCES="/etc /home/user/important /var/www"  # Directories to backup
BACKUP_DIR="backups"                                  # Backup destination
BACKUP_KEEP=7                                         # Keep last 7 backups
```

**Logging & Reports**:
```bash
LOG_FILE="logs/monitor.log"              # Main log file
REPORT_FILE="reports/daily_report.html"  # HTML report location
```

**Alert Configuration**:
```bash
ALERT_ENABLED=true                                    # Enable/disable email alerts
ALERT_EMAIL="your-email@gmail.com"                   # Recipient email address
```

**Security Monitoring**:
```bash
SSH_LOG="/var/log/auth.log"              # SSH log file location
TOP_SSH_IPS=10                           # Top N IPs to report for brute force
AUDIT_ENABLED=true                       # Enable auditd monitoring
WATCH_PATHS="/etc /root /var/www"        # Directories to monitor (space-separated)
AUDIT_KEY="unauthorized_access"          # Audit rule key name
AUDIT_LOG="/var/log/audit/audit.log"     # Audit log location
```

**Save the configuration file** after making your changes.

### 3. Gmail Setup (Email Alerts & Reports)

SentinelShell uses `msmtp` to send email alerts and daily reports. Follow these steps to configure Gmail:

#### Step 3.1: Install msmtp

**On Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install msmtp msmtp-mta
```

**On CentOS/RHEL:**
```bash
sudo yum install msmtp
```

#### Step 3.2: Create Gmail App Password

1. Go to your Google Account: https://myaccount.google.com/
2. Navigate to **Security** → **2-Step Verification** (enable if not already enabled)
3. Go to **App passwords**: https://myaccount.google.com/apppasswords
4. Select **Mail** and **Other (Custom name)**
5. Enter "SentinelShell" as the name
6. Click **Generate**
7. **Copy the 16-character password** (you'll need this in the next step)

#### Step 3.3: Configure msmtp

Create the msmtp configuration file:

**For regular user:**
```bash
mkdir -p ~/.config/msmtp
nano ~/.msmtprc
```

**For root user (recommended for system monitoring):**
```bash
sudo nano /root/.msmtprc
```

**Add the following configuration** (replace with your Gmail address and app password):

```bash
# Gmail SMTP configuration for SentinelShell
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

# Gmail account
account        gmail
host           smtp.gmail.com
port           587
from           your-email@gmail.com
user           your-email@gmail.com
password       YOUR_16_CHAR_APP_PASSWORD

# Set default account
account default : gmail
```

**Important:**
- Replace `your-email@gmail.com` with your actual Gmail address (appears twice)
- Replace `YOUR_16_CHAR_APP_PASSWORD` with the 16-character app password from Step 3.2
- For root user, the file should be `/root/.msmtprc`

#### Step 3.4: Set Proper Permissions

```bash
# For regular user
chmod 600 ~/.msmtprc

# For root user
sudo chmod 600 /root/.msmtprc
```

#### Step 3.5: Test Email Configuration

Test the email setup:

```bash
# For regular user
echo "Test email from SentinelShell" | msmtp your-email@gmail.com

# For root user
echo "Test email from SentinelShell" | sudo msmtp your-email@gmail.com
```

Check your inbox. If you receive the email, the configuration is correct!

#### Step 3.6: Update Configuration File

Ensure `config/toolkit.conf` has:
```bash
ALERT_ENABLED=true
ALERT_EMAIL="your-email@gmail.com"  # Same email as in .msmtprc
```

### 4. Security Violation Monitoring Setup (auditd)

SentinelShell can monitor unauthorized file access using Linux `auditd`. Follow these steps:

#### Step 4.1: Install and Enable auditd

**On Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install auditd audispd-plugins
sudo systemctl enable auditd
sudo systemctl start auditd
```

**On CentOS/RHEL:**
```bash
sudo yum install audit
sudo systemctl enable auditd
sudo systemctl start auditd
```

#### Step 4.2: Verify auditd is Running

```bash
sudo systemctl status auditd
```

You should see `active (running)` status.

#### Step 4.3: Configure SentinelShell Audit Rules

Edit `config/toolkit.conf` and ensure:
```bash
AUDIT_ENABLED=true
WATCH_PATHS="/etc /root /var/www"  # Add paths you want to monitor
AUDIT_KEY="unauthorized_access"
```

#### Step 4.4: Set Up Audit Rules

Run the setup script (requires sudo/root):

```bash
sudo bash bin/setup_audit_rules.sh
```

This will create audit rules watching the paths specified in `WATCH_PATHS` for read, write, and attribute changes.

#### Step 4.5: Verify Audit Rules

Check that rules are active:
```bash
sudo auditctl -l
```

You should see entries like:
```
-w /etc -p rwa -k unauthorized_access
-w /root -p rwa -k unauthorized_access
-w /var/www -p rwa -k unauthorized_access
```

#### Step 4.6: Test Security Monitoring

Test the monitoring by attempting to access a monitored file:
```bash
sudo cat /etc/shadow  # This should trigger an audit event
```

Check the violation report:
```bash
cat reports/permission_violations.txt
```

#### Step 4.7: Make Audit Rules Persistent (Optional)

To make audit rules persist across reboots, add them to `/etc/audit/rules.d/`:

```bash
sudo nano /etc/audit/rules.d/sentinelshell.rules
```

Add:
```
-w /etc -p rwa -k unauthorized_access
-w /root -p rwa -k unauthorized_access
-w /var/www -p rwa -k unauthorized_access
```

Restart auditd:
```bash
sudo systemctl restart auditd
```

---

## Usage

### Manual Execution

Run SentinelShell once manually (useful for testing):

```bash
cd /path/to/SentinelShell
./orchestrator.sh
```

Check the output:
- Logs: `logs/monitor.log`
- Reports: `reports/daily_report.html`
- SSH Analysis: `reports/ssh_bruteforce.txt`
- Permission Violations: `reports/permission_violations.txt`
- Backups: `backups/backup_YYYY-MM-DD_HH-MM.tar.gz`

### Automated Scheduling (Cron)

Schedule SentinelShell to run automatically:

```bash
# Edit crontab
crontab -e

# Add one of these lines (choose based on your needs):

# Run every 15 minutes
*/15 * * * * /path/to/SentinelShell/orchestrator.sh >/dev/null 2>&1

# Run every hour
0 * * * * /path/to/SentinelShell/orchestrator.sh >/dev/null 2>&1

# Run daily at 2 AM
0 2 * * * /path/to/SentinelShell/orchestrator.sh >/dev/null 2>&1
```

**Note:** `orchestrator.sh` uses a lock file (`/var/lock/sentinelshell.lock`) to prevent overlapping runs.

### Systemd Timer (Alternative to Cron)

Create a systemd service and timer:

**Create service file:**
```bash
sudo nano /etc/systemd/system/sentinelshell.service
```

Add:
```ini
[Unit]
Description=SentinelShell Monitoring Toolkit

[Service]
Type=oneshot
ExecStart=/path/to/SentinelShell/orchestrator.sh
User=root
```

**Create timer file:**
```bash
sudo nano /etc/systemd/system/sentinelshell.timer
```

Add:
```ini
[Unit]
Description=Run SentinelShell every 15 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=15min

[Install]
WantedBy=timers.target
```

**Enable and start:**
```bash
sudo systemctl daemon-reload
sudo systemctl enable sentinelshell.timer
sudo systemctl start sentinelshell.timer
```

---

## Understanding the Reports

### HTML Daily Report (`reports/daily_report.html`)

The HTML report includes:
- **System Health**: Uptime and disk usage
- **Service Status**: Status of monitored services (active/inactive)
- **SSH Brute Force Attempts**: Top IP addresses attempting unauthorized SSH access
- **Permission Violations**: Unauthorized access attempts detected by auditd
- **Backup Summary**: List of recent backups
- **Recent Logs**: Last 20 log entries

Open the report in a web browser:
```bash
# On local machine
firefox reports/daily_report.html

# Or copy to a web server and access via browser
```

### SSH Brute Force Report (`reports/ssh_bruteforce.txt`)

Lists top IP addresses attempting SSH brute force attacks:
```
  45 192.168.1.100
  23 10.0.0.50
  12 203.0.113.42
```

### Permission Violations Report (`reports/permission_violations.txt`)

Contains auditd log entries for denied access attempts to monitored directories.

---

## Troubleshooting

### Email Not Sending

1. **Check msmtp configuration:**
   ```bash
   msmtp --version
   cat ~/.msmtprc  # or /root/.msmtprc
   ```

2. **Test email manually:**
   ```bash
   echo "Test" | msmtp your-email@gmail.com
   ```

3. **Check msmtp logs:**
   ```bash
   cat ~/.msmtp.log
   ```

4. **Verify Gmail app password:** Ensure you're using the 16-character app password, not your regular Gmail password.

### Audit Rules Not Working

1. **Check auditd status:**
   ```bash
   sudo systemctl status auditd
   ```

2. **Verify rules are loaded:**
   ```bash
   sudo auditctl -l
   ```

3. **Check audit logs:**
   ```bash
   sudo tail -f /var/log/audit/audit.log
   ```

4. **Re-run setup script:**
   ```bash
   sudo bash bin/setup_audit_rules.sh
   ```

### Scripts Not Executing

1. **Check file permissions:**
   ```bash
   ls -l orchestrator.sh bin/*.sh
   chmod +x orchestrator.sh bin/*.sh
   ```

2. **Check lock file:**
   ```bash
   ls -l /var/lock/sentinelshell.lock
   # If stuck, remove it: sudo rm /var/lock/sentinelshell.lock
   ```

3. **Run with bash explicitly:**
   ```bash
   bash orchestrator.sh
   ```

### High False Positives

Adjust thresholds in `config/toolkit.conf`:
- Increase `CPU_THRESHOLD`, `MEM_THRESHOLD`, `DISK_THRESHOLD` if alerts are too frequent
- Review `WATCH_PATHS` and remove paths that generate too much noise

---

## Security Considerations

- **File Permissions**: Ensure `config/toolkit.conf` and `.msmtprc` have restrictive permissions (600)
- **Sudo Access**: Some scripts require sudo/root access. Review scripts before running with elevated privileges
- **Email Credentials**: Never commit `.msmtprc` files with passwords to version control
- **Audit Logs**: Monitor audit log size; they can grow large over time
- **Backup Storage**: Ensure sufficient disk space for backups

---

## License

See [LICENSE](LICENSE) file for details.

---

## Disclaimer

SentinelShell is provided **as‑is, without warranty of any kind**. Review scripts and configuration before deploying to production, and test in a non‑critical environment first. The authors are not responsible for any damage or data loss resulting from the use of this software.
