#!/data/data/com.termux/files/usr/bin/bash
set -u

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"

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
    local pattern="$1"
    local label="$2"

    if grep -qE "$pattern" "$CHAT" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

echo "================================================"
echo " LEVEL 71 OFFLINE COMMAND FALLBACK TEST"
echo "================================================"

check \
'fun buildOfflineCommandFallback' \
"Offline fallback builder exists"

check \
'fun handleOfflineCommand' \
"Offline command handler exists"

check \
'command\.trim\(\)\.lowercase\(\)' \
"Offline commands normalized"

check \
'normalized\.isBlank\(\)' \
"Blank command safety exists"

check \
'normalized\.contains\("hello"\)' \
"Local greeting command exists"

check \
'normalized\.contains\("help"\)' \
"Local help command exists"

check \
'normalized\.contains\("status"\)' \
"Local status command exists"

check \
'MONU offline runtime is ready' \
"Offline runtime response exists"

check \
'role = MessageRole\.ASSISTANT' \
"Offline response enters assistant channel"

check \
'handleOfflineCommand\(cleanCommand\)' \
"Fallback is connected to command flow"

COUNT=$(grep -c 'fun buildOfflineCommandFallback' "$CHAT" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single offline fallback authority"
else
    fail "Offline fallback authority count is $COUNT"
fi

echo "================================================"
echo " LEVEL 71 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 71 GOLDEN"
    echo "Basic offline command fallback verified"
else
    echo "LEVEL 71 NEEDS TARGETED REPAIR"
    exit 1
fi
