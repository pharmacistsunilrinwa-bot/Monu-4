#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"

BACKUP=".monu-backups/level76-repair"
LOG=".monu-logs/level76-repair"

mkdir -p "$BACKUP" "$LOG"

test -f "$ROUTER"

cp "$ROUTER" \
"$BACKUP/MONUOfflineCommandRouter.before_repair.kt.backup"

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/feature/offline/"
    "MONUOfflineCommandRouter.kt"
)

text = path.read_text()

start = text.find(
    "    fun canHandle(command: String): Boolean {"
)

end = text.find(
    "\n    fun handle(command: String): String {",
    start
)

if start == -1 or end == -1:
    raise SystemExit(
        "FAIL: canHandle function boundaries not found"
    )

replacement = '''    fun canHandle(command: String): Boolean {
        val intent = intentParser.parse(command)

        return intent != MONUOfflineCommandIntent.UNKNOWN
    }
'''

text = (
    text[:start]
    + replacement
    + text[end:]
)

path.write_text(text)
PY

cat > level76_offline_command_execution_repair_test.sh <<'TEST'
#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
PARSER="$BASE/feature/offline/MONUOfflineCommandIntentParser.kt"

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
echo " LEVEL 76 TARGETED REPAIR TEST"
echo "================================================"

check \
"$ROUTER" \
'fun canHandle\(command: String\): Boolean' \
"Router capability function exists"

check \
"$ROUTER" \
'intentParser\.parse\(command\)' \
"Capability detection uses intent parser"

check \
"$ROUTER" \
'intent != MONUOfflineCommandIntent\.UNKNOWN' \
"Capability detection rejects unknown intent"

check \
"$ROUTER" \
'fun handle\(command: String\): String' \
"Router execution function preserved"

check \
"$ROUTER" \
'when \(intentParser\.parse\(command\)\)' \
"Router intent dispatch preserved"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Unknown intent remains defined"

COUNT=$(grep -c \
'fun canHandle(command: String): Boolean' \
"$ROUTER" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single capability authority"
else
    fail "Capability function count is $COUNT"
fi

echo "================================================"
echo " LEVEL 76 TARGETED REPAIR RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 76 REPAIR GOLDEN"
else
    echo "LEVEL 76 REPAIR FAILED"
    exit 1
fi
TEST

chmod +x level76_offline_command_execution_repair_test.sh

./level76_offline_command_execution_repair_test.sh

echo
echo "================================================"
echo " RE-RUNNING ORIGINAL LEVEL 76 AUDIT"
echo "================================================"

./level76_offline_command_execution_audit.sh

{
    echo "LEVEL 76 CAPABILITY REPAIR MAP"
    echo "==============================="
    echo
    grep -nE \
    'fun canHandle|val intent =|intentParser\.parse|UNKNOWN' \
    "$ROUTER" || true
} > "$LOG/capability_repair_map.txt"

echo "================================================"
echo " LEVEL 76 REPAIR COMPLETE"
echo "================================================"
echo "If original audit is GOLDEN:"
echo "NEXT: LEVEL 77 - OFFLINE COMMAND CAPABILITY MATRIX"
echo "================================================"
