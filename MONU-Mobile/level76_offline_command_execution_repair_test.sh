#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
PARSER="$BASE/feature/offline/MONUOfflineCommandIntentParser.kt"

PASS=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

check() {
    local file="$1"
    local pattern="$2"
    local label="$3"

    if grep -qE "$pattern" "$file" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

echo "================================================"
echo " LEVEL 76 TARGETED REPAIR TEST"
echo "================================================"

check \
"$ROUTER" \
'fun canHandle\(command: String\): Boolean' \
"Router capability function exists"

check \
"$ROUTER" \
'intentParser\.parse\(command\)' \
"Capability detection uses intent parser"

check \
"$ROUTER" \
'intent != MONUOfflineCommandIntent\.UNKNOWN' \
"Capability detection rejects unknown intent"

check \
"$ROUTER" \
'fun handle\(command: String\): String' \
"Router execution function preserved"

check \
"$ROUTER" \
'when \(intentParser\.parse\(command\)\)' \
"Router intent dispatch preserved"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Unknown intent remains defined"

COUNT=$(grep -c \
'fun canHandle(command: String): Boolean' \
"$ROUTER" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single capability authority"
else
    fail "Capability function count is $COUNT"
fi

echo "================================================"
echo " LEVEL 76 TARGETED REPAIR RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 76 REPAIR GOLDEN"
else
    echo "LEVEL 76 REPAIR FAILED"
    exit 1
fi
