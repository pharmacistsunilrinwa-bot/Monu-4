#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
MANIFEST="app/src/main/AndroidManifest.xml"

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
echo " MONU MOBILE - LEVEL 65"
echo " VOICE SESSION ROBUSTNESS AUDIT"
echo " NO APK BUILD"
echo "================================================"

echo
echo "[1/8] Core session guards"
echo "------------------------------------------------"

check \
"$ENGINE" \
'private var listening = false' \
"Engine owns listening state"

check \
"$ENGINE" \
'if \(listening\) return' \
"Duplicate start is guarded"

check \
"$ENGINE" \
'updateListeningState\(true\)' \
"Listening activation uses central state"

check \
"$ENGINE" \
'updateListeningState\(false\)' \
"Listening deactivation uses central state"

echo
echo "[2/8] Permission failure safety"
echo "------------------------------------------------"

check \
"$ENGINE" \
'hasMicrophonePermission\(\)' \
"Engine checks permission"

check \
"$ENGINE" \
'Microphone permission is required' \
"Permission failure reports error"

check \
"$ENGINE" \
'onError\(' \
"Engine error callback exists"

check \
"$CHAT" \
'microphonePermissionLauncher' \
"Runtime permission launcher exists"

check \
"$CHAT" \
'Microphone permission was denied' \
"Permission denial reaches UI"

echo
echo "[3/8] Recognition completion safety"
echo "------------------------------------------------"

check \
"$ENGINE" \
'override fun onEndOfSpeech' \
"End-of-speech callback exists"

check \
"$ENGINE" \
'override fun onResults' \
"Final result callback exists"

check \
"$ENGINE" \
'override fun onError' \
"Recognition error callback exists"

check \
"$ENGINE" \
'updateListeningState\(false\)' \
"Completion path can deactivate listening"

check \
"$CHAT" \
'onListeningStateChanged = \{ isListening ->' \
"UI receives engine state"

echo
echo "[4/8] Stop and shutdown safety"
echo "------------------------------------------------"

check \
"$ENGINE" \
'fun stopListening' \
"Explicit stop capability exists"

check \
"$ENGINE" \
'speechRecognizer\?\.stopListening\(\)' \
"Recognizer receives stop command"

check \
"$ENGINE" \
'fun shutdown' \
"Shutdown capability exists"

check \
"$ENGINE" \
'speechRecognizer\?\.cancel\(\)' \
"Shutdown cancellation exists"

check \
"$ENGINE" \
'speechRecognizer\?\.destroy\(\)' \
"Recognizer destruction exists"

check \
"$ENGINE" \
'speechRecognizer = null' \
"Recognizer reference released"

echo
echo "[5/8] Callback-to-chat safety"
echo "------------------------------------------------"

check \
"$CHAT" \
'recognizedCommand\.trim\(\)' \
"Voice result normalized"

check \
"$CHAT" \
'cleanCommand\.isNotBlank\(\)' \
"Blank command rejected"

check \
"$CHAT" \
'role = MessageRole\.OWNER' \
"Voice command enters owner channel"

check \
"$CHAT" \
'knowledgeEngine\.search\(cleanCommand\)' \
"Voice command reaches knowledge engine"

check \
"$CHAT" \
'finally \{' \
"Async cleanup finally exists"

echo
echo "[6/8] UI session integrity"
echo "------------------------------------------------"

check \
"$CHAT" \
'if \(voiceListening\)' \
"Single state-driven Start/Stop decision"

check \
"$CHAT" \
'voiceInputEngine\.stopListening\(\)' \
"Stop button reaches engine"

check \
"$CHAT" \
'val microphoneGranted' \
"Start checks permission state"

check \
"$CHAT" \
'if \(microphoneGranted\)' \
"Permission branch exists"

check \
"$CHAT" \
'voiceInputStatus = ""' \
"Previous errors cleared before new session"

echo
echo "[7/8] Ownership and duplication audit"
echo "------------------------------------------------"

ENGINE_COUNT=$(grep -c \
'val voiceInputEngine = remember' \
"$CHAT" 2>/dev/null || true)

if [ "$ENGINE_COUNT" -eq 1 ]; then
    pass "Single voice engine owner"
else
    fail "Voice engine ownership count is $ENGINE_COUNT"
fi

START_COUNT=$(grep -c \
'voiceInputEngine.startListening()' \
"$CHAT" 2>/dev/null || true)

if [ "$START_COUNT" -le 2 ]; then
    pass "Start listening paths are controlled ($START_COUNT)"
else
    warn "Multiple start paths detected ($START_COUNT)"
fi

STOP_COUNT=$(grep -c \
'voiceInputEngine.stopListening()' \
"$CHAT" 2>/dev/null || true)

if [ "$STOP_COUNT" -eq 1 ]; then
    pass "Single explicit stop path"
else
    warn "Stop path count is $STOP_COUNT"
fi

SHUTDOWN_COUNT=$(grep -c \
'voiceInputEngine.shutdown()' \
"$CHAT" 2>/dev/null || true)

if [ "$SHUTDOWN_COUNT" -eq 1 ]; then
    pass "Single shutdown owner"
else
    fail "Voice shutdown ownership count is $SHUTDOWN_COUNT"
fi

echo
echo "[8/8] Critical placeholder audit"
echo "------------------------------------------------"

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$CHAT" \
"$ENGINE" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical voice placeholders"
else
    warn "Placeholder markers detected"
    echo "$PLACEHOLDERS"
fi

echo
echo "================================================"
echo " LEVEL 65 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 65 GOLDEN"
    echo "Voice session robustness architecture verified"
else
    echo "LEVEL 65 NEEDS TARGETED REPAIR"
    exit 1
fi
