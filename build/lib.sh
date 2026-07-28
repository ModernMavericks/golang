# build/lib.sh -- sourced helpers for the mavericks-golang build scripts. No side effects.
# Bare upstream Go version (x.y.z) from the committed UPSTREAM_VERSION file.
upstream_version() {
  tr -d '[:space:]' < "${REPO_ROOT:-.}/UPSTREAM_VERSION"
}
