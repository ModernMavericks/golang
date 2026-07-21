#!/bin/sh
set -eu
cd "$(dirname "$0")/../.."
fail=0
if grep -ril pkgsrc patches build test 2>/dev/null | grep -v rename-check.sh | grep -q .; then
  echo "FAIL: 'pkgsrc' still present:"; grep -ril pkgsrc patches build test | grep -v rename-check.sh
  fail=1
fi
[ -f build/extract-patches.sh ] && { echo "FAIL: extract-patches.sh not removed"; fail=1; }
for f in patches/126/0007-root-keychainunion.patch patches/126/0008-root-keychainunion-darwin.patch patches/126/0009-root-keychainunion-test.patch; do
  [ -f "$f" ] || { echo "FAIL: missing $f"; fail=1; }
done
[ "$fail" = 0 ] && echo "rename-check OK"
exit $fail
