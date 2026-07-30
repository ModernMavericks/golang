#!/bin/sh
# Thin wrapper: the logic lives in shared-cmake (scripts/version.sh) so it cannot drift between repos.
# Every call site -- tests/version-test.sh, build/versions.sh, the release workflow, and a plain
# `sh build/version.sh auto` -- keeps working through this.
set -eu
SELF="$(cd "$(dirname "$0")" && pwd)"
MAVERICKS_ROOT="$(cd "$SELF/.." && pwd)"; export MAVERICKS_ROOT

# This repo ships parallel Go minor LINES (go126, and a future go127) as separate products, so the
# upstream version is per line rather than a single file at the root. Everything else -- the shared
# logic, the tag scan, the RELEASE decision -- is unchanged.
GO_LINE="${GO_LINE:-126}"
MAVERICKS_UPSTREAM_FILE="$MAVERICKS_ROOT/lines/$GO_LINE/UPSTREAM_VERSION"; export MAVERICKS_UPSTREAM_FILE
[ -f "$MAVERICKS_UPSTREAM_FILE" ] || { echo "version.sh: no such line: lines/$GO_LINE" >&2; exit 1; }

. "$SELF/msc.sh"
exec sh "$MSC/version.sh" "$@"
