#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ID="com.modernweather.widget"
PLASMOID_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/plasmoids/$PLUGIN_ID"
RESTART_SHELL=false

for arg in "$@"; do
    case "$arg" in
        --restart)
            RESTART_SHELL=true
            ;;
        -h|--help)
            echo "Usage: $0 [--restart]"
            echo "  --restart  Restart plasmashell after uninstalling"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            exit 1
            ;;
    esac
done

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "Error: kpackagetool6 not found. This script requires KDE Plasma 6." >&2
    exit 1
fi

if kpackagetool6 --type Plasma/Applet --show "$PLUGIN_ID" >/dev/null 2>&1; then
    echo "Removing $PLUGIN_ID via kpackagetool6..."
    kpackagetool6 --type Plasma/Applet --remove "$PLUGIN_ID"
else
    echo "$PLUGIN_ID is not registered in kpackagetool6."
fi

if [ -d "$PLASMOID_DIR" ]; then
    echo "Cleaning residual directory: $PLASMOID_DIR"
    rm -rf "$PLASMOID_DIR"
fi

echo "Uninstalled $PLUGIN_ID completely."

if [ "$RESTART_SHELL" = true ]; then
    echo "Restarting plasmashell..."
    if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet plasma-plasmashell.service 2>/dev/null; then
        systemctl --user restart plasma-plasmashell.service
    elif command -v kquitapp6 >/dev/null 2>&1 && command -v kstart >/dev/null 2>&1; then
        kquitapp6 plasmashell || true
        kstart plasmashell >/dev/null 2>&1 &
    fi
else
    echo "Tip: Run '$0 --restart' or restart plasmashell to refresh your desktop."
fi
