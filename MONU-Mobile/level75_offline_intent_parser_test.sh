#!/data/data/com.termux/files/usr/bin/bash
set -u

PARSER="app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandIntentParser.kt"
ROUTER="app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandRouter.kt"

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
echo " LEVEL 75 OFFLINE INTENT PARSER TEST"
echo "================================================"

check \
"$PARSER" \
'enum class MONUOfflineCommandIntent' \
"Offline intent enum exists"

check \
"$PARSER" \
'class MONUOfflineCommandIntentParser' \
"Dedicated intent parser exists"

check \
"$PARSER" \
'fun parse\(command: String\)' \
"Intent parsing function exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.GREETING' \
"Greeting intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.HELP' \
"Help intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.STATUS' \
"Status intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.TIME' \
"Time intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.DATE' \
"Date intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Unknown intent fallback exists"

check \
"$ROUTER" \
'private val intentParser' \
"Router owns centralized intent parser"

check \
"$ROUTER" \
'intentParser\.parse\(command\)' \
"Router delegates capability detection to parser"

check \
"$ROUTER" \
'when \(intentParser\.parse\(command\)\)' \
"Router dispatches using parsed intent"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.TIME' \
"Time intent delegates through router"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Unknown intent remains safe"

PARSER_COUNT=$(grep -c \
'class MONUOfflineCommandIntentParser' \
"$PARSER" 2>/dev/null || true)

if [ "$PARSER_COUNT" -eq 1 ]; then
    pass "Single intent parser authority"
else
    fail "Intent parser authority count is $PARSER_COUNT"
fi

echo "================================================"
echo " LEVEL 75 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 75 GOLDEN"
    echo "Centralized offline intent parsing verified"
else
    echo "LEVEL 75 NEEDS TARGETED REPAIR"
    exit 1
fi
