#!/data/data/com.termux/files/usr/bin/bash
set -u

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
ENGINE="app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceInputEngine.kt"

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
    local file="$1"
    local pattern="$2"
    local label="$3"

    if grep -qE "$pattern" "$file" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

echo "================================================"
echo " LEVEL 69 VOICE RUNTIME HEALTH TEST"
echo "================================================"

check \
"$ENGINE" \
'fun getRuntimeHealth\(\): String' \
"Engine runtime health function exists"

check \
"$ENGINE" \
'hasMicrophonePermission\(\)' \
"Health checks microphone permission"

check \
"$ENGINE" \
'isAvailable\(\)' \
"Health checks recognizer availability"

check \
"$ENGINE" \
'"Listening"' \
"Health reports listening state"

check \
"$ENGINE" \
'"Ready"' \
"Health reports ready state"

check \
"$CHAT" \
'var voiceRuntimeHealth by remember' \
"Chat stores runtime health"

check \
"$CHAT" \
'voiceInputEngine\.getRuntimeHealth\(\)' \
"Chat reads engine health"

check \
"$CHAT" \
'voiceRuntimeHealth =' \
"Health updates connected"

check \
"$CHAT" \
'onListeningStateChanged = \{ isListening ->' \
"State callback remains connected"

echo "================================================"
echo " LEVEL 69 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 69 GOLDEN"
else
    echo "LEVEL 69 NEEDS TARGETED REPAIR"
    exit 1
fi
