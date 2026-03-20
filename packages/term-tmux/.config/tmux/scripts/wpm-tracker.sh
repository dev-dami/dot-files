#!/usr/bin/env bash
# WPM tracker for tmux status bar

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/tmux-wpm"
mkdir -p "$STATE_DIR"

KEYSTROKES_FILE="$STATE_DIR/keystrokes"
WPM_FILE="$STATE_DIR/wpm"
LAST_UPDATE_FILE="$STATE_DIR/last_update"

# Initialize files if they don't exist
[ ! -f "$KEYSTROKES_FILE" ] && echo "0" > "$KEYSTROKES_FILE"
[ ! -f "$WPM_FILE" ] && echo "0" > "$WPM_FILE"
[ ! -f "$LAST_UPDATE_FILE" ] && date +%s > "$LAST_UPDATE_FILE"

# Read current values
keystrokes=$(cat "$KEYSTROKES_FILE" 2>/dev/null || echo 0)
last_update=$(cat "$LAST_UPDATE_FILE" 2>/dev/null || date +%s)
current_time=$(date +%s)

# Calculate time difference
time_diff=$((current_time - last_update))

# Reset counter every 60 seconds
if [ "$time_diff" -ge 60 ]; then
    # Calculate WPM (assuming 5 chars per word)
    wpm=$(( (keystrokes * 60) / (time_diff * 5) ))
    [ "$wpm" -gt 999 ] && wpm=999
    echo "$wpm" > "$WPM_FILE"
    echo "0" > "$KEYSTROKES_FILE"
    date +%s > "$LAST_UPDATE_FILE"
fi

# Return current WPM
cat "$WPM_FILE" 2>/dev/null || echo "0"
