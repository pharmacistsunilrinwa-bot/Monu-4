#!/data/data/com.termux/files/usr/bin/bash
set -e

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
ENGINE="app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceInputEngine.kt"
BACKUP=".monu-backups/level68-repair"
LOG=".monu-logs/level68-repair"

mkdir -p "$BACKUP" "$LOG"

test -f "$CHAT"
test -f "$ENGINE"

cp "$CHAT" "$BACKUP/ChatScreen.before_repair.kt.backup"
cp "$ENGINE" "$BACKUP/MONUVoiceInputEngine.before_repair.kt.backup"

python - <<'PY'
from pathlib import Path

path = Path("app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt")
text = path.read_text()

# Ensure DisposableEffect import exists.
if "import androidx.compose.runtime.DisposableEffect" not in text:
    package_line_end = text.find("\n")
    if package_line_end == -1:
        raise SystemExit("FAIL: package line not found")

    text = (
        text[:package_line_end + 1]
        + "import androidx.compose.runtime.DisposableEffect\n"
        + text[package_line_end + 1:]
    )

# Do not add a duplicate lifecycle owner.
if "DisposableEffect(voiceInputEngine)" not in text:
    anchor = "    var voiceListening by remember"

    if anchor not in text:
        raise SystemExit(
            "FAIL: safe Compose state anchor not found"
        )

    lifecycle = '''    DisposableEffect(voiceInputEngine) {
        onDispose {
            voiceInputEngine.shutdown()
        }
    }

'''

    text = text.replace(
        anchor,
        lifecycle + anchor,
        1
    )

path.write_text(text)
PY

cat > level68_voice_lifecycle_disposal_test.sh <<'TEST'
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
echo " LEVEL 68 VOICE LIFECYCLE DISPOSAL TEST"
echo "================================================"

check \
"$CHAT" \
'import androidx\.compose\.runtime\.DisposableEffect' \
"DisposableEffect import exists"

check \
"$CHAT" \
'DisposableEffect\(voiceInputEngine\)' \
"Voice lifecycle owner exists"

check \
"$CHAT" \
'onDispose[[:space:]]*\{' \
"Compose disposal callback exists"

check \
"$CHAT" \
'voiceInputEngine\.shutdown\(\)' \
"Voice shutdown connected to disposal"

check \
"$ENGINE" \
'fun shutdown' \
"Engine shutdown function exists"

check \
"$ENGINE" \
'speechRecognizer\?\.cancel\(\)' \
"Shutdown cancels recognizer"

check \
"$ENGINE" \
'speechRecognizer\?\.destroy\(\)' \
"Shutdown destroys recognizer"

check \
"$ENGINE" \
'speechRecognizer = null' \
"Shutdown releases recognizer"

COUNT=$(grep -c 'DisposableEffect(voiceInputEngine)' "$CHAT" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single lifecycle disposal owner"
else
    fail "Lifecycle disposal owner count is $COUNT"
fi

echo "================================================"
echo " LEVEL 68 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 68 GOLDEN"
else
    echo "LEVEL 68 NEEDS TARGETED REPAIR"
    exit 1
fi
TEST

chmod +x level68_voice_lifecycle_disposal_test.sh

./level68_voice_lifecycle_disposal_test.sh

{
    echo "LEVEL 68 VOICE LIFECYCLE MAP"
    echo "============================"
    grep -nE \
    'DisposableEffect|onDispose|voiceInputEngine\.shutdown' \
    "$CHAT" || true
} > "$LOG/voice_lifecycle_map.txt"

echo "================================================"
echo " LEVEL 68 COMPLETE"
echo "================================================"
