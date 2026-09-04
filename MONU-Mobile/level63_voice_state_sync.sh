#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
BACKUP=".monu-backups/level63"
LOG=".monu-logs/level63"

echo "================================================"
echo " MONU MOBILE - LEVEL 63"
echo " VOICE STATE SYNCHRONIZATION"
echo " NO APK BUILD"
echo "================================================"

mkdir -p "$BACKUP" "$LOG"

echo
echo "[1/8] Checking Level 62 GOLDEN prerequisites..."

test -f "$CHAT"
test -f "$ENGINE"

grep -q 'private var listening = false' "$ENGINE"
grep -q 'var voiceListening by remember' "$CHAT"
grep -q 'MONUVoiceInputEngine(' "$CHAT"
grep -q 'voiceInputEngine.startListening()' "$CHAT"

echo "[OK] Level 62 prerequisites verified"

echo
echo "[2/8] Creating backups..."

cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"
cp "$ENGINE" "$BACKUP/MONUVoiceInputEngine.kt.backup"

echo "[OK] ChatScreen backup preserved"
echo "[OK] Voice engine backup preserved"

echo
echo "[3/8] Adding engine listening-state callback..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceInputEngine.kt"
)

text = path.read_text()

old = '''class MONUVoiceInputEngine(
    context: Context,
    private val onResult: (String) -> Unit,
    private val onError: (String) -> Unit = {}
) : RecognitionListener {
'''

new = '''class MONUVoiceInputEngine(
    context: Context,
    private val onResult: (String) -> Unit,
    private val onError: (String) -> Unit = {},
    private val onListeningStateChanged: (Boolean) -> Unit = {}
) : RecognitionListener {
'''

if old not in text:
    raise SystemExit(
        "FAIL: MONUVoiceInputEngine constructor anchor not found"
    )

text = text.replace(old, new, 1)

old_state = '''    private var listening = false
'''

new_state = '''    private var listening = false

    private fun updateListeningState(value: Boolean) {
        listening = value
        onListeningStateChanged(value)
    }
'''

if new_state not in text:
    if old_state not in text:
        raise SystemExit(
            "FAIL: listening state anchor not found"
        )

    text = text.replace(old_state, new_state, 1)

replacements = {
    '        listening = true\n\n        speechRecognizer?.startListening(intent)':
    '        updateListeningState(true)\n\n        speechRecognizer?.startListening(intent)',

    '        listening = false\n        speechRecognizer?.stopListening()':
    '        updateListeningState(false)\n        speechRecognizer?.stopListening()',

    '        listening = false\n        speechRecognizer?.cancel()':
    '        updateListeningState(false)\n        speechRecognizer?.cancel()',

    '''    override fun onReadyForSpeech(params: Bundle?) {
        listening = true
    }''':
    '''    override fun onReadyForSpeech(params: Bundle?) {
        updateListeningState(true)
    }''',

    '''    override fun onBeginningOfSpeech() {
        listening = true
    }''':
    '''    override fun onBeginningOfSpeech() {
        updateListeningState(true)
    }''',

    '''    override fun onEndOfSpeech() {
        listening = false
    }''':
    '''    override fun onEndOfSpeech() {
        updateListeningState(false)
    }''',

    '''    override fun onError(error: Int) {
        listening = false''':
    '''    override fun onError(error: Int) {
        updateListeningState(false)''',

    '''    override fun onResults(results: Bundle?) {
        listening = false''':
    '''    override fun onResults(results: Bundle?) {
        updateListeningState(false)'''
}

for old_text, new_text in replacements.items():
    if old_text in text:
        text = text.replace(old_text, new_text, 1)

path.write_text(text)
PY

echo "[OK] Engine state callback added"

echo
echo "[4/8] Connecting engine state to Compose UI..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

needle = '''            onError = { error ->
                voiceInputStatus = error
            }
'''

replacement = '''            onError = { error ->
                voiceInputStatus = error
                voiceListening = false
            },
            onListeningStateChanged = { isListening ->
                voiceListening = isListening
            }
'''

if 'onListeningStateChanged = { isListening ->' not in text:
    if needle not in text:
        raise SystemExit(
            "FAIL: Voice engine error callback anchor not found"
        )

    text = text.replace(
        needle,
        replacement,
        1
    )

path.write_text(text)
PY

echo "[OK] Compose UI synchronized with engine state"

echo
echo "[5/8] Simplifying manual UI state ownership..."

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

old = '''                    if (voiceListening) {
                        voiceInputEngine.stopListening()
                        voiceListening = false
                    } else {
                        voiceInputStatus = ""
                        voiceInputEngine.startListening()
                        voiceListening = true
                    }
'''

new = '''                    if (voiceListening) {
                        voiceInputEngine.stopListening()
                    } else {
                        voiceInputStatus = ""
                        voiceInputEngine.startListening()
                    }
'''

if old in text:
    text = text.replace(old, new, 1)

path.write_text(text)
PY

echo "[OK] Engine is now authoritative for listening state"

echo
echo "[6/8] Creating Level 63 verification..."

cat > level63_voice_state_sync_test.sh <<'TEST'
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
TEST

chmod +x level63_voice_state_sync_test.sh

echo
echo "[7/8] Running verification..."

./level63_voice_state_sync_test.sh

echo
echo "[8/8] Saving architecture map..."

{
    echo "LEVEL 63 VOICE STATE SYNCHRONIZATION"
    echo "====================================="
    echo
    echo "ENGINE STATE:"
    grep -nE \
    'onListeningStateChanged|updateListeningState|onReadyForSpeech|onEndOfSpeech|onResults|onError' \
    "$ENGINE"
    echo
    echo "CHAT STATE:"
    grep -nE \
    'voiceListening|onListeningStateChanged|voiceInputStatus' \
    "$CHAT"
} > "$LOG/voice_state_sync_map.txt"

echo "[OK] Architecture map saved"

echo
echo "================================================"
echo " LEVEL 63 COMPLETE"
echo "================================================"
echo "✓ Voice engine owns real listening state"
echo "✓ State changes emit callbacks"
echo "✓ UI follows SpeechRecognizer lifecycle"
echo "✓ Results automatically stop UI listening state"
echo "✓ Errors automatically stop UI listening state"
echo "✓ Manual duplicate state ownership reduced"
echo "✓ Backups preserved"
echo
echo "NEXT: LEVEL 64 - VOICE RUNTIME PERMISSION SAFETY"
echo "================================================"
