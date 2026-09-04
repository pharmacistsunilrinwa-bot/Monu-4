#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"

BACKUP=".monu-backups/level72"
LOG=".monu-logs/level72"

mkdir -p "$BACKUP" "$LOG"
mkdir -p "$(dirname "$ROUTER")"

test -f "$CHAT"

cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"

if [ -f "$ROUTER" ]; then
    cp "$ROUTER" "$BACKUP/MONUOfflineCommandRouter.kt.backup"
fi

cat > "$ROUTER" <<'KOTLIN'
package com.monu.mobile.feature.offline

class MONUOfflineCommandRouter {

    fun canHandle(command: String): Boolean {
        val normalized = command.trim().lowercase()

        if (normalized.isBlank()) return true

        return normalized.contains("hello") ||
            normalized.contains("hi monu") ||
            normalized.contains("help") ||
            normalized.contains("status") ||
            normalized.contains("time") ||
            normalized.contains("who are you") ||
            normalized.contains("what can you do")
    }

    fun handle(command: String): String {
        val normalized = command.trim().lowercase()

        return when {
            normalized.isBlank() ->
                "Please say or type a command."

            normalized.contains("hello") ||
                normalized.contains("hi monu") ->
                "Hello. MONU is running locally in offline mode."

            normalized.contains("help") ||
                normalized.contains("what can you do") ->
                """
                MONU offline commands:
                • hello
                • help
                • status
                • who are you
                • time
                """.trimIndent()

            normalized.contains("status") ->
                "MONU local runtime is ready. Offline command system is active."

            normalized.contains("who are you") ->
                "I am MONU, your personal AI assistant. I can operate with local offline capabilities."

            normalized.contains("time") ->
                "Time queries will be handled by the local device utility system."

            else ->
                "I received your command, but this offline capability is not available yet."
        }
    }
}
KOTLIN

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

router_import = (
    "import com.monu.mobile.feature.offline.MONUOfflineCommandRouter\n"
)

if router_import not in text:
    package_end = text.find("\n")

    if package_end == -1:
        raise SystemExit("FAIL: package declaration missing")

    text = (
        text[:package_end + 1]
        + router_import
        + text[package_end + 1:]
    )

if "val offlineCommandRouter = remember" not in text:
    anchor = "    val context = LocalContext.current"

    if anchor not in text:
        raise SystemExit("FAIL: context anchor missing")

    injection = '''    val offlineCommandRouter = remember {
        MONUOfflineCommandRouter()
    }

'''

    text = text.replace(
        anchor,
        injection + anchor,
        1
    )

old = '''        val offlineResponse =
            buildOfflineCommandFallback(cleanCommand)'''

new = '''        val offlineResponse =
            offlineCommandRouter.handle(cleanCommand)'''

if old in text:
    text = text.replace(old, new, 1)

path.write_text(text)
PY

cat > level72_offline_command_router_test.sh <<'TEST'
#!/data/data/com.termux/files/usr/bin/bash
set -u

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
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
echo " LEVEL 72 OFFLINE COMMAND ROUTER TEST"
echo "================================================"

check \
"$ROUTER" \
'class MONUOfflineCommandRouter' \
"Dedicated offline router exists"

check \
"$ROUTER" \
'fun canHandle\(command: String\)' \
"Router capability detection exists"

check \
"$ROUTER" \
'fun handle\(command: String\): String' \
"Router command handler exists"

check \
"$ROUTER" \
'normalized\.contains\("hello"\)' \
"Router handles greeting"

check \
"$ROUTER" \
'normalized\.contains\("help"\)' \
"Router handles help"

check \
"$ROUTER" \
'normalized\.contains\("status"\)' \
"Router handles status"

check \
"$ROUTER" \
'normalized\.contains\("who are you"\)' \
"Router handles identity"

check \
"$CHAT" \
'import com\.monu\.mobile\.feature\.offline\.MONUOfflineCommandRouter' \
"Chat imports offline router"

check \
"$CHAT" \
'val offlineCommandRouter = remember' \
"Chat owns one router instance"

check \
"$CHAT" \
'offlineCommandRouter\.handle\(cleanCommand\)' \
"Fallback uses dedicated router"

COUNT=$(grep -c \
'class MONUOfflineCommandRouter' \
"$ROUTER" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single router authority"
else
    fail "Router authority count is $COUNT"
fi

echo "================================================"
echo " LEVEL 72 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 72 GOLDEN"
    echo "Dedicated offline command routing verified"
else
    echo "LEVEL 72 NEEDS TARGETED REPAIR"
    exit 1
fi
TEST

chmod +x level72_offline_command_router_test.sh
./level72_offline_command_router_test.sh

{
    echo "LEVEL 72 OFFLINE COMMAND ROUTER MAP"
    echo "==================================="
    echo
    echo "ROUTER:"
    grep -nE \
    'class MONUOfflineCommandRouter|fun canHandle|fun handle|hello|help|status' \
    "$ROUTER" || true

    echo
    echo "CHAT:"
    grep -nE \
    'MONUOfflineCommandRouter|offlineCommandRouter' \
    "$CHAT" || true
} > "$LOG/offline_command_router_map.txt"

echo "================================================"
echo " LEVEL 72 COMPLETE"
echo "================================================"
echo "NEXT: LEVEL 73 - LOCAL DEVICE COMMAND ENGINE"
echo "================================================"
