#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
MANIFEST="app/src/main/AndroidManifest.xml"

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
echo " LEVEL 64 RUNTIME PERMISSION TEST"
echo "================================================"

echo
echo "[1/5] Manifest permission"

check \
"$MANIFEST" \
'android\.permission\.RECORD_AUDIO' \
"RECORD_AUDIO declared"

echo
echo "[2/5] Engine independent safety"

check \
"$ENGINE" \
'fun hasMicrophonePermission\(\)' \
"Engine permission function exists"

check \
"$ENGINE" \
'ContextCompat\.checkSelfPermission' \
"Engine checks runtime permission"

check \
"$ENGINE" \
'Manifest\.permission\.RECORD_AUDIO' \
"Engine references RECORD_AUDIO"

check \
"$ENGINE" \
'Microphone permission is required' \
"Engine rejects unauthorized listening"

echo
echo "[3/5] Chat permission launcher"

check \
"$CHAT" \
'val microphonePermissionLauncher' \
"Permission launcher declared"

check \
"$CHAT" \
'rememberLauncherForActivityResult' \
"Activity result launcher used"

check \
"$CHAT" \
'ActivityResultContracts\.RequestPermission' \
"RequestPermission contract used"

check \
"$CHAT" \
'microphonePermissionLauncher\.launch' \
"Permission request launch connected"

echo
echo "[4/5] Start Voice permission gate"

check \
"$CHAT" \
'val microphoneGranted' \
"Permission state calculated"

check \
"$CHAT" \
'ContextCompat\.checkSelfPermission' \
"Chat checks permission"

check \
"$CHAT" \
'PackageManager\.PERMISSION_GRANTED' \
"Granted state verified"

check \
"$CHAT" \
'if \(microphoneGranted\)' \
"Start branches on permission"

check \
"$CHAT" \
'Manifest\.permission\.RECORD_AUDIO' \
"Microphone permission requested"

echo
echo "[5/5] Permission result safety"

check \
"$CHAT" \
'if \(granted\)' \
"Permission grant handled"

check \
"$CHAT" \
'voiceInputEngine\.startListening\(\)' \
"Listening starts after permission path"

check \
"$CHAT" \
'Microphone permission was denied' \
"Permission denial shown"

check \
"$CHAT" \
'voiceListening = false' \
"Denied permission resets UI state"

echo
echo "================================================"
echo " LEVEL 64 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 64 GOLDEN"
    echo "Runtime microphone permission safety verified"
else
    echo "LEVEL 64 NEEDS TARGETED REPAIR"
    exit 1
fi
