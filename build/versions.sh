#!/bin/sh
# Single source of truth for every pinned input. Sourced, not executed.
: "${REPO_ROOT:=$(cd "$(dirname "$0")/.." && pwd)}"
export REPO_ROOT
# Heavy build I/O (Go source tree, compiled toolchain) must live on a LOCAL
# disk: this repo is on an NFS mount (ap-juicer:/export/code/trees), where
# extracting Go's ~13k source files crawls. Default to the local cache; the
# durable bits (patches, scripts, manifests) stay in the NFS repo. Override
# with MAVERICKS_WORK. On CI, $HOME/.cache is a fine local path too.
export WORK="${MAVERICKS_WORK:-$HOME/.cache/mavericks-golang/work}"

# Package version, shaped like ../mavericks-swift's VERSION: <upstream>-mavericks.<rev>
# (e.g. 1.26.4-mavericks.1). Bump the -mavericks.N suffix for packaging-only
# re-releases (patch/recipe changes) independent of upstream Go. GO_VERSION is
# the upstream part, used to fetch source; keep GO_SRC_SHA512 in sync with it.
export PKG_VERSION="$(cat "$REPO_ROOT/VERSION")"
export GO_VERSION="${PKG_VERSION%%-mavericks.*}"
export GO_SRC_URL="https://go.dev/dl/go${GO_VERSION}.src.tar.gz"
export GO_SRC_SHA512="adacc6a34ad239d98277acd2ac8da867110da0b184dbbafb82e8a06d2b7fd23434f878a8a8cd550172c21bd31ac6391d01a0bd095c9f5c1250be66b459c8de88"

# The 10.9 legacy-support shim is fetched PREBUILT from the mavericks-legacysupport
# release (ModernMavericks/macports-legacy-support) — no from-source build here. Integrity is
# checked against the release's SHA256SUMS every run. Renovate bumps this pin via the
# shared preset's `# mavericks-legacysupport` customManager (unquoted, marker on the line).
export MLS_VERSION=1.5.2-mavericks.1   # mavericks-legacysupport

export PREFIX="/usr/local/go126"
export MACOS_MIN="10.9"

# Both products bake the SAME CA convention path into the std trust model: the
# NATIVE prefix's bundle dir. Native populates it; cross-built apps look there
# (a box with the native .pkg installed, or an app that drops/embeds its CA).
export NATIVE_PREFIX="/usr/local/go126"
export CROSS_PREFIX="/usr/local/go126-cross"
export CA_DIR="$NATIVE_PREFIX/etc/openssl"   # @SSLDIR@ substitution target (native == cross)

export WLU_SYMS="_SecTrustEvaluateWithError _SecTrustCopyCertificateChain _notify_is_valid_token _xpc_date_create_from_current"

# CA bundle: curl.se cacert.pem. CA_SHA256 is blessed (TOFU) in Task 5.
export CA_URL="https://curl.se/ca/cacert.pem"
export CA_SHA256="3ff344e30b9b1ed2971044eabb438a08f2e2245ddb5f8ab1a3ad8b63ab4eaf91"  # curl.se cacert.pem, Mozilla 2026-07-16

# mavericks-shared-cmake is a find_package package INSTALLED to a prefix and
# self-registered in CMake's user package registry -- it is NOT vendored or
# consumed from a sibling checkout. Resolve its installed scripts/ dir (for the
# shell callers: SDK fetch, compat guard, productbuild floor, signer, appcast):
#   1. $MAVERICKS_SHARED_SCRIPTS override, else
#   2. the user package registry entry (honors whatever --prefix it was installed to), else
#   3. a sibling checkout (dev-only fallback).
_mav_shared_scripts() {
  if [ -n "${MAVERICKS_SHARED_SCRIPTS:-}" ] && [ -d "$MAVERICKS_SHARED_SCRIPTS" ]; then
    printf '%s\n' "$MAVERICKS_SHARED_SCRIPTS"; return 0
  fi
  for _r in "$HOME/.cmake/packages/MavericksSharedCMake/"*; do
    [ -f "$_r" ] || continue
    _d="$(cat "$_r")/scripts"
    [ -d "$_d" ] && { printf '%s\n' "$_d"; return 0; }
  done
  [ -d "$REPO_ROOT/../mavericks-shared-cmake/scripts" ] && \
    { printf '%s\n' "$REPO_ROOT/../mavericks-shared-cmake/scripts"; return 0; }
  return 1
}
MSC_SCRIPTS="$(_mav_shared_scripts || true)"; export MSC_SCRIPTS
