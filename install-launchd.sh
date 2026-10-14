#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PLIST_SRC="$SCRIPT_DIR/launchd/com.longyun.shadowrocket-sync.plist.template"
PLIST_DST="$HOME/Library/LaunchAgents/com.longyun.shadowrocket-sync.plist"
LABEL="com.longyun.shadowrocket-sync"

[[ -f "$PLIST_SRC" ]] || { print -r -- "missing $PLIST_SRC"; exit 1; }

mkdir -p "$HOME/Library/LaunchAgents"
sed -e "s|__INSTALL_DIR__|$SCRIPT_DIR|g" -e "s|__HOME__|$HOME|g" "$PLIST_SRC" > "$PLIST_DST"

launchctl bootout "gui/$(id -u)" "$PLIST_DST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST"
print -r -- "installed: $PLIST_DST"
print -r -- "schedule: daily 09:10 → $SCRIPT_DIR/sync.sh"
print -r -- "check: launchctl list | grep $LABEL"
