#!/bin/bash

# Function to monitor CPU and memory usage
monitor_usage() {
    echo "===== CPU and Memory Usage ====="
    # CPU usage
    top -bn 1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "CPU Usage: " 100 - $1"%"}'

    # Memory usage
    free -h | awk '/^Mem:/ {print "Memory Usage: " $3 "/" $2 " (" $3/$2*100 "%)"}'

    echo "===== Top Consuming Processes ====="
    # Top consuming processes
    ps aux --sort=-%cpu,%mem | head -n 11
}

# Function to backup MySQL database
backup_mysql_db() {
    echo "===== MySQL Database Backup ====="
    DB_USER="your_db_user"
    DB_PASS="your_db_password"
    DB_NAME="your_database_name"
    BACKUP_DIR="/path/to/backup/directory"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql"

    # Perform backup
    mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE
    if [ $? -eq 0 ]; then
        echo "Backup successful: $BACKUP_FILE"
    else
        echo "Backup failed"
    fi
}

# Main script execution
monitor_usage
backup_mysql_db
