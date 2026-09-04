#!/data/data/com.termux/files/usr/bin/bash
set -u

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"

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
    if grep -qE "$1" "$CHAT"; then
        pass "$2"
    else
        fail "$2"
    fi
}

echo "================================================"
echo " LEVEL 60 VOICE UI INTEGRATION TEST"
echo "================================================"

check 'var voiceListening by remember' \
"Voice listening state exists"

check 'Button\(' \
"Voice control button exists"

check 'voiceInputEngine\.startListening\(\)' \
"Voice start action connected"

check 'voiceInputEngine\.stopListening\(\)' \
"Voice stop action connected"

check 'voiceListening = true' \
"Listening state activates"

check 'voiceListening = false' \
"Listening state deactivates"

check '"Start Voice"' \
"Start Voice UI label exists"

check '"Stop Listening"' \
"Stop Listening UI label exists"

check 'voiceInputStatus\.isNotBlank\(\)' \
"Voice error status visible"

check 'voiceInputStatus = ""' \
"Voice error reset before listening"

check 'voiceInputEngine\.shutdown\(\)' \
"Voice lifecycle cleanup preserved"

echo
echo "================================================"
echo " LEVEL 60 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 60 GOLDEN"
else
    echo "LEVEL 60 NEEDS TARGETED REPAIR"
    exit 1
fi
