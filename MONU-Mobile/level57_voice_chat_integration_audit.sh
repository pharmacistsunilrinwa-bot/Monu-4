#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"

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

echo "================================================"
echo " LEVEL 57 PRE-WIRING ARCHITECTURE AUDIT"
echo "================================================"

if [ -f "$CHAT" ]; then
    pass "ChatScreen exists"
else
    fail "ChatScreen missing"
fi

if [ -f "$ENGINE" ]; then
    pass "MONUVoiceInputEngine exists"
else
    fail "MONUVoiceInputEngine missing"
fi

grep -q 'MONUVoiceInputEngine' "$ENGINE" \
    && pass "Voice input engine declaration verified" \
    || fail "Voice input engine declaration missing"

grep -q 'fun startListening' "$ENGINE" \
    && pass "Voice start capability verified" \
    || fail "Voice start capability missing"

grep -q 'fun stopListening' "$ENGINE" \
    && pass "Voice stop capability verified" \
    || fail "Voice stop capability missing"

grep -q 'onResult' "$ENGINE" \
    && pass "Recognized command callback available" \
    || fail "Voice result callback missing"

grep -q 'CommandInput' "$CHAT" \
    && pass "Chat input component connected" \
    || fail "Chat input component missing"

grep -q 'ChatMessage(' "$CHAT" \
    && pass "Chat message creation detected" \
    || fail "Chat message creation missing"

grep -q 'role = MessageRole.OWNER' "$CHAT" \
    && pass "Owner command pipeline detected" \
    || fail "Owner command pipeline missing"

echo
echo "================================================"
echo " LEVEL 57 PRE-WIRING RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "ARCHITECTURE READY FOR SAFE VOICE WIRING"
else
    echo "STOP: FIX MISSING PREREQUISITES FIRST"
    exit 1
fi
