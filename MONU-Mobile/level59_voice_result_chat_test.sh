#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"

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
    PATTERN="$1"
    LABEL="$2"

    if grep -qE "$PATTERN" "$CHAT"; then
        pass "$LABEL"
    else
        fail "$LABEL"
    fi
}

echo "================================================"
echo " LEVEL 59 VOICE -> CHAT INTEGRATION TEST"
echo "================================================"

check \
'import com\.monu\.mobile\.feature\.voice\.MONUVoiceInputEngine' \
"Voice input engine imported"

check \
'val voiceInputEngine = remember' \
"Voice input engine state created"

check \
'MONUVoiceInputEngine\(' \
"Voice input engine instantiated"

check \
'onResult = \{ recognizedCommand' \
"Voice recognition callback connected"

check \
'val cleanCommand = recognizedCommand\.trim\(\)' \
"Voice command normalized"

check \
'content = cleanCommand' \
"Recognized command enters message model"

check \
'MessageRole\.OWNER' \
"Voice command marked as owner message"

check \
'knowledgeEngine\.search\(cleanCommand\)' \
"Voice command enters knowledge pipeline"

check \
'withContext\(Dispatchers\.IO\)' \
"Voice command network work isolated"

check \
'voiceInputEngine\.shutdown\(\)' \
"Voice input lifecycle cleanup connected"

check \
'onError = \{ error' \
"Voice recognition errors captured"

check \
'voiceInputStatus = error' \
"Voice error state stored"

echo
echo "================================================"
echo " LEVEL 59 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 59 GOLDEN"
    echo "Voice Result -> Chat -> Knowledge pipeline verified"
else
    echo "LEVEL 59 NEEDS TARGETED REPAIR"
    exit 1
fi
