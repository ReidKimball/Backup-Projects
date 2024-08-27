#!/bin/bash

# Base source directory
SOURCE_BASE_DIR="/Volumes/EOS_TEST" # give only the root folder where the projects live

# Base backup directory
BACKUP_BASE_DIR="/Volumes/EOS_TEST_BACKUPS" # give the root folder where you want dated backup folders to be created in

# Get current date in YYMMDD format
CURRENT_DATE=$(date "+%y%m%d")

# Create the full backup directory path
BACKUP_DIR="$BACKUP_BASE_DIR/$CURRENT_DATE"

# Create the backup directory
mkdir -p "$BACKUP_DIR"

# List of project folders to backup, give only the folder names of each Avid project
PROJECTS=("EOS Producers")

# Maximum number of retries for a failed copy
MAX_RETRIES=3

# Function to backup a single project
backup_project() {
    local project="$1"
    local source_dir="$SOURCE_BASE_DIR/$project"
    local dest_dir="$BACKUP_DIR/$project"
    local log_dir="${HOME}/Desktop/rsync_output.log"
    
    echo "Backing up $project..."
    if [ -d "$source_dir" ]; then
        mkdir -p "$dest_dir"
        
        # Use rsync instead of cp for more robust copying
        rsync -av --timeout=60 "$source_dir" "$BACKUP_DIR" 2>&1 | tee "$log_dir"
        
        # Check rsync exit status
        if [ ${PIPESTATUS[0]} -eq 0 ]; then
            echo "  Backup of $project completed successfully."
        else
            echo "  Errors occurred during backup of $project. Check your log file for details."
            echo "  You may want to retry the backup for this project."
        fi
    else
        echo "  Warning: $project directory not found. Skipping."
    fi
}

# Backup each project
for project in "${PROJECTS[@]}"; do
    backup_project "$project"
done

echo "All backups completed. Files copied to $BACKUP_DIR"
echo "Please check your log file for any error messages."