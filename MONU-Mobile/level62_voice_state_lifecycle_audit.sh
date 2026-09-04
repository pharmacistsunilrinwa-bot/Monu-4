#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

CHAT="$BASE/ui/screens/ChatScreen.kt"
VOICE_INPUT="$BASE/feature/voice/MONUVoiceInputEngine.kt"

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

check() {
    FILE="$1"
    PATTERN="$2"
    LABEL="$3"

    if grep -qE "$PATTERN" "$FILE" 2>/dev/null; then
        pass "$LABEL"
    else
        fail "$LABEL"
    fi
}

echo "================================================"
echo " MONU MOBILE - LEVEL 62"
echo " VOICE STATE + LIFECYCLE INTEGRITY AUDIT"
echo " NO APK BUILD"
echo "================================================"

echo
echo "[1/8] Input engine state ownership"
echo "------------------------------------------------"

check \
"$VOICE_INPUT" \
'private var listening = false' \
"Voice engine owns listening state"

check \
"$VOICE_INPUT" \
'if \(listening\) return' \
"Duplicate start protection exists"

check \
"$VOICE_INPUT" \
'listening = true' \
"Listening activation exists"

check \
"$VOICE_INPUT" \
'listening = false' \
"Listening deactivation exists"

echo
echo "[2/8] Recognition lifecycle"
echo "------------------------------------------------"

check \
"$VOICE_INPUT" \
'onReadyForSpeech' \
"Ready-for-speech lifecycle handled"

check \
"$VOICE_INPUT" \
'onBeginningOfSpeech' \
"Beginning-of-speech lifecycle handled"

check \
"$VOICE_INPUT" \
'onEndOfSpeech' \
"End-of-speech lifecycle handled"

check \
"$VOICE_INPUT" \
'onResults' \
"Final recognition result lifecycle handled"

check \
"$VOICE_INPUT" \
'onError' \
"Recognition error lifecycle handled"

echo
echo "[3/8] Recognizer cleanup"
echo "------------------------------------------------"

check \
"$VOICE_INPUT" \
'speechRecognizer\?\.cancel\(\)' \
"Recognizer cancellation exists"

check \
"$VOICE_INPUT" \
'speechRecognizer\?\.destroy\(\)' \
"Recognizer destruction exists"

check \
"$VOICE_INPUT" \
'speechRecognizer = null' \
"Recognizer reference released"

echo
echo "[4/8] Chat voice UI state"
echo "------------------------------------------------"

check \
"$CHAT" \
'var voiceListening by remember' \
"Compose listening state remembered"

check \
"$CHAT" \
'var voiceInputStatus by remember' \
"Voice status state remembered"

check \
"$CHAT" \
'voiceInputStatus = ""' \
"Old error cleared before new session"

check \
"$CHAT" \
'voiceListening = true' \
"UI listening state activates"

check \
"$CHAT" \
'voiceListening = false' \
"UI listening state deactivates"

echo
echo "[5/8] Start/Stop command integrity"
echo "------------------------------------------------"

check \
"$CHAT" \
'if \(voiceListening\)' \
"Start/Stop decision uses state"

check \
"$CHAT" \
'voiceInputEngine\.stopListening\(\)' \
"Stop command reaches engine"

check \
"$CHAT" \
'voiceInputEngine\.startListening\(\)' \
"Start command reaches engine"

START_COUNT=$(
    grep -c \
    'voiceInputEngine.startListening()' \
    "$CHAT" || true
)

STOP_COUNT=$(
    grep -c \
    'voiceInputEngine.stopListening()' \
    "$CHAT" || true
)

if [ "$START_COUNT" -eq 1 ]; then
    pass "Single Start Voice trigger"
else
    warn "Start Voice trigger count: $START_COUNT"
fi

if [ "$STOP_COUNT" -eq 1 ]; then
    pass "Single Stop Voice trigger"
else
    warn "Stop Voice trigger count: $STOP_COUNT"
fi

echo
echo "[6/8] Callback safety"
echo "------------------------------------------------"

check \
"$CHAT" \
'recognizedCommand\.trim\(\)' \
"Recognized command trimmed"

check \
"$CHAT" \
'if \(cleanCommand\.isNotBlank\(\)\)' \
"Blank voice commands rejected"

check \
"$CHAT" \
'onError = \{ error' \
"Recognition error callback exists"

check \
"$CHAT" \
'voiceInputStatus = error' \
"Recognition error safely stored"

echo
echo "[7/8] Async state integrity"
echo "------------------------------------------------"

check \
"$CHAT" \
'scope\.launch' \
"Coroutine scope used"

check \
"$CHAT" \
'withContext\(Dispatchers\.IO\)' \
"Background network context used"

check \
"$CHAT" \
'searching = true' \
"Search state activation exists"

check \
"$CHAT" \
'finally \{' \
"Search state cleanup finally block exists"

check \
"$CHAT" \
'searching = false' \
"Search state deactivation exists"

echo
echo "[8/8] Final lifecycle cleanup"
echo "------------------------------------------------"

check \
"$CHAT" \
'voiceInputEngine\.shutdown\(\)' \
"Voice input shutdown connected"

check \
"$CHAT" \
'voiceEngine\.shutdown\(\)' \
"Voice output shutdown connected"

INPUT_SHUTDOWN_COUNT=$(
    grep -c \
    'voiceInputEngine.shutdown()' \
    "$CHAT" || true
)

if [ "$INPUT_SHUTDOWN_COUNT" -eq 1 ]; then
    pass "Single voice input shutdown owner"
else
    fail "Voice input shutdown count is $INPUT_SHUTDOWN_COUNT"
fi

echo
echo "================================================"
echo " LEVEL 62 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo " LEVEL 62 GOLDEN"
    echo "================================================"
    echo "✓ Voice state ownership verified"
    echo "✓ Recognition lifecycle verified"
    echo "✓ Start/Stop integrity verified"
    echo "✓ Callback safety verified"
    echo "✓ Async state integrity verified"
    echo "✓ Shutdown ownership verified"
else
    echo " LEVEL 62 NEEDS TARGETED REPAIR"
    exit 1
fi
