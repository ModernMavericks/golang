## Mavericks Go @VER@ (mavericks.1)

A modern **Go @VER@** toolchain patched to build and run on **Mac OS X 10.9 (Mavericks)**.

**This revision (mavericks.1):**
- Tracks **upstream Go @VER@** — the Mavericks patch set and build recipe are unchanged from the
  previous release; only the upstream Go version moved. Upstream notes:
  https://go.dev/doc/devel/release#go@VER@

- Installs to `/usr/local/go126`; add its `bin/` to your `PATH`.
- `go build` works out of the box, **cgo included** — the toolchain links the legacy runtime shim
  automatically, producing 10.9-safe binaries.
- Modern **verified TLS** on 10.9: the standard library verifies certificates against the system
  keychain (honoring distrust) unioned with a bundled current CA set.
- A background **Sparkle** updater checks daily for new releases.

Requires OS X 10.9.5 or later, Intel (x86_64).
