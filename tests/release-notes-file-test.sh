#!/bin/sh
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../build/release-notes-file.sh"

# present: an existing committed note is returned verbatim (read-only, non-destructive)
p="$(sh "$script" 1.26.4-mavericks.1 1.26.4-mavericks.1)"
case "$p" in */release-notes/1.26.4-mavericks.1.md) : ;; *) echo "FAIL present path: $p"; exit 1;; esac
[ -s "$p" ] || { echo "FAIL present empty"; exit 1; }

# absent: a non-empty default is generated to a TEMP file (not under release-notes/)
p2="$(sh "$script" 9.9.9-mavericks.1 9.9.9-mavericks.1)"
case "$p2" in */release-notes/*) echo "FAIL absent should be temp: $p2"; exit 1;; esac
[ -s "$p2" ] || { echo "FAIL generated empty"; exit 1; }
grep -q '9.9.9' "$p2" || { echo "FAIL generated missing version"; cat "$p2"; exit 1; }
rm -f "$p2"

echo "PASS: release-notes-file"
