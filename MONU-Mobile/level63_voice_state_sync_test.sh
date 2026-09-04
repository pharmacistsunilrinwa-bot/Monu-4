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
echo " LEVEL 63 VOICE STATE SYNC TEST"
echo "================================================"

echo
echo "[1/4] Engine callback architecture"

check \
"$ENGINE" \
'onListeningStateChanged: \(Boolean\) -> Unit' \
"Listening state callback declared"

check \
"$ENGINE" \
'fun updateListeningState\(value: Boolean\)' \
"Central state update function exists"

check \
"$ENGINE" \
'onListeningStateChanged\(value\)' \
"State callback emitted"

echo
echo "[2/4] Recognition lifecycle synchronization"

check \
"$ENGINE" \
'updateListeningState\(true\)' \
"Listening activation routed through central state"

check \
"$ENGINE" \
'updateListeningState\(false\)' \
"Listening deactivation routed through central state"

check \
"$ENGINE" \
'onEndOfSpeech' \
"End of speech lifecycle retained"

check \
"$ENGINE" \
'onError' \
"Error lifecycle retained"

check \
"$ENGINE" \
'onResults' \
"Results lifecycle retained"

echo
echo "[3/4] Chat UI synchronization"

check \
"$CHAT" \
'onListeningStateChanged = \{ isListening ->' \
"Chat receives engine listening state"

check \
"$CHAT" \
'voiceListening = isListening' \
"Compose state follows engine"

check \
"$CHAT" \
'voiceInputStatus = error' \
"Voice errors preserved"

check \
"$CHAT" \
'voiceListening = false' \
"Errors safely deactivate UI state"

echo
echo "[4/4] Ownership integrity"

check \
"$CHAT" \
'voiceInputEngine\.startListening\(\)' \
"Start action preserved"

check \
"$CHAT" \
'voiceInputEngine\.stopListening\(\)' \
"Stop action preserved"

check \
"$CHAT" \
'if \(voiceListening\)' \
"UI still uses synchronized state"

echo
echo "================================================"
echo " LEVEL 63 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 63 GOLDEN"
    echo "Voice engine is authoritative for listening state"
    echo "Compose UI automatically follows recognition lifecycle"
else
    echo "LEVEL 63 NEEDS TARGETED REPAIR"
    exit 1
fi
