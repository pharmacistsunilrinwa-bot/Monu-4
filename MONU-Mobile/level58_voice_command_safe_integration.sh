#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
VOICE_INPUT="$BASE/feature/voice/MONUVoiceInputEngine.kt"
BACKUP=".monu-backups/level58"
LOG=".monu-logs/level58"

echo "================================================"
echo " MONU MOBILE - LEVEL 58"
echo " SAFE VOICE COMMAND INTEGRATION"
echo " NO APK BUILD"
echo "================================================"

mkdir -p "$BACKUP" "$LOG"

echo
echo "[1/7] Verifying Level 57 prerequisites..."

test -f "$CHAT"
test -f "$VOICE_INPUT"

grep -q 'fun startListening' "$VOICE_INPUT"
grep -q 'onResult' "$VOICE_INPUT"
grep -q 'CommandInput' "$CHAT"

echo "[OK] Voice input engine ready"
echo "[OK] Existing chat pipeline found"

echo
echo "[2/7] Creating Level 58 backup..."

cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"

echo "[OK] ChatScreen backup preserved"

echo
echo "[3/7] Extracting exact ChatScreen structure..."

grep -n \
    -E 'fun ChatScreen|CommandInput|val ownerMessage|val systemMessage|val monuMessage|messages.add|messages =|scope.launch' \
    "$CHAT" \
    > "$LOG/chat_pipeline_structure.txt" || true

cat "$LOG/chat_pipeline_structure.txt"

echo
echo "[4/7] Checking for existing voice input integration..."

if grep -q 'MONUVoiceInputEngine' "$CHAT"; then
    echo "[INFO] Voice input import/reference already exists"
else
    echo "[INFO] Voice input not yet connected"
fi

if grep -q 'startListening()' "$CHAT"; then
    echo "[INFO] Voice listening call already exists"
else
    echo "[INFO] Voice listening call not yet connected"
fi

echo
echo "[5/7] Preparing safe integration plan..."

cat > "$LOG/integration_plan.txt" <<'PLAN'
LEVEL 58 SAFE INTEGRATION PLAN

1. Preserve existing CommandInput pipeline.
2. Do not replace ChatScreen.
3. Reuse existing message state.
4. Reuse existing owner message creation.
5. Connect MONUVoiceInputEngine callback.
6. Voice recognized text must enter same command flow.
7. Keep voice lifecycle cleanup.
8. No duplicate ChatMessage pipeline.
PLAN

cat "$LOG/integration_plan.txt"

echo
echo "[6/7] Creating integration readiness audit..."

cat > level58_voice_integration_readiness_test.sh <<'AUDIT'
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
AUDIT

chmod +x level58_voice_integration_readiness_test.sh

echo
echo "[7/7] Running readiness test..."

./level58_voice_integration_readiness_test.sh

echo
echo "================================================"
echo " LEVEL 58 PREPARATION COMPLETE"
echo "================================================"
echo "✓ Existing ChatScreen preserved"
echo "✓ Backup created"
echo "✓ Exact command structure captured"
echo "✓ Existing pipeline identified"
echo "✓ Voice input prerequisites verified"
echo "✓ Safe integration plan saved"
echo
echo "CURRENT STATUS:"
echo "LEVEL 58 READY FOR TARGETED WIRING"
echo
echo "NEXT:"
echo "LEVEL 59 - WIRE VOICE RESULT INTO EXISTING CHAT PIPELINE"
echo "================================================"
