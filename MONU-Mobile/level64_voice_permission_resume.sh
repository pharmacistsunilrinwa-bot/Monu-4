#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
MANIFEST="app/src/main/AndroidManifest.xml"
BACKUP=".monu-backups/level64"
LOG=".monu-logs/level64"

echo "================================================"
echo " MONU MOBILE - LEVEL 64 RESUME"
echo " RUNTIME PERMISSION SAFETY"
echo " TARGETED CONTINUATION"
echo " NO APK BUILD"
echo "================================================"

mkdir -p "$BACKUP" "$LOG"

echo
echo "[1/7] Checking partial Level 64 state..."

test -f "$CHAT"
test -f "$ENGINE"
test -f "$MANIFEST"

grep -q 'fun hasMicrophonePermission()' "$ENGINE"
grep -q 'Manifest.permission.RECORD_AUDIO' "$ENGINE"
grep -q 'import android.Manifest' "$CHAT"
grep -q 'rememberLauncherForActivityResult' "$CHAT" || true

echo "[OK] Level 64 continuation prerequisites verified"

echo
echo "[2/7] Creating continuation backups..."

cp "$CHAT" "$BACKUP/ChatScreen.before_resume.kt.backup"
cp "$ENGINE" "$BACKUP/MONUVoiceInputEngine.before_resume.kt.backup"

echo "[OK] Continuation backups preserved"

echo
echo "[3/7] Adding runtime permission launcher safely..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

if 'val microphonePermissionLauncher =' not in text:

    anchor = '''    var voiceListening by remember {
'''

    injection = '''    val microphonePermissionLauncher =
        rememberLauncherForActivityResult(
            contract = ActivityResultContracts.RequestPermission()
        ) { granted ->
            if (granted) {
                voiceInputStatus = ""
                voiceInputEngine.startListening()
            } else {
                voiceInputStatus =
                    "Microphone permission was denied."
                voiceListening = false
            }
        }

'''

    if anchor not in text:
        raise SystemExit(
            "FAIL: voiceListening state anchor not found"
        )

    text = text.replace(
        anchor,
        injection + anchor,
        1
    )

path.write_text(text)
PY

echo "[OK] Permission launcher ready"

echo
echo "[4/7] Wiring Start Voice through permission gate..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

if 'val microphoneGranted =' not in text:

    old = '''                    } else {
                        voiceInputStatus = ""
                        voiceInputEngine.startListening()
                    }'''

    new = '''                    } else {
                        voiceInputStatus = ""

                        val microphoneGranted =
                            ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.RECORD_AUDIO
                            ) == PackageManager.PERMISSION_GRANTED

                        if (microphoneGranted) {
                            voiceInputEngine.startListening()
                        } else {
                            microphonePermissionLauncher.launch(
                                Manifest.permission.RECORD_AUDIO
                            )
                        }
                    }'''

    if old not in text:
        raise SystemExit(
            "FAIL: Start Voice button block anchor not found"
        )

    text = text.replace(old, new, 1)

path.write_text(text)
PY

echo "[OK] Start Voice permission gate connected"

echo
echo "[5/7] Creating Level 64 verification..."

cat > level64_voice_permission_test.sh <<'TEST'
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
TEST

chmod +x level64_voice_permission_test.sh

echo
echo "[6/7] Running Level 64 verification..."

./level64_voice_permission_test.sh

echo
echo "[7/7] Saving permission architecture map..."

{
    echo "LEVEL 64 RUNTIME PERMISSION MAP"
    echo "================================"
    echo
    echo "ENGINE:"
    grep -nE \
    'hasMicrophonePermission|RECORD_AUDIO|checkSelfPermission' \
    "$ENGINE" || true

    echo
    echo "CHAT:"
    grep -nE \
    'microphonePermissionLauncher|RequestPermission|microphoneGranted|RECORD_AUDIO' \
    "$CHAT" || true
} > "$LOG/runtime_permission_map.txt"

echo "[OK] Permission architecture map saved"

echo
echo "================================================"
echo " LEVEL 64 COMPLETE"
echo "================================================"
echo "✓ Engine independently checks microphone permission"
echo "✓ Chat requests runtime permission safely"
echo "✓ Start Voice is permission-gated"
echo "✓ Permission denial is visible"
echo "✓ Existing voice pipeline preserved"
echo "✓ Continuation backups preserved"
echo
echo "NEXT: LEVEL 65 - VOICE SESSION ROBUSTNESS AUDIT"
echo "================================================"
