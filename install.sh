#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="com.modernweather.widget"

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Error: kpackagetool6 not found. This widget requires KDE Plasma 6." >&2
    exit 1
fi

if kpackagetool6 --type Plasma/Applet --show "$PLUGIN_ID" >/dev/null 2>&1; then
    echo "Upgrading existing $PLUGIN_ID..."
    kpackagetool6 --type Plasma/Applet --upgrade "$SCRIPT_DIR"
else
    echo "Installing $PLUGIN_ID..."
    kpackagetool6 --type Plasma/Applet --install "$SCRIPT_DIR"
fi

echo "Done! Add 'Modern Weather' / 'Thời tiết hiện đại' to your panel or desktop."
