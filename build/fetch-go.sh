#!/bin/sh
set -eu
. "$(cd "$(dirname "$0")" && pwd)/versions.sh"
mkdir -p "$WORK"
tarball="$WORK/go${GO_VERSION}.src.tar.gz"
[ -f "$tarball" ] || curl -fSL -o "$tarball" "$GO_SRC_URL"
got=$(shasum -a 512 "$tarball" | awk '{print $1}')
[ "$got" = "$GO_SRC_SHA512" ] || { echo "FATAL: go src SHA512 mismatch: got $got" >&2; exit 1; }
rm -rf "$WORK/go"
tar -C "$WORK" -xzf "$tarball"
test -f "$WORK/go/src/make.bash" || { echo "FATAL: unexpected archive layout" >&2; exit 1; }
echo "fetched + verified go${GO_VERSION} -> $WORK/go"
