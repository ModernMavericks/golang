#!/bin/sh
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/versions.sh"
export COPYFILE_DISABLE=1
stage="$WORK/staging-cross"
test -x "$stage$CROSS_PREFIX/bin/go" || { echo "run build-cross.sh first" >&2; exit 1; }
test -x "$stage$CROSS_PREFIX/bin/mavericks-cross-clang" || { echo "FATAL: cross CC wrapper not staged" >&2; exit 1; }

out="$WORK/out"; mkdir -p "$out"
base="golang-go126-cross-${PKG_VERSION}-darwin-arm64"
pkg="$out/$base.pkg"

# Stage the modern Sparkle updater + shim + LaunchAgent + postinstall via the shared helper.
# Skipped if the cross updater isn't built.
: "${MSC_SCRIPTS:?mavericks-shared-cmake not found; install it -- see its README}"
UPD_APP="${UPD_APP:-/updater-cross/GoCrossUpdater.app}"
set --                                    # pkgbuild gets --scripts only when there IS a postinstall
if [ -d "$UPD_APP" ]; then
  scr="$out/pkg-scripts-cross"; rm -rf "$scr"; mkdir -p "$scr"
  sh "$MSC_SCRIPTS/stage_updater.sh" \
    --stage "$stage" \
    --app "$UPD_APP" \
    --app-dir "/Library/Application Support/ModernMavericks" \
    --agent-label dev.modernmavericks.golang.go126-cross-updatecheck \
    --scripts-out "$scr"
  set -- --scripts "$scr"
else
  echo ">> WARNING: no cross updater at $UPD_APP; packaging toolchain only" >&2
fi

find "$stage" -name '._*' -delete 2>/dev/null || true

# Plain product pkg -- NO 10.9.5 floor (this installs on modern macOS, arm64 host).
pkgbuild --root "$stage" --identifier dev.modernmavericks.golang.go126-cross --version "$PKG_VERSION" \
         "$@" --install-location / "$pkg"
# Provenance: input pins in build/versions.sh, output hash in the release's SHA256SUMS.
echo "$pkg"
