#!/bin/bash

# Configuration and Log File Paths
LOG_FILE="logs/storage_monitor.log"
mkdir -p logs

# Function to log and display alerts
send_alert() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_entry="[$timestamp] [$level] $message"

    # Append to log file
    echo "$log_entry" >> "$LOG_FILE"

    # Display on terminal with formatted status tags
    case "$level" in
        "CRITICAL")
            echo -e "\033[0;31m[CRITICAL ALERT]\033[0m $message"
            ;;
        "WARNING")
            echo -e "\033[0;33m[WARNING ALERT]\033[0m $message"
            ;;
        *)
            echo -e "\033[0;32m[INFO]\033[0m $message"
            ;;
    esac
}

# Check if arguments were passed
if [ "$#" -ge 2 ]; then
    send_alert "$1" "$2"
else
    echo "Usage: ./scripts/alert.sh <LEVEL: WARNING|CRITICAL|INFO> <MESSAGE>"
fi
