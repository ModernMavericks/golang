#!/bin/sh
# Print a path to a GUARANTEED non-empty Sparkle release-notes file for a release.
# sign_and_appcast.sh rejects a missing OR empty notes file, so the appcast step must
# never hand it nothing. If release-notes/<TAG>.md exists and is non-empty, use it;
# otherwise generate a minimal default into a temp file and print THAT path.
#   usage: release-notes-file.sh <TAG> <FULL_VERSION>
set -eu
SELF="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SELF/.." && pwd)"
TAG="${1:?release-notes-file: TAG required}"
FULL="${2:?release-notes-file: FULL version required}"
notes="$REPO_ROOT/release-notes/${TAG}.md"
if [ -f "$notes" ] && [ -s "$notes" ]; then
  printf '%s\n' "$notes"
  exit 0
fi
up="${FULL%%-mavericks.*}"
tmp="$(mktemp -t mavgo-notes-XXXXXX)"
printf '## Mavericks Go %s (%s)\n\nAutomated release tracking upstream Go %s for Mac OS X 10.9 (Mavericks).\n' \
  "$up" "$TAG" "$up" > "$tmp"
printf '%s\n' "$tmp"
