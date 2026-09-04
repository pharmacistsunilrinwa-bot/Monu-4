#!/data/data/com.termux/files/usr/bin/bash
set -u

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
ENGINE="app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceInputEngine.kt"

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
echo " LEVEL 70 VOICE RUNTIME HEALTH UI TEST"
echo "================================================"

check \
"$ENGINE" \
'fun getRuntimeHealth\(\): String' \
"Engine health provider exists"

check \
"$CHAT" \
'var voiceRuntimeHealth by remember' \
"Chat owns health state"

check \
"$CHAT" \
'voiceInputEngine\.getRuntimeHealth\(\)' \
"Chat reads engine health"

check \
"$CHAT" \
'text[[:space:]]*=[[:space:]]*voiceRuntimeHealth' \
"Runtime health is visible in UI"

check \
"$CHAT" \
'voiceRuntimeHealth[[:space:]]*=' \
"Runtime health update path exists"

check \
"$CHAT" \
'onListeningStateChanged = \{ isListening ->' \
"Engine state synchronization preserved"

COUNT=$(grep -cE 'text[[:space:]]*=[[:space:]]*voiceRuntimeHealth' "$CHAT" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single runtime health UI display"
else
    fail "Runtime health UI display count is $COUNT"
fi

echo "================================================"
echo " LEVEL 70 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 70 GOLDEN"
    echo "Voice runtime health is visible to the user"
else
    echo "LEVEL 70 NEEDS TARGETED REPAIR"
    exit 1
fi
