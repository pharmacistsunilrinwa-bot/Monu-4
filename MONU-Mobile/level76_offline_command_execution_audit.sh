#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/feature/offline/MONULocalDeviceCommandEngine.kt"
PARSER="$BASE/feature/offline/MONUOfflineCommandIntentParser.kt"

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

echo "================================================"
echo " MONU MOBILE - LEVEL 76"
echo " OFFLINE COMMAND EXECUTION AUDIT"
echo " NO APK BUILD"
echo "================================================"

for file in "$CHAT" "$ROUTER" "$ENGINE" "$PARSER"; do
    if [ ! -f "$file" ]; then
        fail "Required file missing: $file"
    fi
done

if [ "$FAIL" -ne 0 ]; then
    echo "LEVEL 76 NEEDS TARGETED REPAIR"
    exit 1
fi

echo
echo "[1/8] Intent parser integrity"
echo "------------------------------------------------"

check "$PARSER" \
'enum class MONUOfflineCommandIntent' \
"Intent enum exists"

check "$PARSER" \
'class MONUOfflineCommandIntentParser' \
"Dedicated parser exists"

check "$PARSER" \
'fun parse\(command: String\)' \
"Parser execution function exists"

check "$PARSER" \
'MONUOfflineCommandIntent\.EMPTY' \
"Empty intent supported"

check "$PARSER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Unknown intent supported"

echo
echo "[2/8] Intent coverage"
echo "------------------------------------------------"

for intent in GREETING HELP STATUS IDENTITY TIME DATE LOCAL_STATUS; do
    check "$PARSER" \
    "MONUOfflineCommandIntent\\.$intent" \
    "Intent supported: $intent"
done

echo
echo "[3/8] Router ownership"
echo "------------------------------------------------"

check "$ROUTER" \
'class MONUOfflineCommandRouter' \
"Dedicated router exists"

check "$ROUTER" \
'private val intentParser' \
"Router owns intent parser"

check "$ROUTER" \
'private val localDeviceCommandEngine' \
"Router owns local device engine"

check "$ROUTER" \
'fun canHandle\(command: String\): Boolean' \
"Router capability function exists"

check "$ROUTER" \
'fun handle\(command: String\): String' \
"Router execution function exists"

echo
echo "[4/8] Parser to router execution"
echo "------------------------------------------------"

check "$ROUTER" \
'intentParser\.parse\(command\)' \
"Router asks parser for command intent"

check "$ROUTER" \
'when \(intentParser\.parse\(command\)\)' \
"Router dispatches by parsed intent"

check "$ROUTER" \
'!=[[:space:]]*MONUOfflineCommandIntent\.UNKNOWN' \
"Capability detection rejects unknown intent"

echo
echo "[5/8] Local engine delegation"
echo "------------------------------------------------"

check "$ROUTER" \
'MONUOfflineCommandIntent\.TIME' \
"Router recognizes time intent"

check "$ROUTER" \
'MONUOfflineCommandIntent\.DATE' \
"Router recognizes date intent"

check "$ROUTER" \
'MONUOfflineCommandIntent\.LOCAL_STATUS' \
"Router recognizes local status intent"

check "$ROUTER" \
'localDeviceCommandEngine\.handle\(command\)' \
"Router delegates device execution"

echo
echo "[6/8] Device command independence"
echo "------------------------------------------------"

check "$ENGINE" \
'class MONULocalDeviceCommandEngine' \
"Local engine exists"

check "$ENGINE" \
'fun canHandle\(command: String\): Boolean' \
"Local engine capability detection exists"

check "$ENGINE" \
'fun handle\(command: String\): String' \
"Local engine execution exists"

check "$ENGINE" \
'SimpleDateFormat' \
"Local clock formatting exists"

check "$ENGINE" \
'java\.util\.Date' \
"Local device clock source exists"

check "$ENGINE" \
'Locale\.getDefault\(\)' \
"Device locale support exists"

echo
echo "[7/8] Chat execution integration"
echo "------------------------------------------------"

check "$CHAT" \
'import com\.monu\.mobile\.feature\.offline\.MONUOfflineCommandRouter' \
"Chat imports router"

check "$CHAT" \
'val offlineCommandRouter = remember' \
"Chat owns router"

check "$CHAT" \
'fun handleOfflineCommand' \
"Chat offline handler exists"

check "$CHAT" \
'offlineCommandRouter\.handle\(cleanCommand\)' \
"Chat executes router command"

check "$CHAT" \
'role = MessageRole\.ASSISTANT' \
"Offline response reaches assistant channel"

echo
echo "[8/8] Architecture ownership and placeholder audit"
echo "------------------------------------------------"

PARSER_COUNT=$(grep -c \
'class MONUOfflineCommandIntentParser' \
"$PARSER" 2>/dev/null || true)

if [ "$PARSER_COUNT" -eq 1 ]; then
    pass "Single intent parser authority"
else
    fail "Intent parser authority count is $PARSER_COUNT"
fi

ROUTER_COUNT=$(grep -c \
'class MONUOfflineCommandRouter' \
"$ROUTER" 2>/dev/null || true)

if [ "$ROUTER_COUNT" -eq 1 ]; then
    pass "Single router authority"
else
    fail "Router authority count is $ROUTER_COUNT"
fi

ENGINE_COUNT=$(grep -c \
'class MONULocalDeviceCommandEngine' \
"$ENGINE" 2>/dev/null || true)

if [ "$ENGINE_COUNT" -eq 1 ]; then
    pass "Single local engine authority"
else
    fail "Local engine authority count is $ENGINE_COUNT"
fi

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$CHAT" "$ROUTER" "$ENGINE" "$PARSER" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical offline execution placeholders"
else
    warn "Placeholder markers detected"
    echo "$PLACEHOLDERS"
fi

echo
echo "================================================"
echo " LEVEL 76 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 76 GOLDEN"
    echo "CHAT -> ROUTER -> INTENT -> LOCAL EXECUTION verified"
    echo "Offline command execution architecture is structurally sound"
else
    echo "LEVEL 76 NEEDS TARGETED REPAIR"
    exit 1
fi
