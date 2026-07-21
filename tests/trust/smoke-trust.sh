#!/bin/sh
# On-box trust smoke. Uses Let's Encrypt's PINNED single-root endpoints so the
# result is immune to CA-hierarchy churn (public sites like letsencrypt.org now
# dual-root via ISRG Root X2, so distrusting X1 alone no longer blocks them).
#
#   valid-isrgrootx2.letsencrypt.org  chains ONLY to ISRG Root X2  -> positive
#   valid-isrgrootx1.letsencrypt.org  chains ONLY to ISRG Root X1  -> distrust target
#
# Positive is fully automated. The distrust half is semi-manual (toggle ISRG
# Root X1 -> Never Trust in Keychain Access; scripted keychain writes wedge
# SecurityAgent -- see mavericks-tailscale ws1-keychain-enum-spike).
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/../../build/versions.sh"
: "${MAVERICKS_HOST:?set MAVERICKS_HOST}"

ssh "$MAVERICKS_HOST" "rm -rf /tmp/trust && mkdir -p /tmp/trust"
rsync -a "$here/verify_tls.go" "$MAVERICKS_HOST:/tmp/trust/"

run() { # url
  ssh "$MAVERICKS_HOST" "sh -c '
    unset HTTPS_PROXY HTTP_PROXY ALL_PROXY GODEBUG
    export PATH=$PREFIX/bin:\$PATH GOROOT=$PREFIX GOCACHE=/tmp/gctrust GOPATH=/tmp/gptrust
    cd /tmp/trust && (test -f go.mod || go mod init trust) >/dev/null 2>&1
    go run ./verify_tls.go $1
  '"
}

echo "== positive: valid-isrgrootx2 (must VERIFY) =="
out=$(run "https://valid-isrgrootx2.letsencrypt.org/")
echo "$out"
case "$out" in *"VERIFIED"*) ;; *) echo "FAIL: positive trust broken" >&2; exit 1;; esac

echo "== positive: valid-isrgrootx1 with X1 TRUSTED (must VERIFY) =="
out=$(run "https://valid-isrgrootx1.letsencrypt.org/")
echo "$out"
case "$out" in
  *"VERIFIED"*) echo "OK (X1 trusted -> verified)";;
  *"REJECTED"*) echo "NOTE: X1 is currently distrusted on the box -> this is the negative case";;
esac

cat <<'EOF'

-- Distrust acceptance (semi-manual) --
1. Keychain Access -> System keychain -> ISRG Root X1 -> Trust ->
   "When using this certificate: Never Trust" (authenticate as admin).
2. Re-run: this script's valid-isrgrootx1 line must flip to REJECTED
   ("certificate signed by unknown authority").
3. Restore: set ISRG Root X1 back to "Use System Defaults".
EOF
