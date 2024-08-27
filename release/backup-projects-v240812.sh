#!/bin/bash

: '
 * Backs up the specified project directory to the backup directory using rsync.
 * 
 * This function uses rsync to copy the contents of the project directory to the
 * backup directory. It logs the output of the rsync command to a log file on
 * the desktop.
 * 
 * @param project The name of the project to be backed up.
 '

# The configure file
source "${HOME}/Documents/Programming/Bash/backup-projects-config-file-v240812.sh"

# Get current date in YYMMDD format
CURRENT_DATE=$(date "+%y%m%d")

# Create the full backup directory path
BACKUP_DIR="$BACKUP_BASE_DIR/$CURRENT_DATE"

# Create the backup directory
# mkdir -p "$BACKUP_DIR" # Make directories for backup including parents if needed
if ! mkdir -p "$BACKUP_DIR"; then
    echo "Error: Failed to create backup directory: $BACKUP_DIR. Exiting."
    exit 1
fi

# Maximum number of retries for a failed copy
MAX_RETRIES=3

# Function to backup a single project
backup_project() {
    local project="$1" # Get project name from function parameter
    local source_dir="$SOURCE_BASE_DIR/$project" # Construct source directory path
    local dest_dir="$BACKUP_DIR/$project" # Construct destination directory path
    local log_dir="${HOME}/Desktop/rsync_output.log" # Construct log file path
    
    echo "Backing up $project..."
    if [ -d "$source_dir" ]; then # Check if source directory exists using a test operator -d, if true then...
        mkdir -p "$dest_dir" # Create destination directory if it doesn't exist, including parents
        
        # Use rsync instead of cp for more robust copying with progress reporting etc
        rsync -av --timeout=60 "$source_dir" "$BACKUP_DIR" 2>&1 | tee "$log_dir"
        
        # Check rsync exit status
        if [ ${PIPESTATUS[0]} -eq 0 ]; then # Check status of last command in pipe (rsync)
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
for project in "${PROJECTS[@]}"; do # value in PROJECTS array assigned to project variable on each iteration
    echo "Starting backup of: $project" # print project name
    backup_project "$project" # call backup_project function passing project name
done

echo "All backups completed. Files copied to $BACKUP_DIR"
echo "Please check your log file for any error messages."
