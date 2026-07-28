# mavericks-golang

Cross-builds a **patched Go 1.26.4 toolchain that installs and runs on Mac OS X 10.9
(Mavericks)** — with out-of-the-box cgo, keychain∪bundle verified TLS, and a Sparkle
auto-updater — entirely on modern hardware. No 10.9 build runner anywhere.

**Status:** built and proven end-to-end on real 10.9.5 hardware (`ultimate-hat`), and published to
GitHub Releases. Ships as `go126-<gover>-native-mavericks.<rev>.pkg` and
`go126-<gover>-cross-mavericks.<rev>.pkg` (native installs to `/usr/local/go126`).

## Build / release

- `sh build/build-native.sh` — **Rosetta-free**: fetch go1.26.4 → apply `patches/126/` → build
  static macports-legacy-support → native arm64 `make.bash` builder → cross `go install cmd` for
  amd64 (via a build-time `-arch x86_64`/min-10.9 CC wrapper) → assemble amd64 GOROOT (local `WORK`).
  No amd64 code runs in the build path; Rosetta is only an optional post-build self-test.
- `sh build/package-pkg.sh` — stage the updater + LaunchAgent, wrap with the 10.9.5 floor →
  `.pkg` + tarball + `manifest/`.
- `MAVERICKS_HOST=ultimate-hat sh test/smoke-mavericks.sh [installer]` — on-box smoke.
- `sh test/trust/smoke-trust.sh` — TLS-trust acceptance (pinned LE endpoints).
- `.github/workflows/release.yml` — CI build → EdDSA-sign → appcast → Release. Three triggers: push
  to `main` (auto-cuts `<upstream>-mavericks.1` if unreleased), a `*-mavericks.*` tag, or
  `workflow_dispatch local_release=true`.
- Upstream Go version lives in `UPSTREAM_VERSION` (bare `x.y.z`, Renovate-managed). `build/version.sh
  <auto|local>` derives the full `<upstream>-mavericks.N` + a `RELEASE=yes/no` decision from
  existing `*-mavericks.*` tags: `auto` is `N=1`/`RELEASE=yes` for a new upstream (no tag yet),
  else current `N`/`RELEASE=no`; `local` (via `workflow_dispatch local_release`) is always
  `N=maxN+1`/`RELEASE=yes`. `VERSION` (the full string) is workflow-written and **gitignored** —
  never committed.
- Renovate auto-bumps `UPSTREAM_VERSION` for upstream Go **patch** releases and automerges the PR
  (`.github/renovate.json` customManager + `packageRules`, `ignoreTests: false` so automerge waits
  for a green build); minor/major Go bumps land as normal, non-automerged PRs for manual review.
- A push to `main` whose upstream has no release yet auto-cuts `<upstream>-mavericks.1` via
  `gh release create` in `release.yml` (no PAT — `gh` mints the tag itself). Don't also push a
  manual tag for that release; that re-triggers CI and rebuilds/republishes the same version.

## Non-obvious invariants (details in `memory/`)

- **Repo is on NFS — build on local disk** (`WORK` defaults to `~/.cache`). [[mavericks-golang-nfs-build-location]]
- **Every on-box `go build` links via the invisible `mavericks-clang` CC wrapper** (go.env). [[mavericks-go126-downstream-linking]]
- **The amd64 toolchain is cross-linked `-linkmode=external`** so pure-Go binaries (go/gofmt/tools)
  route through the min-10.9 CC wrapper — Go 1.26 internal-links them to a 12.0 floor otherwise.
  `link-recipe.sh` (the old `-extldflags`/`GO_EXTLINK_ENABLED` plumbing) is gone; the CC wrappers
  inject the shim directly. [[mavericks-go126-downstream-linking]]
- **Distrust acceptance uses LE's pinned `valid-isrgrootx1/x2` endpoints**, not public sites. [[mavericks-trust-test-endpoints]]
- **Sparkle updater + EdDSA keys** (private key = `SPARKLE_PRIVATE_KEY` secret). [[mavericks-go126-sparkle-updater]]
- **Renovate's Go patch auto-release trusts go.dev's feed-verified sha256** (`build/fetch-go.sh`,
  `build/go-src-sha256.sh`), not a pinned checksum, and requires no PAT/App token — deliberately,
  so don't add one.
- Apple `/usr/bin/clang` required for cgo/ObjC. Reuse `../mavericks-shared-cmake`; don't duplicate.

## Design docs

`docs/superpowers/specs/2026-07-18-*.md` (spec) and `docs/superpowers/plans/2026-07-18-*.md`
(implementation plan). The `2026-07-14` spec is the older umbrella vision.
