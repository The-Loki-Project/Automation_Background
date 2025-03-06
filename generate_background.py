import os
import subprocess
import datetime

# Define paths
HOME_DIR = os.path.expanduser("~")
BASE_DIR = os.path.join(HOME_DIR, "Automation", "Background")
GENERATED_DIR = os.path.join(BASE_DIR, "generated")
PROMPT_FILE = os.path.join(BASE_DIR, "prompt.txt")
LOG_FILE = os.path.join(BASE_DIR, "background_logs.txt")

# Ensure required directories and files exist
def setup_environment():
    os.makedirs(GENERATED_DIR, exist_ok=True)
    for file_path in [PROMPT_FILE, LOG_FILE]:
        if not os.path.exists(file_path):
            with open(file_path, "w") as f:
                if file_path == PROMPT_FILE:
                    f.write("Default prompt: A beautiful and inspiring landscape\n")

# Generate background image (Placeholder)
def generate_background():
    with open(PROMPT_FILE, "r") as f:
        prompts = f.readlines()

    today = datetime.datetime.now().strftime("%b-%d-%Y")
    prompt = next((line.split(": ", 1)[1] for line in prompts if line.startswith(today)), "Default: A scenic landscape")

    image_path = os.path.join(GENERATED_DIR, f"background_{today}.jpg")

    # Placeholder: Create an empty file for now
    subprocess.run(["touch", image_path])

    return image_path, prompt

# Set wallpaper using AppleScript
def set_wallpaper(image_path):
    script = f'tell application "System Events" to set picture of every desktop to POSIX file "{image_path}"'
    subprocess.run(["osascript", "-e", script])

# Log results
def log_event(message):
    with open(LOG_FILE, "a") as log:
        log.write(f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - {message}\n")

# Ask for feedback
def request_feedback():
    feedback = input("Do you like the new background? Provide feedback: ")
    today = datetime.datetime.now().strftime("%b-%d-%Y")
    with open(PROMPT_FILE, "a") as f:
        f.write(f"{today}: Feedback: {feedback}\n")

# Main execution
def main():
    setup_environment()

    try:
        image_path, prompt = generate_background()
        log_event(f"Generated image using prompt: {prompt}")

        set_wallpaper(image_path)
        log_event(f"Wallpaper set successfully: {image_path}")

        request_feedback()
    except Exception as e:
        log_event(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    main()