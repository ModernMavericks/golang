#!/bin/sh
# Sourced by build-native.sh AFTER LEGACY_A and SDK are known.
: "${LEGACY_A:?set LEGACY_A}"; : "${SDK:?set SDK}"; : "${WLU_SYMS:?set WLU_SYMS}"
: "${MACOS_MIN:=10.9}"
_wlu=""; for s in $WLU_SYMS; do _wlu="$_wlu -Wl,-U,$s"; done
SYSROOT="-isysroot $SDK -mmacosx-version-min=$MACOS_MIN"
GO_LEGACY_LDFLAGS="$SYSROOT $LEGACY_A$_wlu"
# Asymmetric quoting is REQUIRED (see MacPorts lang/go note; mavericks-tailscale
# memory/mavericks-go-build.md). The legacy flags contain spaces (-isysroot PATH
# -mmacosx-version-min ... ARCHIVE ...), and the three consumers parse differently:
#   CGO_LDFLAGS      : plain, passed to the C compiler       -> bare, no quoting
#   BOOT_GO_LDFLAGS  : one argv token straight to the link tool -> bare `-extldflags=...`
#   GO_LDFLAGS       : through go's quote-aware -ldflags parser -> LITERAL double-quotes
#   GO_BOOTSTRAP_LDFLAGS : go-command -ldflags, inner single-quotes (native/M5 only)
export CGO_CFLAGS="-g -O2 $SYSROOT"
export CGO_LDFLAGS="-g -O2 $GO_LEGACY_LDFLAGS"
export BOOT_GO_LDFLAGS="-extldflags=$GO_LEGACY_LDFLAGS"
export GO_LDFLAGS="\"-extldflags=$GO_LEGACY_LDFLAGS\""
export GO_BOOTSTRAP_LDFLAGS="-extldflags '$GO_LEGACY_LDFLAGS'"
export GO_EXTLINK_ENABLED=1
