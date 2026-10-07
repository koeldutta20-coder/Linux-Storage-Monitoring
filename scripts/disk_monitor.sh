#!/bin/bash

# Configuration and Report File Paths
CONFIG_FILE="config/thresholds.conf"
REPORT_FILE="reports/disk_report.txt"

# Load thresholds from shared configuration if available
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    DISK_WARNING=80
    DISK_CRITICAL=90
fi

# Ensure reports directory exists
mkdir -p reports

# Generate Report Header
echo "========================================" > "$REPORT_FILE"
echo "        DISK UTILIZATION REPORT         " >> "$REPORT_FILE"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
printf "%-20s %-10s %-10s\n" "Mount Point" "Usage" "Status" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

# Process disk space metrics
df -h -P | awk 'NR>1 {print $1, $5, $6}' | while read -r fs usage mount; do
    # Filter out virtual / temporary filesystems
    if [[ "$fs" == *"tmpfs"* ]] || [[ "$fs" == "none" ]] || [[ "$mount" == "/dev"* ]]; then
        continue
    fi

    # Extract numerical percentage value
    use_num=${usage%\%}

    # Determine health status based on thresholds
    if [ "$use_num" -ge "$DISK_CRITICAL" ]; then
        status="CRITICAL"
    elif [ "$use_num" -ge "$DISK_WARNING" ]; then
        status="WARNING"
    else
        status="OK"
    fi

    printf "%-20s %-10s %-10s\n" "$mount" "$usage" "$status" >> "$REPORT_FILE"
done

echo "Disk Report generated: $REPORT_FILE"
