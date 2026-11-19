#!/usr/bin/env bash
# check_test.sh — proves check.mjs: clean sample run, error capture with
# exit 1, no-flow fallback, and loud fast failure when Chromium is absent.
set -u
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TPL="$REPO_ROOT/hermes/templates/web-game"
CHECK="$TPL/check.mjs"
fail() { echo "FAIL: $1"; exit 1; }

[ -f "$CHECK" ] || fail "check.mjs does not exist"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# (a) sample template: exit 0, >=3 PNGs, report arrays empty
node "$CHECK" "$TPL" "$TMP/a" >"$TMP/a.log" 2>&1
rc=$?
[ "$rc" -eq 0 ] || fail "sample run expected exit 0, got $rc: $(tail -5 "$TMP/a.log")"
pngs=$(find "$TMP/a" -name '*.png' | wc -l)
[ "$pngs" -ge 3 ] || fail "expected >=3 screenshots, got $pngs"
node -e 'const r=require(process.argv[1]);const ok=["consoleErrors","pageErrors","failedRequests"].every(k=>Array.isArray(r[k])&&r[k].length===0);process.exit(ok?0:1)' "$TMP/a/report.json" \
  || fail "sample report.json error arrays not empty: $(cat "$TMP/a/report.json")"

# (b) fixture with console.error + failing fetch: exit 1, both captured
mkdir -p "$TMP/b"
cat > "$TMP/b/index.html" <<'EOF'
<!doctype html><html><body><script>
console.error("boom");
fetch("http://127.0.0.1:9/nope").catch(()=>{});
</script></body></html>
EOF
node "$CHECK" "$TMP/b" "$TMP/bout" >"$TMP/b.log" 2>&1
rc=$?
[ "$rc" -eq 1 ] || fail "error fixture expected exit 1, got $rc"
grep -q "boom" "$TMP/bout/report.json" || fail "console error 'boom' not in report"
grep -q "127.0.0.1:9/nope" "$TMP/bout/report.json" || fail "failed request URL not in report"

# (c) fixture without check-flow.mjs: boot+final shots, exit 0
mkdir -p "$TMP/c"
echo '<!doctype html><html><body><h1>ok</h1></body></html>' > "$TMP/c/index.html"
node "$CHECK" "$TMP/c" "$TMP/cout" >"$TMP/c.log" 2>&1
rc=$?
[ "$rc" -eq 0 ] || fail "no-flow fixture expected exit 0, got $rc: $(tail -5 "$TMP/c.log")"
pngs=$(find "$TMP/cout" -name '*.png' | wc -l)
[ "$pngs" -ge 2 ] || fail "no-flow fixture expected >=2 screenshots, got $pngs"

# (d) Chromium absent: exit 1 within 60s, clear launch-error message
mkdir -p "$TMP/empty-browsers"
start=$SECONDS
PLAYWRIGHT_BROWSERS_PATH="$TMP/empty-browsers" timeout 65 node "$CHECK" "$TMP/c" "$TMP/dout" >"$TMP/d.log" 2>&1
rc=$?
elapsed=$((SECONDS - start))
[ "$rc" -eq 1 ] || fail "missing-browser run expected exit 1, got $rc (elapsed ${elapsed}s)"
[ "$elapsed" -lt 60 ] || fail "missing-browser run took ${elapsed}s (must fail fast)"
grep -qiE "launch|chromium|executable" "$TMP/d.log" || fail "no clear launch-error message: $(cat "$TMP/d.log")"

echo "PASS: check_test (clean sample, error capture exit 1, no-flow fallback, missing-browser fast fail)"
