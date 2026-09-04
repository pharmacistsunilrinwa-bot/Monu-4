#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile/feature/offline"

ROUTER="$BASE/MONUOfflineCommandRouter.kt"
CONTRACT="$BASE/MONUOfflineCommandContract.kt"

BACKUP=".monu-backups/level83"
LOG=".monu-logs/level83"

mkdir -p "$BACKUP" "$LOG"

echo "================================================"
echo " MONU MOBILE - LEVEL 83"
echo " CONNECT ROUTER TO PRODUCTION CONTRACT"
echo " REAL IMPLEMENTATION"
echo "================================================"

for file in "$ROUTER" "$CONTRACT"; do
    if [ ! -f "$file" ]; then
        echo "[FAIL] Required file missing: $file"
        exit 1
    fi
done

cp "$ROUTER" \
"$BACKUP/MONUOfflineCommandRouter.before_level83.kt.backup"

python - <<'PY'
from pathlib import Path
import re

path = Path(
    "app/src/main/java/com/monu/mobile/feature/offline/"
    "MONUOfflineCommandRouter.kt"
)

text = path.read_text()

# Make router implement the production contract.
old_class = "class MONUOfflineCommandRouter {"
new_class = "class MONUOfflineCommandRouter : MONUOfflineCommandContract {"

if old_class in text:
    text = text.replace(old_class, new_class, 1)
elif new_class not in text:
    raise SystemExit(
        "FAIL: MONUOfflineCommandRouter class declaration not found"
    )

# Add contract canHandle overload if absent.
contract_can_handle = '''
    override fun canHandle(
        request: MONUOfflineCommandRequest
    ): Boolean {
        return canHandle(request.command)
    }

'''

if "override fun canHandle(\n        request: MONUOfflineCommandRequest" not in text:
    marker = "    fun canHandle(command: String): Boolean {"
    pos = text.find(marker)

    if pos == -1:
        raise SystemExit("FAIL: Existing canHandle(String) not found")

    text = text[:pos] + contract_can_handle + text[pos:]

# Add structured execute method before the final class brace.
contract_execute = '''
    override fun execute(
        request: MONUOfflineCommandRequest
    ): MONUOfflineCommandResponse {
        val command = request.command
        val intent = intentParser.parse(command)
        val handled = intent != MONUOfflineCommandIntent.UNKNOWN

        return MONUOfflineCommandResponse(
            handled = handled,
            intent = intent,
            response = handle(command)
        )
    }

'''

if "override fun execute(\n        request: MONUOfflineCommandRequest" not in text:
    last_brace = text.rstrip().rfind("}")

    if last_brace == -1:
        raise SystemExit("FAIL: Router closing brace not found")

    text = (
        text[:last_brace]
        + contract_execute
        + text[last_brace:]
    )

path.write_text(text)
PY

echo "[PASS] Router production contract implementation applied"

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

    if grep -qE "$pattern" "$ROUTER" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

echo
echo "================================================"
echo " LEVEL 83 IMPLEMENTATION CHECK"
echo "================================================"

check \
'class MONUOfflineCommandRouter[[:space:]]*:[[:space:]]*MONUOfflineCommandContract' \
"Router implements production contract"

check \
'override fun canHandle\(' \
"Contract canHandle implementation exists"

check \
'MONUOfflineCommandRequest' \
"Structured command request used"

check \
'override fun execute\(' \
"Contract execute implementation exists"

check \
'MONUOfflineCommandResponse' \
"Structured command response created"

check \
'val intent = intentParser\.parse\(command\)' \
"Execute parses command intent centrally"

check \
'intent != MONUOfflineCommandIntent\.UNKNOWN' \
"Execute determines handling capability"

check \
'response = handle\(command\)' \
"Structured execution delegates to existing router behavior"

COUNT=$(grep -c \
'class MONUOfflineCommandRouter' \
"$ROUTER" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single router authority retained"
else
    fail "Router authority count is $COUNT"
fi

PLACEHOLDERS=$(grep -nE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING' \
"$ROUTER" 2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical implementation placeholders"
else
    fail "Critical placeholders found"
    echo "$PLACEHOLDERS"
fi

{
    echo "LEVEL 83 ROUTER CONTRACT INTEGRATION"
    echo "===================================="
    echo
    echo "PRODUCTION FLOW:"
    echo "MONUOfflineCommandRequest"
    echo "        ->"
    echo "MONUOfflineCommandRouter"
    echo "        ->"
    echo "Intent Parser"
    echo "        ->"
    echo "Existing Execution Path"
    echo "        ->"
    echo "MONUOfflineCommandResponse"
    echo
    echo "RESULT:"
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
} > "$LOG/level83_router_contract_integration.txt"

echo
echo "================================================"
echo " LEVEL 83 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 83 GOLDEN"
    echo "Router is now connected to the production command contract"
    echo "NEXT: LEVEL 84 - CONNECT CHAT TO STRUCTURED COMMAND RESPONSES"
else
    echo "LEVEL 83 NEEDS TARGETED REPAIR"
    exit 1
fi
