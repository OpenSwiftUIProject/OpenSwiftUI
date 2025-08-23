#!/bin/bash

set -e

PLIST_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/org.openswiftuiproject.openswiftui.environment.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/org.openswiftuiproject.openswiftui.environment.plist"

mkdir -p "$HOME/Library/LaunchAgents"
cp "$PLIST_SRC" "$PLIST_DEST"
echo "Synced $PLIST_SRC to $PLIST_DEST"

# launchctl load $PLIST_DEST
