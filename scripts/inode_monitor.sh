#!/bin/bash

# Configuration and Report File Paths
CONFIG_FILE="config/thresholds.conf"
REPORT_FILE="reports/inode_report.txt"

# Load thresholds from shared configuration if available
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    INODE_WARNING=80
    INODE_CRITICAL=90
fi

# Ensure reports directory exists
mkdir -p reports

# Generate Report Header
echo "========================================" > "$REPORT_FILE"
echo "        INODE UTILIZATION REPORT        " >> "$REPORT_FILE"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
printf "%-20s %-10s %-10s\n" "Mount Point" "IUse%" "Status" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

# Process inode metrics
df -i -P | awk 'NR>1 {print $1, $5, $6}' | while read -r fs usage mount; do
    # Filter out virtual / temporary filesystems
    if [[ "$fs" == *"tmpfs"* ]] || [[ "$fs" == "none" ]] || [[ "$mount" == "/dev"* ]]; then
        continue
    fi

    # Extract numerical percentage value
    iuse_num=${usage%\%}

    # Determine health status based on thresholds
    if [ "$iuse_num" -ge "$INODE_CRITICAL" ]; then
        status="CRITICAL"
    elif [ "$iuse_num" -ge "$INODE_WARNING" ]; then
        status="WARNING"
    else
        status="OK"
    fi

    printf "%-20s %-10s %-10s\n" "$mount" "$usage" "$status" >> "$REPORT_FILE"
done

echo "Inode Report generated: $REPORT_FILE"
