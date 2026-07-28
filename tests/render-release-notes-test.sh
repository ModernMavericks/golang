#!/bin/sh
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../build/render-release-notes.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
printf 'Go @VER@ note. See go@VER@ notes.\n' > "$tmp/_template.md"

# 1. renders when absent, substituting @VER@ with the upstream version
RELEASE_NOTES_DIR="$tmp" sh "$script" 1.26.5-mavericks.1
out="$tmp/1.26.5-mavericks.1.md"
[ -f "$out" ] || { echo "FAIL: note not created"; exit 1; }
grep -q 'Go 1.26.5 note' "$out" || { echo "FAIL: @VER@ not substituted"; cat "$out"; exit 1; }
grep -q '@VER@' "$out" && { echo "FAIL: placeholder left behind"; exit 1; }

# 2. no-op when the note already exists (does not overwrite)
printf 'HAND-WRITTEN\n' > "$out"
RELEASE_NOTES_DIR="$tmp" sh "$script" 1.26.5-mavericks.1
grep -q 'HAND-WRITTEN' "$out" || { echo "FAIL: overwrote existing note"; exit 1; }

echo "PASS: render-release-notes"
