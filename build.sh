#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! command -v zip >/dev/null 2>&1; then
    echo "Error: 'zip' command not found. Please install zip first." >&2
    exit 1
fi

WIDGET_NAME="$(basename "$SCRIPT_DIR")"
VERSION="$(python3 -c 'import json; print(json.load(open("metadata.json")).get("KPlugin", {}).get("Version", "1.0.0"))' 2>/dev/null || echo "1.0.0")"
OUT_FILE="${1:-${WIDGET_NAME}-v${VERSION}.plasmoid}"

rm -f "$OUT_FILE"

zip -r "$OUT_FILE" . \
    -x "screenshot" \
    -x "screenshot/" \
    -x "screenshot/*" \
    -x "screenshots" \
    -x "screenshots/" \
    -x "screenshots/*" \
    -x ".git" \
    -x ".git/" \
    -x ".git/*" \
    -x ".gitignore" \
    -x ".DS_Store" \
    -x "*.sh" \
    -x "*.plasmoid" \
    -x "README*.md"

echo "Built: $SCRIPT_DIR/$OUT_FILE"
