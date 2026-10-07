#!/bin/bash

# Define paths
DISK_SCRIPT="scripts/disk_monitor.sh"
INODE_SCRIPT="scripts/inode_monitor.sh"
GROWTH_SCRIPT="scripts/storage_growth.sh"
ALERT_SCRIPT="scripts/alert.sh"
SUMMARY_REPORT="reports/storage_report.txt"

# Ensure log and report directories exist
mkdir -p reports logs

echo "========================================"
echo "    LINUX STORAGE MONITORING SYSTEM     "
echo "========================================"
echo "Running system checks..."

# 1. Execute sub-modules
[ -f "$DISK_SCRIPT" ] && bash "$DISK_SCRIPT"
[ -f "$INODE_SCRIPT" ] && bash "$INODE_SCRIPT"
[ -f "$GROWTH_SCRIPT" ] && bash "$GROWTH_SCRIPT"

echo ""
echo "----------------------------------------"
echo "          SYSTEM STATUS SUMMARY         "
echo "----------------------------------------"

# 2. Check for WARNING or CRITICAL statuses in generated reports
ALERTS_FOUND=0

if [ -f "reports/disk_report.txt" ]; then
    if grep -q "CRITICAL" reports/disk_report.txt; then
        bash "$ALERT_SCRIPT" "CRITICAL" "High Disk Space Usage detected!"
        ALERTS_FOUND=1
    elif grep -q "WARNING" reports/disk_report.txt; then
        bash "$ALERT_SCRIPT" "WARNING" "Disk Space Usage above warning threshold!"
        ALERTS_FOUND=1
    fi
fi

if [ -f "reports/inode_report.txt" ]; then
    if grep -q "CRITICAL" reports/inode_report.txt; then
        bash "$ALERT_SCRIPT" "CRITICAL" "High Inode Usage detected!"
        ALERTS_FOUND=1
    elif grep -q "WARNING" reports/inode_report.txt; then
        bash "$ALERT_SCRIPT" "WARNING" "Inode Usage above warning threshold!"
        ALERTS_FOUND=1
    fi
fi

if [ $ALERTS_FOUND -eq 0 ]; then
    bash "$ALERT_SCRIPT" "INFO" "All storage subsystems operating normally."
fi

# 3. Combine individual reports into a single consolidated report
echo "========================================" > "$SUMMARY_REPORT"
echo "      COMPLETE STORAGE SYSTEM REPORT    " >> "$SUMMARY_REPORT"
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$SUMMARY_REPORT"
echo "========================================" >> "$SUMMARY_REPORT"
echo "" >> "$SUMMARY_REPORT"

[ -f "reports/disk_report.txt" ] && cat reports/disk_report.txt >> "$SUMMARY_REPORT"
echo "" >> "$SUMMARY_REPORT"
[ -f "reports/inode_report.txt" ] && cat reports/inode_report.txt >> "$SUMMARY_REPORT"
echo "" >> "$SUMMARY_REPORT"
[ -f "reports/growth_report.txt" ] && cat reports/growth_report.txt >> "$SUMMARY_REPORT"

echo "----------------------------------------"
echo "Full summary saved to: $SUMMARY_REPORT"
echo "System log updated: logs/storage_monitor.log"
echo "========================================"
