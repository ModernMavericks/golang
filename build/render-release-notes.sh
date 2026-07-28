#!/bin/sh
# Render release-notes/<full-version>.md from _template.md when absent (no-op if present).
# @VER@ in the template becomes the upstream Go version (the part before -mavericks.).
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
VER="${1:?usage: render-release-notes.sh <full-version, e.g. 1.26.5-mavericks.1>}"
dir="${RELEASE_NOTES_DIR:-$(cd "$here/.." && pwd)/release-notes}"
out="$dir/$VER.md"
if [ -f "$out" ]; then
  echo "release notes already present: $out"
  exit 0
fi
up=$(printf '%s' "$VER" | sed 's/-mavericks\..*//')
sed "s/@VER@/$up/g" "$dir/_template.md" > "$out"
echo "rendered $out"
