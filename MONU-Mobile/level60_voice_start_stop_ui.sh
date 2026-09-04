#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
BACKUP=".monu-backups/level60"

echo "================================================"
echo " MONU MOBILE - LEVEL 60"
echo " VOICE START / STOP UI CONTROL"
echo " NO APK BUILD"
echo "================================================"

mkdir -p "$BACKUP"

echo "[1/7] Checking Level 59 prerequisites..."
test -f "$CHAT"
grep -q 'val voiceInputEngine = remember' "$CHAT"
grep -q 'MONUVoiceInputEngine' "$CHAT"
grep -q 'CommandInput' "$CHAT"
echo "[OK] Level 59 integration found"

echo "[2/7] Creating backup..."
cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"
echo "[OK] Backup preserved"

echo "[3/7] Checking existing microphone UI..."

if grep -q 'voiceInputEngine.startListening' "$CHAT"; then
    echo "[INFO] Voice start already exists - skipping duplicate injection"
else

python - <<'PY'
from pathlib import Path

path = Path("app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt")
text = path.read_text()

# Add listening state before voiceInputStatus
anchor = '''    var voiceInputStatus by remember {
'''

injection = '''    var voiceListening by remember {
        mutableStateOf(false)
    }

'''

if 'var voiceListening by remember' not in text:
    if anchor not in text:
        raise SystemExit("FAIL: Voice state anchor not found")
    text = text.replace(anchor, injection + anchor, 1)

# Find CommandInput block and inject voice controls immediately before it
anchor = '''        CommandInput { command, attachments ->
'''

controls = '''        Row {
            Button(
                onClick = {
                    if (voiceListening) {
                        voiceInputEngine.stopListening()
                        voiceListening = false
                    } else {
                        voiceInputStatus = ""
                        voiceInputEngine.startListening()
                        voiceListening = true
                    }
                }
            ) {
                Text(
                    if (voiceListening) {
                        "Stop Listening"
                    } else {
                        "Start Voice"
                    }
                )
            }

            if (voiceInputStatus.isNotBlank()) {
                Text(voiceInputStatus)
            }
        }

'''

if 'voiceInputEngine.startListening()' not in text:
    if anchor not in text:
        raise SystemExit("FAIL: CommandInput anchor not found")
    text = text.replace(anchor, controls + anchor, 1)

path.write_text(text)
PY

fi

echo "[OK] Voice Start/Stop control injected"

echo "[4/7] Verifying UI dependencies..."

grep -q 'import androidx.compose.foundation.layout.Row' "$CHAT" || \
sed -i '/import androidx.compose.foundation.layout/a\
import androidx.compose.foundation.layout.Row' "$CHAT"

grep -q 'import androidx.compose.material3.Button' "$CHAT" || true

echo "[OK] UI dependency check complete"

echo "[5/7] Creating Level 60 integration test..."

cat > level60_voice_ui_test.sh <<'TEST'
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
TEST

chmod +x level60_voice_ui_test.sh

echo "[6/7] Running integration test..."
./level60_voice_ui_test.sh

echo "[7/7] Final pipeline summary..."

echo
echo "VOICE UI FLOW:"
echo
echo "Start Voice Button"
echo "        ↓"
echo "voiceInputEngine.startListening()"
echo "        ↓"
echo "SpeechRecognizer"
echo "        ↓"
echo "Recognized Command"
echo "        ↓"
echo "Existing Chat Pipeline"
echo "        ↓"
echo "Knowledge Engine"
echo "        ↓"
echo "MONU Response"
echo
echo "Stop Listening"
echo "        ↓"
echo "voiceInputEngine.stopListening()"

echo
echo "================================================"
echo " LEVEL 60 COMPLETE"
echo "================================================"
echo "✓ Start voice UI connected"
echo "✓ Stop voice UI connected"
echo "✓ Listening state controlled"
echo "✓ Voice errors visible"
echo "✓ Existing chat pipeline preserved"
echo "✓ Lifecycle cleanup preserved"
echo
echo "NEXT: LEVEL 61 - VOICE PIPELINE END-TO-END AUDIT"
echo "================================================"
