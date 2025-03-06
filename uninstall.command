#!/bin/zsh

# Define Paths
HOME_DIR="$HOME"
BASE_DIR="$HOME/Automation/Background"
PLIST_DEST="$HOME/Library/LaunchAgents/com.user.backgroundgen.plist"
UNINSTALL_LOG="$BASE_DIR/uninstall_logs.txt"

# Create uninstall log
echo "==== Uninstall Started at $(date) ====" > "$UNINSTALL_LOG"

# Function to log messages
log() {
    echo "$(date) - $1" | tee -a "$UNINSTALL_LOG"
}

# Check if LaunchAgent exists and unload it
if [[ -f "$PLIST_DEST" ]]; then
    log "Unloading LaunchAgent..."
    launchctl unload "$PLIST_DEST"
    rm "$PLIST_DEST"
    log "LaunchAgent removed."
else
    log "No LaunchAgent found, skipping."
fi

# Check if the main folder exists and delete it
if [[ -d "$BASE_DIR" ]]; then
    log "Removing background automation folder..."
    rm -rf "$BASE_DIR"
    log "Folder removed."
else
    log "No background folder found, skipping."
fi

log "Uninstall complete! The automated background changer has been removed."