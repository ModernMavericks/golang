#!/bin/sh
set -eu
# Resolve the shared compat guard from mavericks-shared-cmake's INSTALLED location
# (via versions.sh's MSC_SCRIPTS resolver -- registry/prefix, not a sibling copy).
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/../build/versions.sh"
: "${MSC_SCRIPTS:?mavericks-shared-cmake not found; install it -- see its README}"
MAVERICKS_REQUIRE_DEFINED_SYMBOLS='_clock_gettime' sh "$MSC_SCRIPTS/assert_binary_compatible.sh" "$@"
