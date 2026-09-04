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
echo " LEVEL 58 INTEGRATION READINESS TEST"
echo "================================================"

test -f "$CHAT" \
    && pass "ChatScreen exists" \
    || fail "ChatScreen missing"

test -f "$ENGINE" \
    && pass "Voice input engine exists" \
    || fail "Voice input engine missing"

grep -q 'CommandInput' "$CHAT" \
    && pass "Existing text command entry found" \
    || fail "Text command entry missing"

grep -q 'ChatMessage(' "$CHAT" \
    && pass "Existing message pipeline found" \
    || fail "Message pipeline missing"

grep -q 'MessageRole.OWNER' "$CHAT" \
    && pass "Owner command role found" \
    || fail "Owner command role missing"

grep -q 'MONUVoiceEngine' "$CHAT" \
    && pass "Existing voice output engine found" \
    || fail "Voice output engine missing"

grep -q 'voiceEngine.shutdown' "$CHAT" \
    && pass "Voice output lifecycle cleanup found" \
    || fail "Voice lifecycle cleanup missing"

grep -q 'fun startListening' "$ENGINE" \
    && pass "Voice input start available" \
    || fail "Voice input start missing"

grep -q 'fun stopListening' "$ENGINE" \
    && pass "Voice input stop available" \
    || fail "Voice input stop missing"

grep -q 'onResult' "$ENGINE" \
    && pass "Voice recognized text callback available" \
    || fail "Voice result callback missing"

echo
echo "================================================"
echo " LEVEL 58 READINESS RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 58 READY FOR EXACT SAFE WIRING"
else
    echo "LEVEL 58 BLOCKED - DO NOT MODIFY CHATSCREEN"
    exit 1
fi
