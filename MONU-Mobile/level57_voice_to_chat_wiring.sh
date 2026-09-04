#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
BACKUP=".monu-backups/level57"

echo "================================================"
echo " MONU MOBILE - LEVEL 57"
echo " VOICE INPUT -> CHAT COMMAND WIRING"
echo " NO APK BUILD"
echo "================================================"

mkdir -p "$BACKUP"

echo "[1/6] Checking prerequisites..."

test -f "$CHAT"
test -f "$ENGINE"

echo "[OK] ChatScreen found"
echo "[OK] MONUVoiceInputEngine found"

echo "[2/6] Backing up ChatScreen..."
cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"

echo "[3/6] Inspecting ChatScreen command architecture..."

echo
grep -nE \
'onSend|sendMessage|ChatMessage\(|CommandInput|remember' \
"$CHAT" | head -80 || true

echo
echo "[4/6] Creating integration audit..."

cat > level57_voice_chat_integration_audit.sh <<'AUDIT'
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
AUDIT

chmod +x level57_voice_chat_integration_audit.sh

echo "[5/6] Running pre-wiring audit..."
./level57_voice_chat_integration_audit.sh

echo "[6/6] Preserving exact integration map..."

mkdir -p .monu-logs

{
echo "LEVEL 57 INTEGRATION MAP"
echo "========================"
echo
echo "VOICE ENGINE:"
grep -nE 'class MONUVoiceInputEngine|fun startListening|fun stopListening|onResult' "$ENGINE"
echo
echo "CHAT PIPELINE:"
grep -nE 'CommandInput|ChatMessage\(|MessageRole\.OWNER|onSend' "$CHAT" | head -100
} > .monu-logs/level57_voice_chat_map.txt

echo
echo "================================================"
echo " LEVEL 57 PREPARATION COMPLETE"
echo "================================================"
echo "✓ Voice engine verified"
echo "✓ Chat command architecture verified"
echo "✓ ChatScreen backup preserved"
echo "✓ Exact integration map saved"
echo
echo "IMPORTANT:"
echo "No blind overwrite of ChatScreen was performed."
echo "Next level will wire voice into the EXISTING"
echo "chat command pipeline rather than replacing it."
echo
echo "NEXT: LEVEL 58 - SAFE VOICE COMMAND INTEGRATION"
echo "================================================"
