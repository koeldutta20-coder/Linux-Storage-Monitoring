#!/bin/bash

# Configuration, Data, and Report File Paths
CONFIG_FILE="config/thresholds.conf"
HISTORY_FILE="data/storage_history.csv"
REPORT_FILE="reports/growth_report.txt"

# Ensure required directories exist
mkdir -p data reports

# Create CSV header if history file does not exist
if [ ! -f "$HISTORY_FILE" ]; then
    echo "Date,Timestamp,Filesystem,Used_GB" > "$HISTORY_FILE"
fi

# Load thresholds if available
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

CURRENT_DATE=$(date '+%Y-%m-%d')
CURRENT_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 1. Capture current disk usage in GB for root filesystem
# Uses POSIX output block size in 1G units
CURRENT_USED=$(df -BG -P / | awk 'NR==2 {print $3}' | tr -d 'G')

# Save current reading to history file
echo "${CURRENT_DATE},${CURRENT_TIMESTAMP},/,${CURRENT_USED}" >> "$HISTORY_FILE"

# 2. Retrieve previous reading from history file (excluding current record)
PREVIOUS_USED=$(awk -F',' 'NR>1 {print $4}' "$HISTORY_FILE" | tail -n 2 | head -n 1)

# Default previous usage if this is the first run
if [ -z "$PREVIOUS_USED" ]; then
    PREVIOUS_USED=$CURRENT_USED
fi

# Calculate growth
GROWTH=$((CURRENT_USED - PREVIOUS_USED))

# 3. Generate Growth Report
echo "========================================" > "$REPORT_FILE"
echo "        STORAGE GROWTH REPORT           " >> "$REPORT_FILE"
echo "Date: $CURRENT_TIMESTAMP" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "Root Filesystem (/):" >> "$REPORT_FILE"
echo "  Previous Usage : ${PREVIOUS_USED} GB" >> "$REPORT_FILE"
echo "  Current Usage  : ${CURRENT_USED} GB" >> "$REPORT_FILE"
echo "  Storage Growth : ${GROWTH} GB" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

if [ "$GROWTH" -gt 0 ]; then
    echo "Status: Storage grew by ${GROWTH} GB since last reading." >> "$REPORT_FILE"
elif [ "$GROWTH" -lt 0 ]; then
    echo "Status: Storage decreased by ${GROWTH#-} GB since last reading." >> "$REPORT_FILE"
else
    echo "Status: No change in storage usage." >> "$REPORT_FILE"
fi

echo "Growth Report generated: $REPORT_FILE"
