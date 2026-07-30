#!/bin/sh
# Print a path to a GUARANTEED non-empty Sparkle release-notes file for a release, ending with a
# generated section naming which build ingredients changed since the previous release.
# sign_and_appcast.sh rejects a missing OR empty notes file, so the appcast step must never be handed
# nothing. A committed release-notes/<TAG>.md supplies the prose; otherwise a minimal default does.
# Either way the result is written to a TEMP file -- the committed note is never edited in place.
#   usage: release-notes-file.sh <TAG> <FULL_VERSION>
set -eu
SELF="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SELF/.." && pwd)"
TAG="${1:?release-notes-file: TAG required}"
FULL="${2:?release-notes-file: FULL version required}"
notes="$REPO_ROOT/release-notes/${TAG}.md"
up="${FULL%%-mavericks.*}"
tmp="$(mktemp -t mavgo-notes-XXXXXX)"

if [ -f "$notes" ] && [ -s "$notes" ]; then
  cat "$notes" > "$tmp"
else
  printf '## Mavericks Go %s (%s)\n\nAutomated release tracking upstream Go %s for Mac OS X 10.9 (Mavericks).\n' \
    "$up" "$TAG" "$up" > "$tmp"
fi

# Append which ingredients moved (the legacysupport shim pin, the vendored CA bundle) since the last
# release: a repackage exists to ship a new input, so the notes should name it. Prose must never fail
# a release, so every step here tolerates failure and simply contributes nothing.
. "$REPO_ROOT/build/versions.sh"        # exports MSC_SCRIPTS (installed shared-cmake scripts dir)
if [ ! -f "${MSC_SCRIPTS:-/nonexistent}/ingredient-notes.sh" ]; then
  # Tolerated, but never silent: a stale shared-cmake install (MSC_SCRIPTS resolves, scripts absent)
  # would otherwise drop the ingredient section from a release and leave no trace of why.
  echo "release-notes-file: no ingredient-notes.sh under '${MSC_SCRIPTS:-}' — notes will omit the" >&2
  echo "  build-ingredient section; update the installed mavericks-shared-cmake to restore it." >&2
else
  PREV="$(cd "$REPO_ROOT" && sh "$MSC_SCRIPTS/previous-release-tag.sh" "$TAG" 2>/dev/null || true)"
  PINS="$(cd "$REPO_ROOT" && sh "$MSC_SCRIPTS/ingredient-pins.sh" 2>/dev/null || true)"
  if [ -n "$PREV" ] && [ -n "$PINS" ]; then
    SECTION="$(cd "$REPO_ROOT" && sh "$MSC_SCRIPTS/ingredient-notes.sh" "$PREV" $PINS 2>/dev/null || true)"
    [ -z "$SECTION" ] || printf '\n%s\n' "$SECTION" >> "$tmp"
  fi
fi

printf '%s\n' "$tmp"
