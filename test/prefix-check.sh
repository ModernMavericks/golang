#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
tracked=$(git ls-files build/versions.sh CMakeLists.txt .github/workflows/release.yml \
  scripts/resources/Welcome.html 'release-notes/*.md')
if printf '%s\n' $tracked | xargs grep -l '/usr/local/mavericks-go' 2>/dev/null | grep -q .; then
  echo "FAIL: old prefix still present in tracked files:"; printf '%s\n' $tracked | xargs grep -l '/usr/local/mavericks-go' 2>/dev/null
  exit 1
fi
# the otool self-link check must reference the new path, not the old bare fragment
grep -q "mavericks-go/go126" .github/workflows/release.yml && { echo "FAIL: bare 'mavericks-go/go126' fragment remains in release.yml"; exit 1; }
# sanity: versions.sh has the new prefixes
grep -q '^export PREFIX="/usr/local/go126"' build/versions.sh || { echo "FAIL: PREFIX not flattened"; exit 1; }
grep -q '^export CROSS_PREFIX="/usr/local/go126-cross"' build/versions.sh || { echo "FAIL: CROSS_PREFIX not flattened"; exit 1; }
echo "prefix-check OK"
