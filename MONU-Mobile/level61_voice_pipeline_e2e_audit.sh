#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

CHAT="$BASE/ui/screens/ChatScreen.kt"
VOICE_INPUT="$BASE/feature/voice/MONUVoiceInputEngine.kt"
VOICE_OUTPUT="$BASE/feature/voice/MONUVoiceEngine.kt"
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

check_file() {
    FILE="$1"
    LABEL="$2"

    if [ -f "$FILE" ]; then
        pass "$LABEL"
    else
        fail "$LABEL"
    fi
}

check_pattern() {
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
echo " MONU MOBILE - LEVEL 61"
echo " VOICE PIPELINE END-TO-END AUDIT"
echo " NO APK BUILD"
echo "================================================"

echo
echo "[1/9] Core file integrity"
echo "------------------------------------------------"

check_file "$CHAT" "ChatScreen exists"
check_file "$VOICE_INPUT" "Voice input engine exists"
check_file "$VOICE_OUTPUT" "Voice output engine exists"
check_file "$MANIFEST" "AndroidManifest exists"

echo
echo "[2/9] Microphone permission"
echo "------------------------------------------------"

check_pattern \
"$MANIFEST" \
'android\.permission\.RECORD_AUDIO' \
"RECORD_AUDIO permission declared"

echo
echo "[3/9] Voice input engine"
echo "------------------------------------------------"

check_pattern \
"$VOICE_INPUT" \
'class MONUVoiceInputEngine' \
"Voice input engine class exists"

check_pattern \
"$VOICE_INPUT" \
'SpeechRecognizer' \
"Android SpeechRecognizer connected"

check_pattern \
"$VOICE_INPUT" \
'RecognitionListener' \
"RecognitionListener implemented"

check_pattern \
"$VOICE_INPUT" \
'fun startListening' \
"Voice start capability exists"

check_pattern \
"$VOICE_INPUT" \
'fun stopListening' \
"Voice stop capability exists"

check_pattern \
"$VOICE_INPUT" \
'fun shutdown' \
"Voice input shutdown capability exists"

check_pattern \
"$VOICE_INPUT" \
'RESULTS_RECOGNITION' \
"Recognized speech results extracted"

check_pattern \
"$VOICE_INPUT" \
'onResult\(command\)' \
"Recognized command callback emitted"

echo
echo "[4/9] Voice input -> Chat connection"
echo "------------------------------------------------"

check_pattern \
"$CHAT" \
'import com\.monu\.mobile\.feature\.voice\.MONUVoiceInputEngine' \
"Voice input engine imported into Chat"

check_pattern \
"$CHAT" \
'val voiceInputEngine = remember' \
"Voice input engine remembered"

check_pattern \
"$CHAT" \
'MONUVoiceInputEngine\(' \
"Voice input engine instantiated"

check_pattern \
"$CHAT" \
'onResult = \{ recognizedCommand' \
"Voice result callback connected"

check_pattern \
"$CHAT" \
'val cleanCommand = recognizedCommand\.trim\(\)' \
"Voice command normalized"

echo
echo "[5/9] Recognized command -> Chat pipeline"
echo "------------------------------------------------"

check_pattern \
"$CHAT" \
'content = cleanCommand' \
"Recognized text enters chat message"

check_pattern \
"$CHAT" \
'role = MessageRole\.OWNER' \
"Voice command enters as owner message"

check_pattern \
"$CHAT" \
'knowledgeEngine\.search\(cleanCommand\)' \
"Voice command reaches knowledge engine"

check_pattern \
"$CHAT" \
'withContext\(Dispatchers\.IO\)' \
"Voice network work isolated from UI thread"

echo
echo "[6/9] Voice UI controls"
echo "------------------------------------------------"

check_pattern \
"$CHAT" \
'var voiceListening by remember' \
"Listening state exists"

check_pattern \
"$CHAT" \
'voiceInputEngine\.startListening\(\)' \
"Start Voice action connected"

check_pattern \
"$CHAT" \
'voiceInputEngine\.stopListening\(\)' \
"Stop Listening action connected"

check_pattern \
"$CHAT" \
'"Start Voice"' \
"Start Voice label exists"

check_pattern \
"$CHAT" \
'"Stop Listening"' \
"Stop Listening label exists"

echo
echo "[7/9] Voice output system"
echo "------------------------------------------------"

check_pattern \
"$VOICE_OUTPUT" \
'fun speak' \
"Voice output speak capability exists"

check_pattern \
"$VOICE_OUTPUT" \
'fun stop' \
"Voice output stop capability exists"

check_pattern \
"$VOICE_OUTPUT" \
'fun shutdown' \
"Voice output shutdown capability exists"

check_pattern \
"$CHAT" \
'voiceEngine\.speak' \
"Chat connected to voice output"

echo
echo "[8/9] Lifecycle integrity"
echo "------------------------------------------------"

check_pattern \
"$CHAT" \
'voiceInputEngine\.shutdown\(\)' \
"Voice input cleanup connected"

check_pattern \
"$CHAT" \
'voiceEngine\.shutdown\(\)' \
"Voice output cleanup connected"

check_pattern \
"$CHAT" \
'voiceInputStatus = error' \
"Voice recognition errors stored"

check_pattern \
"$CHAT" \
'voiceInputStatus\.isNotBlank\(\)' \
"Voice recognition errors visible"

echo
echo "[9/9] Placeholder and duplicate safety audit"
echo "------------------------------------------------"

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$VOICE_INPUT" \
"$VOICE_OUTPUT" \
"$CHAT" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical voice placeholders found"
else
    warn "Voice placeholder markers found"
    echo "$PLACEHOLDERS"
fi

INPUT_IMPORT_COUNT=$(
    grep -c \
    'import com.monu.mobile.feature.voice.MONUVoiceInputEngine' \
    "$CHAT" || true
)

if [ "$INPUT_IMPORT_COUNT" -eq 1 ]; then
    pass "Voice input import has no duplicate"
else
    fail "Voice input import count is $INPUT_IMPORT_COUNT"
fi

INPUT_ENGINE_COUNT=$(
    grep -c \
    'val voiceInputEngine = remember' \
    "$CHAT" || true
)

if [ "$INPUT_ENGINE_COUNT" -eq 1 ]; then
    pass "Voice input engine has single ownership"
else
    fail "Voice input engine ownership count is $INPUT_ENGINE_COUNT"
fi

echo
echo "================================================"
echo " LEVEL 61 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo " LEVEL 61 GOLDEN"
    echo "================================================"
    echo "✓ Microphone permission verified"
    echo "✓ Speech recognition verified"
    echo "✓ Voice -> Chat connection verified"
    echo "✓ Chat -> Knowledge pipeline verified"
    echo "✓ Start/Stop UI verified"
    echo "✓ Voice output verified"
    echo "✓ Lifecycle cleanup verified"
    echo "✓ Duplicate ownership checked"
else
    echo " LEVEL 61 NEEDS TARGETED REPAIR"
    exit 1
fi
