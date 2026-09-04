#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
BACKUP=".monu-backups/level71"
LOG=".monu-logs/level71"

mkdir -p "$BACKUP" "$LOG"

test -f "$CHAT"

cp "$CHAT" "$BACKUP/ChatScreen.kt.backup"

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)
text = path.read_text()

# Add a deterministic local fallback responder inside ChatScreen.
if "fun buildOfflineCommandFallback" not in text:
    anchor = "    val context = LocalContext.current"

    fallback = '''    fun buildOfflineCommandFallback(
        command: String
    ): String {
        val normalized = command.trim().lowercase()

        return when {
            normalized.isBlank() ->
                "Please say or type a command."

            normalized.contains("hello") ||
                normalized.contains("hi monu") ->
                "Hello. MONU is running in offline mode."

            normalized.contains("help") ->
                "Offline commands available: hello, help, status, time."

            normalized.contains("status") ->
                "MONU offline runtime is ready."

            normalized.contains("time") ->
                "Time information requires a connected knowledge source."

            else ->
                "I am currently offline. Your command was received: $command"
        }
    }

'''

    if anchor not in text:
        raise SystemExit(
            "FAIL: ChatScreen context anchor not found"
        )

    text = text.replace(
        anchor,
        fallback + anchor,
        1
    )

# Add a reusable local fallback execution path.
if "fun handleOfflineCommand" not in text:
    anchor = "    var voiceReady by remember"

    handler = '''    fun handleOfflineCommand(
        command: String
    ) {
        val cleanCommand = command.trim()

        if (cleanCommand.isBlank()) return

        val offlineResponse =
            buildOfflineCommandFallback(cleanCommand)

        messages = messages + ChatMessage(
            id = UUID.randomUUID().toString(),
            role = MessageRole.ASSISTANT,
            content = offlineResponse
        )
    }

'''

    if anchor not in text:
        raise SystemExit(
            "FAIL: ChatScreen state anchor not found"
        )

    text = text.replace(
        anchor,
        handler + anchor,
        1
    )

# Ensure voice-result failures can fall back locally if knowledge search fails.
old = '''                        } finally {
                            searching = false
                        }'''

new = '''                        } catch (error: Exception) {
                            handleOfflineCommand(cleanCommand)
                        } finally {
                            searching = false
                        }'''

if "handleOfflineCommand(cleanCommand)" not in text:
    if old in text:
        text = text.replace(old, new, 1)

path.write_text(text)
PY

cat > level71_offline_command_fallback_test.sh <<'TEST'
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
    local pattern="$1"
    local label="$2"

    if grep -qE "$pattern" "$CHAT" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

echo "================================================"
echo " LEVEL 71 OFFLINE COMMAND FALLBACK TEST"
echo "================================================"

check \
'fun buildOfflineCommandFallback' \
"Offline fallback builder exists"

check \
'fun handleOfflineCommand' \
"Offline command handler exists"

check \
'command\.trim\(\)\.lowercase\(\)' \
"Offline commands normalized"

check \
'normalized\.isBlank\(\)' \
"Blank command safety exists"

check \
'normalized\.contains\("hello"\)' \
"Local greeting command exists"

check \
'normalized\.contains\("help"\)' \
"Local help command exists"

check \
'normalized\.contains\("status"\)' \
"Local status command exists"

check \
'MONU offline runtime is ready' \
"Offline runtime response exists"

check \
'role = MessageRole\.ASSISTANT' \
"Offline response enters assistant channel"

check \
'handleOfflineCommand\(cleanCommand\)' \
"Fallback is connected to command flow"

COUNT=$(grep -c 'fun buildOfflineCommandFallback' "$CHAT" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single offline fallback authority"
else
    fail "Offline fallback authority count is $COUNT"
fi

echo "================================================"
echo " LEVEL 71 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 71 GOLDEN"
    echo "Basic offline command fallback verified"
else
    echo "LEVEL 71 NEEDS TARGETED REPAIR"
    exit 1
fi
TEST

chmod +x level71_offline_command_fallback_test.sh
./level71_offline_command_fallback_test.sh

{
    echo "LEVEL 71 OFFLINE COMMAND FALLBACK MAP"
    echo "====================================="
    grep -nE \
    'buildOfflineCommandFallback|handleOfflineCommand|offline mode|offline runtime' \
    "$CHAT" || true
} > "$LOG/offline_command_fallback_map.txt"

echo "================================================"
echo " LEVEL 71 COMPLETE"
echo "================================================"
echo "NEXT: LEVEL 72 - OFFLINE COMMAND ROUTER"
echo "================================================"
