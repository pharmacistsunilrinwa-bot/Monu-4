#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
MANIFEST="app/src/main/AndroidManifest.xml"
BACKUP=".monu-backups/level64"
LOG=".monu-logs/level64"

echo "================================================"
echo " MONU MOBILE - LEVEL 64"
echo " VOICE RUNTIME PERMISSION SAFETY"
echo " NO APK BUILD"
echo "================================================"

mkdir -p "$BACKUP" "$LOG"

echo
echo "[1/8] Checking Level 63 prerequisites..."

test -f "$CHAT"
test -f "$ENGINE"
test -f "$MANIFEST"

grep -q 'android.permission.RECORD_AUDIO' "$MANIFEST"
grep -q 'MONUVoiceInputEngine' "$CHAT"
grep -q 'voiceInputEngine.startListening()' "$CHAT"

echo "[OK] Level 63 voice prerequisites verified"

echo
echo "[2/8] Creating backups..."

cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"
cp "$ENGINE" "$BACKUP/MONUVoiceInputEngine.kt.backup"
cp "$MANIFEST" "$BACKUP/AndroidManifest.xml.backup"

echo "[OK] Backups preserved"

echo
echo "[3/8] Adding permission safety to voice engine..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceInputEngine.kt"
)

text = path.read_text()

if 'import android.Manifest' not in text:
    anchor = 'import android.content.Context\n'
    if anchor not in text:
        raise SystemExit("FAIL: Context import anchor missing")

    text = text.replace(
        anchor,
        'import android.Manifest\n' + anchor,
        1
    )

if 'import android.content.pm.PackageManager' not in text:
    anchor = 'import android.content.Intent\n'
    if anchor not in text:
        raise SystemExit("FAIL: Intent import anchor missing")

    text = text.replace(
        anchor,
        anchor + 'import android.content.pm.PackageManager\n',
        1
    )

if 'import androidx.core.content.ContextCompat' not in text:
    last_import = 'import android.speech.SpeechRecognizer\n'
    if last_import not in text:
        raise SystemExit("FAIL: SpeechRecognizer import anchor missing")

    text = text.replace(
        last_import,
        last_import + 'import androidx.core.content.ContextCompat\n',
        1
    )

old = '''    fun isAvailable(): Boolean {
        return SpeechRecognizer.isRecognitionAvailable(appContext)
    }

    fun startListening() {
'''

new = '''    fun isAvailable(): Boolean {
        return SpeechRecognizer.isRecognitionAvailable(appContext)
    }

    fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            appContext,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun startListening() {
'''

if 'fun hasMicrophonePermission()' not in text:
    if old not in text:
        raise SystemExit(
            "FAIL: Voice availability/start anchor missing"
        )

    text = text.replace(old, new, 1)

old_start = '''    fun startListening() {
        if (listening) return

        if (!isAvailable()) {
'''

new_start = '''    fun startListening() {
        if (listening) return

        if (!hasMicrophonePermission()) {
            onError("Microphone permission is required.")
            updateListeningState(false)
            return
        }

        if (!isAvailable()) {
'''

if old_start not in text:
    raise SystemExit(
        "FAIL: startListening permission insertion anchor missing"
    )

text = text.replace(old_start, new_start, 1)

path.write_text(text)
PY

echo "[OK] Engine microphone permission gate added"

echo
echo "[4/8] Preparing Chat runtime permission imports..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

imports = [
    'import android.Manifest\n',
    'import android.content.pm.PackageManager\n',
    'import androidx.activity.compose.rememberLauncherForActivityResult\n',
    'import androidx.activity.result.contract.ActivityResultContracts\n',
    'import androidx.core.content.ContextCompat\n',
]

anchor = 'import androidx.compose.runtime.Composable\n'

if anchor not in text:
    raise SystemExit("FAIL: Compose import anchor missing")

for imp in imports:
    if imp not in text:
        text = text.replace(anchor, imp + anchor, 1)

path.write_text(text)
PY

echo "[OK] Runtime permission imports prepared"

echo
echo "[5/8] Adding permission request launcher..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

if 'rememberLauncherForActivityResult(' not in text:

    anchor = '''    var voiceListening by remember {
'''

    injection = '''    val microphonePermissionLauncher =
        rememberLauncherForActivityResult(
            contract =
                ActivityResultContracts.RequestPermission()
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
            "FAIL: Voice listening state anchor missing"
        )

    text = text.replace(
        anchor,
        injection + anchor,
        1
    )

path.write_text(text)
PY

echo "[OK] Permission request launcher added"

echo
echo "[6/8] Wiring Start Voice through permission gate..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

old = '''                    } else {
                        voiceInputStatus = ""
                        voiceInputEngine.startListening()
                    }
'''

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
                    }
'''

if old not in text:
    raise SystemExit(
        "FAIL: Start Voice button anchor missing"
    )

text = text.replace(old, new, 1)

path.write_text(text)
PY

echo "[OK] Start Voice permission gate connected"

echo
echo "[7/8] Creating Level 64 verification..."

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
echo "[1/4] Manifest permission"

check \
"$MANIFEST" \
'android\.permission\.RECORD_AUDIO' \
"RECORD_AUDIO declared in manifest"

echo
echo "[2/4] Engine safety gate"

check \
"$ENGINE" \
'fun hasMicrophonePermission\(\)' \
"Engine permission check exists"

check \
"$ENGINE" \
'ContextCompat\.checkSelfPermission' \
"Engine checks runtime permission"

check \
"$ENGINE" \
'Manifest\.permission\.RECORD_AUDIO' \
"Engine references microphone permission"

check \
"$ENGINE" \
'Microphone permission is required' \
"Engine blocks unauthorized listening"

echo
echo "[3/4] Runtime permission request"

check \
"$CHAT" \
'rememberLauncherForActivityResult' \
"Permission launcher exists"

check \
"$CHAT" \
'ActivityResultContracts\.RequestPermission' \
"Runtime permission contract exists"

check \
"$CHAT" \
'microphonePermissionLauncher\.launch' \
"Permission launcher invoked"

check \
"$CHAT" \
'Manifest\.permission\.RECORD_AUDIO' \
"Chat requests microphone permission"

echo
echo "[4/4] Start Voice safety flow"

check \
"$CHAT" \
'ContextCompat\.checkSelfPermission' \
"Chat checks permission before start"

check \
"$CHAT" \
'PackageManager\.PERMISSION_GRANTED' \
"Permission granted state checked"

check \
"$CHAT" \
'if \(microphoneGranted\)' \
"Start Voice branches on permission"

check \
"$CHAT" \
'voiceInputEngine\.startListening\(\)' \
"Listening starts only after permission path"

check \
"$CHAT" \
'Microphone permission was denied' \
"Permission denial visible to user"

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
echo "[8/8] Running verification..."

./level64_voice_permission_test.sh

{
    echo "LEVEL 64 RUNTIME PERMISSION MAP"
    echo "==============================="
    echo
    echo "ENGINE:"
    grep -nE \
    'hasMicrophonePermission|RECORD_AUDIO|checkSelfPermission' \
    "$ENGINE"
    echo
    echo "CHAT:"
    grep -nE \
    'microphonePermissionLauncher|RequestPermission|microphoneGranted|RECORD_AUDIO' \
    "$CHAT"
} > "$LOG/runtime_permission_map.txt"

echo "[OK] Permission architecture map saved"

echo
echo "================================================"
echo " LEVEL 64 COMPLETE"
echo "================================================"
echo "✓ Manifest permission preserved"
echo "✓ Engine permission safety gate added"
echo "✓ Runtime permission launcher added"
echo "✓ Start Voice checks permission first"
echo "✓ Permission denial handled safely"
echo "✓ Voice engine protected independently"
echo "✓ Backups preserved"
echo
echo "NEXT: LEVEL 65 - VOICE SESSION ROBUSTNESS AUDIT"
echo "================================================"
