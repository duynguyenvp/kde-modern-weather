#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="com.modernweather.widget"
RESTART_SHELL=true

for arg in "$@"; do
    case "$arg" in
        --no-restart)
            RESTART_SHELL=false
            ;;
        -h|--help)
            echo "Usage: $0 [--no-restart]"
            echo "  --no-restart  Upgrade widget files without restarting plasmashell"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Error: kpackagetool6 not found. This widget requires KDE Plasma 6." >&2
    exit 1
fi

if kpackagetool6 --type Plasma/Applet --show "$PLUGIN_ID" >/dev/null 2>&1; then
    echo "Updating $PLUGIN_ID from $SCRIPT_DIR..."
    kpackagetool6 --type Plasma/Applet --upgrade "$SCRIPT_DIR"
else
    echo "$PLUGIN_ID is not installed yet. Installing..."
    kpackagetool6 --type Plasma/Applet --install "$SCRIPT_DIR"
fi

if [ "$RESTART_SHELL" = true ]; then
    echo "Restarting plasmashell to apply changes..."
    if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
        systemctl --user restart plasma-plasmashell.service
    elif command -v kquitapp6 >/dev/null 2>&1 && command -v kstart >/dev/null 2>&1; then
        kquitapp6 plasmashell || true
        kstart plasmashell >/dev/null 2>&1 &
    else
        echo "Warning: Could not restart plasmashell automatically. Please log out/in or restart plasmashell manually."
    fi
fi

echo "Update complete!"
