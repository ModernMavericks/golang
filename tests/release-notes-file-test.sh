#!/bin/sh
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../build/release-notes-file.sh"
repo="$(cd "$here/.." && pwd)"

# present: the committed note supplies the prose, but the returned path is a TEMP file -- the script
# appends a generated ingredient section, and must never edit a tracked file to do it.
committed="$repo/release-notes/1.26.4-mavericks.1.md"
before="$(git -C "$repo" hash-object "$committed")"
p="$(sh "$script" 1.26.4-mavericks.1 1.26.4-mavericks.1)"
case "$p" in */release-notes/*) echo "FAIL present should be temp: $p"; exit 1;; esac
[ -s "$p" ] || { echo "FAIL present empty"; exit 1; }
head -1 "$committed" > "$p.want"
head -1 "$p" > "$p.got"
cmp -s "$p.want" "$p.got" || { echo "FAIL committed prose not preserved"; cat "$p"; exit 1; }
after="$(git -C "$repo" hash-object "$committed")"
[ "$before" = "$after" ] || { echo "FAIL committed note was modified in place"; exit 1; }
rm -f "$p" "$p.want" "$p.got"

# absent: a non-empty default is generated to a TEMP file (not under release-notes/)
p2="$(sh "$script" 9.9.9-mavericks.1 9.9.9-mavericks.1)"
case "$p2" in */release-notes/*) echo "FAIL absent should be temp: $p2"; exit 1;; esac
[ -s "$p2" ] || { echo "FAIL generated empty"; exit 1; }
grep -q '9.9.9' "$p2" || { echo "FAIL generated missing version"; cat "$p2"; exit 1; }
rm -f "$p2"

# The logic now lives in shared-cmake and this is a thin wrapper, so a scripts dir without it is a
# broken environment, not a degraded one: fail loudly rather than quietly returning notes with no
# ingredient section. (The old per-repo copy warned and carried on; a warning nobody reads is how a
# release silently loses its section.)
empty="$(mktemp -d)"
if MSC_SCRIPTS="$empty" sh "$script" 9.9.9-mavericks.1 9.9.9-mavericks.1 >/dev/null 2>&1; then
  echo "FAIL a scripts dir without release-notes-file.sh must fail, not silently degrade"; exit 1
fi
rm -rf "$empty"

echo "PASS: release-notes-file"
