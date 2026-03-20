#!/usr/bin/env bash
# Get shortened directory name for status bar

dir="${1:-.}"
home="$HOME"

# Replace home directory with ~
short_dir="${dir/#$home/~}"

# Limit length
if [ ${#short_dir} -gt 30 ]; then
    echo "...${short_dir: -27}"
else
    echo "$short_dir"
fi
