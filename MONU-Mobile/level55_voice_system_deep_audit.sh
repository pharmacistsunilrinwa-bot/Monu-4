#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

PASS=0
FAIL=0
WARN=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

warn() {
    echo "[WARN] $1"
    WARN=$((WARN + 1))
}

echo "================================================"
echo " MONU MOBILE - LEVEL 55"
echo " VOICE SYSTEM DEEP ARCHITECTURE AUDIT"
echo " NO APK BUILD"
echo "================================================"

echo
echo "[1/8] Voice-related source discovery"
echo "------------------------------------------------"

VOICE_FILES=$(find "$BASE" -type f \
    \( -name '*Voice*.kt' -o -name '*Speech*.kt' -o -name '*Audio*.kt' \) \
    2>/dev/null)

if [ -n "$VOICE_FILES" ]; then
    pass "Voice-related source files discovered"
    echo "$VOICE_FILES"
else
    fail "No voice-related source files found"
fi

echo
echo "[2/8] Core voice engine"
echo "------------------------------------------------"

ENGINE="$BASE/feature/voice/MONUVoiceEngine.kt"

if [ -f "$ENGINE" ]; then
    pass "MONUVoiceEngine exists"

    grep -q 'fun speak' "$ENGINE" \
        && pass "Voice speak capability exists" \
        || fail "Voice speak capability missing"

    grep -q 'fun stop' "$ENGINE" \
        && pass "Voice stop capability exists" \
        || fail "Voice stop capability missing"

    grep -q 'fun shutdown' "$ENGINE" \
        && pass "Voice shutdown lifecycle exists" \
        || fail "Voice shutdown missing"

else
    fail "MONUVoiceEngine missing"
fi

echo
echo "[3/8] Text-to-speech implementation"
echo "------------------------------------------------"

if grep -Rqi 'TextToSpeech' "$BASE"; then
    pass "Android TextToSpeech implementation detected"

    grep -RIn 'TextToSpeech' \
        "$BASE/feature/voice" \
        2>/dev/null | head -20
else
    warn "TextToSpeech implementation not detected"
fi

echo
echo "[4/8] Speech recognition discovery"
echo "------------------------------------------------"

if grep -RqiE \
'SpeechRecognizer|RecognizerIntent|RecognitionListener' \
"$BASE"; then

    pass "Speech recognition capability detected"

    grep -RInE \
    'SpeechRecognizer|RecognizerIntent|RecognitionListener' \
    "$BASE" 2>/dev/null | head -30

else
    warn "No speech recognition implementation detected"
    echo "INFO: Voice output may exist without voice input."
fi

echo
echo "[5/8] Chat voice integration"
echo "------------------------------------------------"

CHAT="$BASE/ui/screens/ChatScreen.kt"

grep -q 'MONUVoiceEngine' "$CHAT" \
    && pass "Chat connected to voice engine" \
    || fail "Chat voice engine connection missing"

grep -q 'voiceEngine.speak' "$CHAT" \
    && pass "Chat response listen action active" \
    || fail "Chat listen action missing"

grep -q 'voiceEngine.stop' "$CHAT" \
    && pass "Chat stop action active" \
    || fail "Chat stop action missing"

grep -q 'voiceEngine.shutdown' "$CHAT" \
    && pass "Chat voice lifecycle cleanup active" \
    || fail "Chat voice cleanup missing"

echo
echo "[6/8] Voice permissions audit"
echo "------------------------------------------------"

MANIFEST="app/src/main/AndroidManifest.xml"

if grep -q 'android.permission.RECORD_AUDIO' "$MANIFEST"; then
    pass "RECORD_AUDIO permission declared"
else
    warn "RECORD_AUDIO permission absent"
    echo "INFO: Required only for microphone input."
fi

echo
echo "[7/8] Voice destination audit"
echo "------------------------------------------------"

APP="$BASE/ui/MONUApp.kt"

grep -q 'MONUDestination.VOICE' "$APP" \
    && pass "VOICE destination exists" \
    || fail "VOICE destination missing"

grep -q 'FeatureScreen' "$APP" \
    && pass "VOICE currently has controlled UI route" \
    || fail "VOICE UI route missing"

echo
echo "[8/8] Voice placeholder audit"
echo "------------------------------------------------"

VOICE_PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$BASE/feature/voice" \
"$CHAT" \
2>/dev/null || true)

if [ -z "$VOICE_PLACEHOLDERS" ]; then
    pass "No critical voice placeholders found"
else
    warn "Voice placeholder markers found:"
    echo "$VOICE_PLACEHOLDERS"
fi

echo
echo "================================================"
echo " LEVEL 55 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo " LEVEL 55 VOICE ARCHITECTURE VERIFIED"
    echo "================================================"
    echo "✓ Voice engine inspected"
    echo "✓ TTS capability audited"
    echo "✓ Speech recognition status identified"
    echo "✓ Chat integration verified"
    echo "✓ Permission requirements checked"
    echo
    echo "NEXT: LEVEL 56 - REAL VOICE INPUT/COMMAND PIPELINE"
else
    echo " LEVEL 55 NEEDS TARGETED REPAIR"
    echo "Use exact audit output before changing voice files."
fi
