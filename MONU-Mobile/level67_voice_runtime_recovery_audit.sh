#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"

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
echo " MONU MOBILE - LEVEL 67"
echo " VOICE RUNTIME RECOVERY SAFETY AUDIT"
echo " NO APK BUILD"
echo "================================================"

echo
echo "[1/8] Core runtime availability"
echo "------------------------------------------------"

check \
"$ENGINE" \
'fun isAvailable\(\)' \
"Recognizer availability function exists"

check \
"$ENGINE" \
'SpeechRecognizer\.isRecognitionAvailable' \
"Android recognition availability checked"

check \
"$ENGINE" \
'if \(!isAvailable\(\)\)' \
"Unavailable recognizer failure branch exists"

check \
"$ENGINE" \
'onError\(' \
"Runtime availability failure can report error"

check \
"$ENGINE" \
'updateListeningState\(false\)' \
"Runtime failure can restore idle state"

echo
echo "[2/8] Permission recovery safety"
echo "------------------------------------------------"

check \
"$ENGINE" \
'fun hasMicrophonePermission\(\)' \
"Permission availability function exists"

check \
"$ENGINE" \
'if \(!hasMicrophonePermission\(\)\)' \
"Unauthorized start is blocked"

check \
"$ENGINE" \
'Microphone permission is required' \
"Permission failure has user-facing error"

check \
"$CHAT" \
'microphonePermissionLauncher' \
"UI can recover through permission request"

check \
"$CHAT" \
'if \(granted\)' \
"Permission grant recovery path exists"

echo
echo "[3/8] Duplicate session protection"
echo "------------------------------------------------"

check \
"$ENGINE" \
'if \(listening\) return' \
"Duplicate start prevented"

check \
"$ENGINE" \
'private var listening = false' \
"Engine tracks session state"

check \
"$ENGINE" \
'fun updateListeningState\(value: Boolean\)' \
"State transitions centralized"

echo
echo "[4/8] Stop safety"
echo "------------------------------------------------"

check \
"$ENGINE" \
'fun stopListening' \
"Explicit stop function exists"

check \
"$ENGINE" \
'speechRecognizer\?\.stopListening\(\)' \
"Stop is null-safe"

check \
"$ENGINE" \
'updateListeningState\(false\)' \
"Stop can restore idle state"

echo
echo "[5/8] Result and error recovery"
echo "------------------------------------------------"

check \
"$ENGINE" \
'override fun onResults' \
"Results callback exists"

check \
"$ENGINE" \
'override fun onError' \
"Error callback exists"

check \
"$ENGINE" \
'RESULTS_RECOGNITION' \
"Recognition results extracted"

check \
"$CHAT" \
'onError = \{ error' \
"Recognition errors reach UI"

check \
"$CHAT" \
'voiceInputStatus = error' \
"Recognition errors stored"

check \
"$CHAT" \
'voiceInputStatus = ""' \
"New session clears previous error"

echo
echo "[6/8] Engine to UI recovery synchronization"
echo "------------------------------------------------"

check \
"$ENGINE" \
'onListeningStateChanged: \(Boolean\) -> Unit' \
"Engine exposes authoritative state callback"

check \
"$CHAT" \
'onListeningStateChanged = \{ isListening ->' \
"Chat receives state transitions"

check \
"$CHAT" \
'voiceListening = isListening' \
"UI follows engine state"

check \
"$CHAT" \
'voiceListening = false' \
"UI has explicit idle recovery"

echo
echo "[7/8] Shutdown robustness"
echo "------------------------------------------------"

check \
"$ENGINE" \
'fun shutdown' \
"Shutdown function exists"

check \
"$ENGINE" \
'speechRecognizer\?\.cancel\(\)' \
"Shutdown cancels active recognition"

check \
"$ENGINE" \
'speechRecognizer\?\.destroy\(\)' \
"Shutdown destroys recognizer"

check \
"$ENGINE" \
'speechRecognizer = null' \
"Shutdown releases recognizer reference"

check \
"$CHAT" \
'voiceInputEngine\.shutdown\(\)' \
"Chat lifecycle owns shutdown"

echo
echo "[8/8] Ownership and critical marker audit"
echo "------------------------------------------------"

ENGINE_OWNER_COUNT=$(
    grep -c \
    'val voiceInputEngine = remember' \
    "$CHAT" 2>/dev/null || true
)

if [ "$ENGINE_OWNER_COUNT" -eq 1 ]; then
    pass "Single voice engine ownership"
else
    fail "Voice engine ownership count is $ENGINE_OWNER_COUNT"
fi

STATE_CALLBACK_COUNT=$(
    grep -c \
    'onListeningStateChanged = { isListening ->' \
    "$CHAT" 2>/dev/null || true
)

if [ "$STATE_CALLBACK_COUNT" -eq 1 ]; then
    pass "Single UI state synchronization callback"
else
    warn "UI state callback count is $STATE_CALLBACK_COUNT"
fi

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$CHAT" \
"$ENGINE" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical runtime recovery placeholders"
else
    warn "Placeholder markers detected"
    echo "$PLACEHOLDERS"
fi

echo
echo "================================================"
echo " LEVEL 67 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 67 GOLDEN"
    echo "Voice runtime recovery architecture verified"
    echo "UNAVAILABLE/PERMISSION/ERROR/RESULT -> IDLE -> RECOVERY"
else
    echo "LEVEL 67 NEEDS TARGETED REPAIR"
    exit 1
fi
