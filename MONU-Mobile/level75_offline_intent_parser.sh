#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/feature/offline/MONULocalDeviceCommandEngine.kt"
PARSER="$BASE/feature/offline/MONUOfflineCommandIntentParser.kt"

BACKUP=".monu-backups/level75"
LOG=".monu-logs/level75"

mkdir -p "$BACKUP" "$LOG"
mkdir -p "$(dirname "$PARSER")"

test -f "$ROUTER"
test -f "$ENGINE"

cp "$ROUTER" "$BACKUP/MONUOfflineCommandRouter.kt.backup"
cp "$ENGINE" "$BACKUP/MONULocalDeviceCommandEngine.kt.backup"

[ -f "$PARSER" ] && cp "$PARSER" "$BACKUP/MONUOfflineCommandIntentParser.kt.backup" || true

cat > "$PARSER" <<'KOTLIN'
package com.monu.mobile.feature.offline

enum class MONUOfflineCommandIntent {
    EMPTY,
    GREETING,
    HELP,
    STATUS,
    IDENTITY,
    TIME,
    DATE,
    LOCAL_STATUS,
    UNKNOWN
}

class MONUOfflineCommandIntentParser {

    fun parse(command: String): MONUOfflineCommandIntent {
        val normalized = command.trim().lowercase()

        return when {
            normalized.isBlank() ->
                MONUOfflineCommandIntent.EMPTY

            normalized.contains("hello") ||
                normalized.contains("hi monu") ->
                MONUOfflineCommandIntent.GREETING

            normalized.contains("help") ||
                normalized.contains("what can you do") ->
                MONUOfflineCommandIntent.HELP

            normalized.contains("who are you") ->
                MONUOfflineCommandIntent.IDENTITY

            normalized.contains("device status") ||
                normalized.contains("local status") ->
                MONUOfflineCommandIntent.LOCAL_STATUS

            normalized.contains("status") ->
                MONUOfflineCommandIntent.STATUS

            normalized.contains("time") ->
                MONUOfflineCommandIntent.TIME

            normalized.contains("date") ||
                normalized.contains("today") ->
                MONUOfflineCommandIntent.DATE

            else ->
                MONUOfflineCommandIntent.UNKNOWN
        }
    }
}
KOTLIN

python - <<'PY'
from pathlib import Path

router_path = Path(
    "app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandRouter.kt"
)

text = router_path.read_text()

parser_import = (
    "import com.monu.mobile.feature.offline.MONUOfflineCommandIntent\n"
    "import com.monu.mobile.feature.offline.MONUOfflineCommandIntentParser\n"
)

if "MONUOfflineCommandIntentParser" not in text:
    package_end = text.find("\n")
    if package_end == -1:
        raise SystemExit("FAIL: router package declaration missing")

    text = (
        text[:package_end + 1]
        + parser_import
        + text[package_end + 1:]
    )

if "private val intentParser" not in text:
    anchor = "    private val localDeviceCommandEngine ="
    pos = text.find(anchor)

    if pos == -1:
        raise SystemExit("FAIL: local engine anchor missing")

    injection = '''    private val intentParser =
        MONUOfflineCommandIntentParser()

'''

    text = text[:pos] + injection + text[pos:]

start = text.find("    fun canHandle(command: String): Boolean {")
end = text.find("\n    fun handle(command: String): String {", start)

if start == -1 or end == -1:
    raise SystemExit("FAIL: canHandle function boundaries missing")

new_can_handle = '''    fun canHandle(command: String): Boolean {
        return intentParser.parse(command) !=
            MONUOfflineCommandIntent.UNKNOWN
    }
'''

text = text[:start] + new_can_handle + text[end:]

start = text.find("    fun handle(command: String): String {")
if start == -1:
    raise SystemExit("FAIL: handle function missing")

brace_start = text.find("{", start)
depth = 0
end = None

for i in range(brace_start, len(text)):
    if text[i] == "{":
        depth += 1
    elif text[i] == "}":
        depth -= 1
        if depth == 0:
            end = i + 1
            break

if end is None:
    raise SystemExit("FAIL: could not locate handle function end")

new_handle = '''    fun handle(command: String): String {
        return when (intentParser.parse(command)) {
            MONUOfflineCommandIntent.EMPTY ->
                "Please say or type a command."

            MONUOfflineCommandIntent.GREETING ->
                "Hello. MONU is running locally in offline mode."

            MONUOfflineCommandIntent.HELP ->
                """
                MONU offline commands:
                • hello
                • help
                • status
                • who are you
                • time
                • date
                • device status
                """.trimIndent()

            MONUOfflineCommandIntent.STATUS ->
                "MONU local runtime is ready. Offline command system is active."

            MONUOfflineCommandIntent.IDENTITY ->
                "I am MONU, your personal AI assistant. I can operate with local offline capabilities."

            MONUOfflineCommandIntent.TIME,
            MONUOfflineCommandIntent.DATE,
            MONUOfflineCommandIntent.LOCAL_STATUS ->
                localDeviceCommandEngine.handle(command)

            MONUOfflineCommandIntent.UNKNOWN ->
                "I received your command, but this offline capability is not available yet."
        }
    }'''

text = text[:start] + new_handle + text[end:]

router_path.write_text(text)
PY

cat > level75_offline_intent_parser_test.sh <<'TEST'
#!/data/data/com.termux/files/usr/bin/bash
set -u

PARSER="app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandIntentParser.kt"
ROUTER="app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandRouter.kt"

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
echo " LEVEL 75 OFFLINE INTENT PARSER TEST"
echo "================================================"

check \
"$PARSER" \
'enum class MONUOfflineCommandIntent' \
"Offline intent enum exists"

check \
"$PARSER" \
'class MONUOfflineCommandIntentParser' \
"Dedicated intent parser exists"

check \
"$PARSER" \
'fun parse\(command: String\)' \
"Intent parsing function exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.GREETING' \
"Greeting intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.HELP' \
"Help intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.STATUS' \
"Status intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.TIME' \
"Time intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.DATE' \
"Date intent exists"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Unknown intent fallback exists"

check \
"$ROUTER" \
'private val intentParser' \
"Router owns centralized intent parser"

check \
"$ROUTER" \
'intentParser\.parse\(command\)' \
"Router delegates capability detection to parser"

check \
"$ROUTER" \
'when \(intentParser\.parse\(command\)\)' \
"Router dispatches using parsed intent"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.TIME' \
"Time intent delegates through router"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Unknown intent remains safe"

PARSER_COUNT=$(grep -c \
'class MONUOfflineCommandIntentParser' \
"$PARSER" 2>/dev/null || true)

if [ "$PARSER_COUNT" -eq 1 ]; then
    pass "Single intent parser authority"
else
    fail "Intent parser authority count is $PARSER_COUNT"
fi

echo "================================================"
echo " LEVEL 75 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 75 GOLDEN"
    echo "Centralized offline intent parsing verified"
else
    echo "LEVEL 75 NEEDS TARGETED REPAIR"
    exit 1
fi
TEST

chmod +x level75_offline_intent_parser_test.sh
./level75_offline_intent_parser_test.sh

{
    echo "LEVEL 75 OFFLINE INTENT PARSER MAP"
    echo "=================================="
    echo
    echo "PARSER:"
    grep -nE \
    'MONUOfflineCommandIntent|fun parse|GREETING|HELP|STATUS|TIME|DATE|UNKNOWN' \
    "$PARSER" || true

    echo
    echo "ROUTER:"
    grep -nE \
    'intentParser|MONUOfflineCommandIntent|fun canHandle|fun handle' \
    "$ROUTER" || true
} > "$LOG/offline_intent_parser_map.txt"

echo "================================================"
echo " LEVEL 75 COMPLETE"
echo "================================================"
echo "NEXT: LEVEL 76 - OFFLINE COMMAND EXECUTION AUDIT"
echo "================================================"
