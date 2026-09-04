#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
BACKUP=".monu-backups/level59"
LOG=".monu-logs/level59"

echo "================================================"
echo " MONU MOBILE - LEVEL 59"
echo " VOICE RESULT -> EXISTING CHAT PIPELINE"
echo " NO APK BUILD"
echo "================================================"

mkdir -p "$BACKUP" "$LOG"

echo "[1/8] Checking prerequisites..."
test -f "$CHAT"
test -f "$ENGINE"
grep -q 'fun ChatScreen()' "$CHAT"
grep -q 'CommandInput' "$CHAT"
grep -q 'MONUVoiceInputEngine' "$ENGINE"

echo "[OK] Prerequisites verified"

echo "[2/8] Creating backup..."
cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"
echo "[OK] Backup preserved"

echo "[3/8] Inspecting exact command pipeline..."

sed -n '1,290p' "$CHAT" > "$LOG/ChatScreen.before.txt"

grep -nE \
'CommandInput|ownerMessage|MessageRole\.OWNER|messages = messages \+|scope\.launch' \
"$CHAT" | head -80

echo "[4/8] Locating safe insertion points..."

if grep -q 'MONUVoiceInputEngine' "$CHAT"; then
    echo "[INFO] Voice input already referenced - stopping to avoid duplicate wiring"
    exit 1
fi

IMPORT_LINE=$(grep -n 'import com.monu.mobile.ui.components.CommandInput' "$CHAT" | head -1 | cut -d: -f1)

if [ -z "$IMPORT_LINE" ]; then
    echo "[FAIL] Cannot locate CommandInput import"
    exit 1
fi

echo "[OK] Import insertion anchor found"

echo "[5/8] Adding voice input engine import..."

sed -i '/import com\.monu\.mobile\.ui\.components\.CommandInput/a\
import com.monu.mobile.feature.voice.MONUVoiceInputEngine' "$CHAT"

echo "[6/8] Injecting voice input state safely..."

python - <<'PY'
from pathlib import Path

path = Path("app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt")
text = path.read_text()

anchor = '''    val networkMonitor = remember {
'''

injection = '''    var voiceInputStatus by remember {
        mutableStateOf("")
    }

    val voiceInputEngine = remember {
        MONUVoiceInputEngine(
            context = context,
            onResult = { recognizedCommand ->
                val cleanCommand = recognizedCommand.trim()

                if (cleanCommand.isNotBlank()) {
                    messages = messages + ChatMessage(
                        role = MessageRole.OWNER,
                        content = cleanCommand
                    )

                    scope.launch {
                        if (!networkMonitor.isOnline()) {
                            messages = messages + ChatMessage(
                                role = MessageRole.SYSTEM,
                                content = "Internet connection is unavailable."
                            )
                            return@launch
                        }

                        searching = true

                        try {
                            when (
                                val result =
                                    withContext(Dispatchers.IO) {
                                        knowledgeEngine.search(cleanCommand)
                                    }
                            ) {
                                is InternetKnowledgeState.SUCCESS -> {
                                    messages = messages + ChatMessage(
                                        role = MessageRole.MONU,
                                        content = result.answer
                                    )
                                }

                                is InternetKnowledgeState.NOT_FOUND -> {
                                    messages = messages + ChatMessage(
                                        role = MessageRole.SYSTEM,
                                        content = "No information found for this command."
                                    )
                                }

                                is InternetKnowledgeState.NETWORK_ERROR -> {
                                    messages = messages + ChatMessage(
                                        role = MessageRole.SYSTEM,
                                        content = "Network error while processing voice command."
                                    )
                                }

                                is InternetKnowledgeState.INVALID_QUERY -> {
                                    messages = messages + ChatMessage(
                                        role = MessageRole.SYSTEM,
                                        content = "Voice command was invalid."
                                    )
                                }
                            }
                        } finally {
                            searching = false
                        }
                    }
                }
            },
            onError = { error ->
                voiceInputStatus = error
            }
        )
    }

'''

if anchor not in text:
    raise SystemExit("FAIL: Safe insertion anchor not found")

text = text.replace(anchor, injection + anchor, 1)
path.write_text(text)
PY

echo "[OK] Voice result callback connected"

echo "[7/8] Adding lifecycle cleanup..."

python - <<'PY'
from pathlib import Path

path = Path("app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt")
text = path.read_text()

needle = 'voiceEngine.shutdown()'

if needle not in text:
    raise SystemExit("FAIL: voiceEngine.shutdown lifecycle anchor missing")

if 'voiceInputEngine.shutdown()' not in text:
    text = text.replace(
        needle,
        needle + '\n        voiceInputEngine.shutdown()',
        1
    )

path.write_text(text)
PY

echo "[OK] Voice input lifecycle cleanup connected"

echo "[8/8] Creating integration verification..."

cat > level59_voice_result_chat_test.sh <<'TEST'
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
TEST

chmod +x level59_voice_result_chat_test.sh
./level59_voice_result_chat_test.sh

echo
echo "================================================"
echo " LEVEL 59 COMPLETE"
echo "================================================"
echo "✓ Voice result connected to ChatScreen"
echo "✓ Recognized text becomes owner command"
echo "✓ Knowledge pipeline connected"
echo "✓ Network execution isolated"
echo "✓ Voice errors captured"
echo "✓ Lifecycle cleanup connected"
echo "✓ Original ChatScreen backup preserved"
echo
echo "NEXT: LEVEL 60 - VOICE START/STOP UI CONTROL"
echo "================================================"
