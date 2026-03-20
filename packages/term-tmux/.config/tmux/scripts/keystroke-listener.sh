#!/usr/bin/env bash
# Keystroke listener for WPM tracking

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/tmux-wpm"
mkdir -p "$STATE_DIR"

KEYSTROKES_FILE="$STATE_DIR/keystrokes"

# Initialize file if it doesn't exist
[ ! -f "$KEYSTROKES_FILE" ] && echo "0" > "$KEYSTROKES_FILE"

# Increment keystroke counter
current=$(cat "$KEYSTROKES_FILE" 2>/dev/null || echo 0)
echo $((current + 1)) > "$KEYSTROKES_FILE"
