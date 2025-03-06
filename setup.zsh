#!/bin/zsh

# Define Paths
HOME_DIR="$HOME"
BASE_DIR="$HOME/Automation/Background"
GENERATED_DIR="$BASE_DIR/generated"
PROMPT_FILE="$BASE_DIR/prompt.txt"
LOG_FILE="$BASE_DIR/background_logs.txt"
SETUP_LOG="$BASE_DIR/setup_logs.txt"
PYTHON_SCRIPT_SOURCE="./generate_background.py"
PYTHON_SCRIPT_DEST="$BASE_DIR/generate_background.py"
PLIST_SOURCE="./com.user.backgroundgen.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.user.backgroundgen.plist"

# Create log file
echo "==== Setup Started at $(date) ====" > "$SETUP_LOG"

# Function to log messages
log() {
    echo "$(date) - $1" | tee -a "$SETUP_LOG"
}

# Create directories
log "Creating necessary folders..."
mkdir -p "$GENERATED_DIR" || { log "Error creating directories"; exit 1; }

# Move Python script to correct directory
log "Moving Python script..."
mv "$PYTHON_SCRIPT_SOURCE" "$PYTHON_SCRIPT_DEST" || { log "Error moving Python script"; exit 1; }

# Set permissions for Python script
log "Setting executable permissions for Python script..."
chmod +x "$PYTHON_SCRIPT_DEST" || { log "Failed to set permissions"; exit 1; }

# Ensure required files exist
log "Ensuring required files exist..."
[[ -f "$PROMPT_FILE" ]] || echo "Default prompt: A beautiful and inspiring landscape" > "$PROMPT_FILE"
[[ -f "$LOG_FILE" ]] || touch "$LOG_FILE"

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    log "Homebrew not found! Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { log "Failed to install Homebrew"; exit 1; }
fi

# Check if Python is installed via Homebrew
if ! brew list python &>/dev/null; then
    log "Python not found! Installing via Homebrew..."
    brew install python || { log "Failed to install Python"; exit 1; }
fi

# Move LaunchAgent plist file
log "Moving LaunchAgent plist file..."
mv "$PLIST_SOURCE" "$PLIST_DEST" || { log "Error moving plist file"; exit 1; }

# Load launchctl job
log "Setting up launchctl..."
launchctl load "$PLIST_DEST" || { log "Failed to load launchctl agent"; exit 1; }

log "Setup complete! The automated background changer is now active."