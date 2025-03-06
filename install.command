#!/bin/zsh

# Define Paths
HOME_DIR="$HOME"
BASE_DIR="$HOME/Automation/Background"
GENERATED_DIR="$BASE_DIR/generated"
PROMPT_FILE="$BASE_DIR/prompt.txt"
LOG_FILE="$BASE_DIR/background_logs.txt"
INSTALL_LOG="$BASE_DIR/install_logs.txt"
PYTHON_SCRIPT_SOURCE="./generate_background.py"
PYTHON_SCRIPT_DEST="$BASE_DIR/generate_background.py"
PLIST_SOURCE="./com.user.backgroundgen.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.user.backgroundgen.plist"

# Create log file
echo "==== Install Started at $(date) ====" >> "$INSTALL_LOG"

# Function to log messages
log() {
    echo "$(date) - $1" | tee -a "$INSTALL_LOG"
}

# Create directories if they don't exist
log "Checking folders..."
mkdir -p "$GENERATED_DIR"

# Copy Python script only if it doesn't exist
if [[ ! -f "$PYTHON_SCRIPT_DEST" ]]; then
    log "Copying Python script..."
    cp "$PYTHON_SCRIPT_SOURCE" "$PYTHON_SCRIPT_DEST" || { log "Error copying Python script"; exit 1; }
else
    log "Python script already exists, skipping copy."
fi

# Ensure permissions
log "Setting executable permissions for Python script..."
chmod +x "$PYTHON_SCRIPT_DEST"

# Ensure required files exist
log "Ensuring required files exist..."
[[ -f "$PROMPT_FILE" ]] || echo "Default prompt: A beautiful and inspiring landscape" > "$PROMPT_FILE"
[[ -f "$LOG_FILE" ]] || touch "$LOG_FILE"

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    log "Homebrew not found! Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { log "Failed to install Homebrew"; exit 1; }
else
    log "Homebrew is already installed, skipping."
fi

# Check if Python is installed via Homebrew
if ! brew list python &>/dev/null; then
    log "Python not found! Installing via Homebrew..."
    brew install python || { log "Failed to install Python"; exit 1; }
else
    log "Python is already installed, skipping."
fi

# If launch agent already exists, unload it first to avoid errors
if [[ -f "$PLIST_DEST" ]]; then
    log "LaunchAgent already exists, unloading first..."
    launchctl unload "$PLIST_DEST"
else
    log "No existing LaunchAgent found, proceeding."
fi

# Copy LaunchAgent plist file
log "Copying LaunchAgent plist file..."
cp -f "$PLIST_SOURCE" "$PLIST_DEST"

# Load launchctl job
log "Loading launchctl..."
launchctl load "$PLIST_DEST" || { log "Failed to load launchctl agent"; exit 1; }

# RUN THE BACKGROUND GENERATION SCRIPT IMMEDIATELY
log "Running the script for the first time..."
/usr/bin/python3 "$PYTHON_SCRIPT_DEST" || log "Error: Failed to run generate_background.py"

log "Installation complete! The automated background changer is now active."