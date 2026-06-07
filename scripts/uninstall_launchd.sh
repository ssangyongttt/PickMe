#!/usr/bin/env bash
set -euo pipefail

PLIST_NAME="com.jsoh.pickme.maintenance.plist"
TARGET_PLIST="$HOME/Library/LaunchAgents/$PLIST_NAME"

if [[ -f "$TARGET_PLIST" ]]; then
  launchctl unload "$TARGET_PLIST" 2>/dev/null || true
  rm -f "$TARGET_PLIST"
fi

echo "Removed $TARGET_PLIST"
