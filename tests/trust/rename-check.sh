#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
fail=0
# Directories to scan. 'patches' became lines/<line>/patches and 'test' never existed -- a grep aimed
# at a missing directory checks nothing while still looking like a guard.
scan="lines build tests"
if grep -ril pkgsrc $scan 2>/dev/null | grep -v rename-check.sh | grep -q .; then
  echo "FAIL: 'pkgsrc' still present:"; grep -ril pkgsrc $scan | grep -v rename-check.sh
  fail=1
fi
[ -f build/extract-patches.sh ] && { echo "FAIL: extract-patches.sh not removed"; fail=1; }
# Patches live under lines/<line>/patches now: a Go minor line is a product, and each line owns its
# own patch set (with fallback to the newest lower line when a new one has none yet).
for f in lines/126/patches/0007-root-keychainunion.patch lines/126/patches/0008-root-keychainunion-darwin.patch lines/126/patches/0009-root-keychainunion-test.patch; do
  [ -f "$f" ] || { echo "FAIL: missing $f"; fail=1; }
done
[ "$fail" = 0 ] && echo "rename-check OK"
exit $fail
