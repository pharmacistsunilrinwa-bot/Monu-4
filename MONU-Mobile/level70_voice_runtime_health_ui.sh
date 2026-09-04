#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ENGINE="$BASE/feature/voice/MONUVoiceInputEngine.kt"
BACKUP=".monu-backups/level70"
LOG=".monu-logs/level70"

mkdir -p "$BACKUP" "$LOG"

test -f "$CHAT"
test -f "$ENGINE"

cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"
cp "$ENGINE" "$BACKUP/MONUVoiceInputEngine.kt.backup"

python - <<'PY'
from pathlib import Path

path = Path("app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt")
text = path.read_text()

# Find a safe UI anchor near the existing voice controls/status.
if 'text = voiceRuntimeHealth' not in text:
    anchors = [
        'voiceInputStatus.isNotBlank()',
        'voiceInputStatus',
        '"Start Voice"',
    ]

    anchor_pos = -1
    for anchor in anchors:
        anchor_pos = text.find(anchor)
        if anchor_pos != -1:
            break

    if anchor_pos == -1:
        raise SystemExit("FAIL: voice UI anchor not found")

    # Insert health display before the nearest enclosing UI section.
    line_start = text.rfind('\n', 0, anchor_pos)
    if line_start == -1:
        raise SystemExit("FAIL: could not locate UI insertion point")

    indent = ""
    for ch in text[line_start + 1:]:
        if ch in " \t":
            indent += ch
        else:
            break

    health_ui = f'''{indent}Text(
{indent}    text = voiceRuntimeHealth
{indent})
'''

    text = text[:line_start + 1] + health_ui + text[line_start + 1:]

path.write_text(text)
PY

cat > level70_voice_runtime_health_ui_test.sh <<'TEST'
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
echo " LEVEL 70 VOICE RUNTIME HEALTH UI TEST"
echo "================================================"

check \
"$ENGINE" \
'fun getRuntimeHealth\(\): String' \
"Engine health provider exists"

check \
"$CHAT" \
'var voiceRuntimeHealth by remember' \
"Chat owns health state"

check \
"$CHAT" \
'voiceInputEngine\.getRuntimeHealth\(\)' \
"Chat reads engine health"

check \
"$CHAT" \
'text[[:space:]]*=[[:space:]]*voiceRuntimeHealth' \
"Runtime health is visible in UI"

check \
"$CHAT" \
'voiceRuntimeHealth[[:space:]]*=' \
"Runtime health update path exists"

check \
"$CHAT" \
'onListeningStateChanged = \{ isListening ->' \
"Engine state synchronization preserved"

COUNT=$(grep -cE 'text[[:space:]]*=[[:space:]]*voiceRuntimeHealth' "$CHAT" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single runtime health UI display"
else
    fail "Runtime health UI display count is $COUNT"
fi

echo "================================================"
echo " LEVEL 70 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 70 GOLDEN"
    echo "Voice runtime health is visible to the user"
else
    echo "LEVEL 70 NEEDS TARGETED REPAIR"
    exit 1
fi
TEST

chmod +x level70_voice_runtime_health_ui_test.sh
./level70_voice_runtime_health_ui_test.sh

{
    echo "LEVEL 70 VOICE RUNTIME HEALTH UI MAP"
    echo "===================================="
    grep -nE \
    'voiceRuntimeHealth|getRuntimeHealth|text[[:space:]]*=[[:space:]]*voiceRuntimeHealth' \
    "$CHAT" || true
} > "$LOG/voice_runtime_health_ui_map.txt"

echo "================================================"
echo " LEVEL 70 COMPLETE"
echo "================================================"
echo "NEXT: LEVEL 71 - OFFLINE COMMAND FALLBACK"
echo "================================================"
