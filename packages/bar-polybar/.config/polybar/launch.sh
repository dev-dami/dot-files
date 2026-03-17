#!/usr/bin/env bash
set -euo pipefail

# Do not kill a running bar if this script is called from a non-X context.
if ! monitors="$(polybar --list-monitors 2>/dev/null)"; then
  exit 0
fi

monitor_default="$(printf '%s\n' "$monitors" | head -n1 | cut -d: -f1)"
[ -n "${monitor_default:-}" ] || exit 0

pkill -x polybar >/dev/null 2>&1 || true
while pgrep -x polybar >/dev/null 2>&1; do sleep 0.1; done

MONITOR="${MONITOR:-$monitor_default}"
MONITOR="$MONITOR" polybar main >/dev/null 2>&1 &
