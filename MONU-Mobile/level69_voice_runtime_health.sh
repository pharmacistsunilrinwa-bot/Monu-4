#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
BACKUP=".monu-backups/level69"
LOG=".monu-logs/level69"

mkdir -p "$BACKUP" "$LOG"

test -f "$CHAT"
test -f "$ENGINE"

cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"
cp "$ENGINE" "$BACKUP/MONUVoiceInputEngine.kt.backup"

python - <<'PY'
from pathlib import Path

path = Path("app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceInputEngine.kt")
text = path.read_text()

if "fun getRuntimeHealth(): String" not in text:
    anchor = "    fun isAvailable(): Boolean {"

    if anchor not in text:
        raise SystemExit("FAIL: isAvailable anchor not found")

    health = '''    fun getRuntimeHealth(): String {
        return when {
            !hasMicrophonePermission() ->
                "Microphone permission required"
            !isAvailable() ->
                "Speech recognition unavailable"
            listening ->
                "Listening"
            else ->
                "Ready"
        }
    }

'''

    text = text.replace(anchor, health + anchor, 1)

path.write_text(text)
PY

python - <<'PY'
from pathlib import Path

path = Path("app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt")
text = path.read_text()

if "var voiceRuntimeHealth by remember" not in text:
    anchor = "    var voiceListening by remember"

    if anchor not in text:
        raise SystemExit("FAIL: voiceListening anchor not found")

    injection = '''    var voiceRuntimeHealth by remember {
        mutableStateOf(voiceInputEngine.getRuntimeHealth())
    }

'''

    text = text.replace(anchor, injection + anchor, 1)

if 'voiceRuntimeHealth = voiceInputEngine.getRuntimeHealth()' not in text:
    anchor = '''            onListeningStateChanged = { isListening ->
                voiceListening = isListening
            }'''

    replacement = '''            onListeningStateChanged = { isListening ->
                voiceListening = isListening
                voiceRuntimeHealth =
                    voiceInputEngine.getRuntimeHealth()
            }'''

    if anchor not in text:
        raise SystemExit("FAIL: listening callback anchor not found")

    text = text.replace(anchor, replacement, 1)

path.write_text(text)
PY

cat > level69_voice_runtime_health_test.sh <<'TEST'
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
TEST

chmod +x level69_voice_runtime_health_test.sh
./level69_voice_runtime_health_test.sh

{
    echo "LEVEL 69 VOICE RUNTIME HEALTH MAP"
    echo "================================="
    echo
    echo "ENGINE:"
    grep -nE \
    'getRuntimeHealth|Microphone permission|required|unavailable|Listening|Ready' \
    "$ENGINE" || true
    echo
    echo "CHAT:"
    grep -nE \
    'voiceRuntimeHealth|getRuntimeHealth|onListeningStateChanged' \
    "$CHAT" || true
} > "$LOG/voice_runtime_health_map.txt"

echo "================================================"
echo " LEVEL 69 COMPLETE"
echo "================================================"
