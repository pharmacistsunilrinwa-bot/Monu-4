#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

CHAT="$BASE/ui/screens/ChatScreen.kt"
PARSER="$BASE/feature/offline/MONUOfflineCommandIntentParser.kt"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/feature/offline/MONULocalDeviceCommandEngine.kt"
MATRIX="$BASE/feature/offline/MONUOfflineCommandCapabilityMatrix.kt"

LOG=".monu-logs/level80"
mkdir -p "$LOG"

PASS=0
FAIL=0
WARN=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

warn() {
    echo "[WARN] $1"
    WARN=$((WARN + 1))
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

count_exactly_one() {
    local file="$1"
    local pattern="$2"
    local label="$3"

    local count
    count=$(grep -cE "$pattern" "$file" 2>/dev/null || true)

    if [ "$count" -eq 1 ]; then
        pass "$label"
    else
        fail "$label (count=$count)"
    fi
}

echo "================================================"
echo " MONU MOBILE - LEVEL 80"
echo " OFFLINE COMMAND REGRESSION GUARD"
echo " NO APK BUILD"
echo "================================================"

for file in \
"$CHAT" \
"$PARSER" \
"$ROUTER" \
"$ENGINE" \
"$MATRIX"
do
    if [ ! -f "$file" ]; then
        fail "Required file missing: $file"
    fi
done

if [ "$FAIL" -ne 0 ]; then
    echo "LEVEL 80 NEEDS TARGETED REPAIR"
    exit 1
fi

echo
echo "[1/7] Authority regression guard"
echo "------------------------------------------------"

count_exactly_one \
"$PARSER" \
'^class MONUOfflineCommandIntentParser' \
"Exactly one intent parser authority"

count_exactly_one \
"$ROUTER" \
'^class MONUOfflineCommandRouter' \
"Exactly one router authority"

count_exactly_one \
"$ENGINE" \
'^class MONULocalDeviceCommandEngine' \
"Exactly one local engine authority"

count_exactly_one \
"$MATRIX" \
'^class MONUOfflineCommandCapabilityMatrix' \
"Exactly one capability matrix authority"

echo
echo "[2/7] Intent regression guard"
echo "------------------------------------------------"

for intent in \
EMPTY \
GREETING \
HELP \
STATUS \
IDENTITY \
TIME \
DATE \
LOCAL_STATUS \
UNKNOWN
do
    check \
    "$PARSER" \
    "MONUOfflineCommandIntent\\.$intent" \
    "Parser retains intent: $intent"
done

echo
echo "[3/7] Parser precedence regression guard"
echo "------------------------------------------------"

check \
"$PARSER" \
'normalized\.isBlank\(\)' \
"Blank input protection retained"

check \
"$PARSER" \
'normalized\.contains\("device status"\)' \
"Specific device status detection retained"

check \
"$PARSER" \
'normalized\.contains\("local status"\)' \
"Specific local status detection retained"

check \
"$PARSER" \
'normalized\.contains\("status"\)' \
"General status detection retained"

check \
"$PARSER" \
'normalized\.contains\("time"\)' \
"Time detection retained"

check \
"$PARSER" \
'normalized\.contains\("date"\)' \
"Date detection retained"

check \
"$PARSER" \
'normalized\.contains\("today"\)' \
"Today detection retained"

echo
echo "[4/7] Router regression guard"
echo "------------------------------------------------"

check \
"$ROUTER" \
'private val intentParser' \
"Router retains parser ownership"

check \
"$ROUTER" \
'private val localDeviceCommandEngine' \
"Router retains engine ownership"

check \
"$ROUTER" \
'fun canHandle\(command: String\): Boolean' \
"Router capability function retained"

check \
"$ROUTER" \
'fun handle\(command: String\): String' \
"Router execution function retained"

check \
"$ROUTER" \
'intentParser\.parse\(command\)' \
"Router still parses centrally"

check \
"$ROUTER" \
'intent != MONUOfflineCommandIntent\.UNKNOWN' \
"Unknown commands still rejected"

check \
"$ROUTER" \
'when \(intentParser\.parse\(command\)\)' \
"Router dispatch remains intent driven"

check \
"$ROUTER" \
'localDeviceCommandEngine\.handle\(command\)' \
"Local execution delegation retained"

echo
echo "[5/7] Capability ownership regression guard"
echo "------------------------------------------------"

for intent in \
GREETING \
HELP \
STATUS \
IDENTITY \
TIME \
DATE \
LOCAL_STATUS \
UNKNOWN
do
    check \
    "$MATRIX" \
    "intent = MONUOfflineCommandIntent\\.$intent" \
    "Matrix retains capability: $intent"
done

check \
"$MATRIX" \
'executionOwner = "Router"' \
"Router ownership retained"

check \
"$MATRIX" \
'executionOwner = "LocalDeviceEngine"' \
"Local engine ownership retained"

check \
"$MATRIX" \
'fun ownerFor\(' \
"Ownership lookup retained"

check \
"$MATRIX" \
'fun supports\(' \
"Capability lookup retained"

echo
echo "[6/7] Chat integration regression guard"
echo "------------------------------------------------"

check \
"$CHAT" \
'import com\.monu\.mobile\.feature\.offline\.MONUOfflineCommandRouter' \
"Chat router import retained"

check \
"$CHAT" \
'val offlineCommandRouter = remember' \
"Chat router ownership retained"

check \
"$CHAT" \
'fun handleOfflineCommand' \
"Offline handler retained"

check \
"$CHAT" \
'offlineCommandRouter\.handle\(cleanCommand\)' \
"Chat router execution retained"

check \
"$CHAT" \
'role = MessageRole\.ASSISTANT' \
"Assistant response channel retained"

echo
echo "[7/7] Placeholder and architecture safety guard"
echo "------------------------------------------------"

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$CHAT" \
"$PARSER" \
"$ROUTER" \
"$ENGINE" \
"$MATRIX" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical offline regression placeholders"
else
    warn "Placeholder markers detected"
    echo "$PLACEHOLDERS"
fi

{
    echo "LEVEL 80 OFFLINE COMMAND REGRESSION GUARD MAP"
    echo "=============================================="
    echo
    echo "ARCHITECTURE:"
    echo "CHAT -> ROUTER -> INTENT PARSER -> EXECUTION OWNER"
    echo
    echo "AUTHORITIES:"
    echo "Parser : $PARSER"
    echo "Router : $ROUTER"
    echo "Engine : $ENGINE"
    echo "Matrix : $MATRIX"
    echo
    echo "RESULT:"
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo "WARN=$WARN"
} > "$LOG/offline_command_regression_guard_map.txt"

echo
echo "================================================"
echo " LEVEL 80 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 80 GOLDEN"
    echo "Offline command architecture regression guard verified"
    echo "Levels 74-80 foundation is protected structurally"
    echo "NEXT: LEVEL 81 - OFFLINE COMMAND FUNCTIONAL TEST HARNESS"
else
    echo "LEVEL 80 NEEDS TARGETED REPAIR"
    exit 1
fi
