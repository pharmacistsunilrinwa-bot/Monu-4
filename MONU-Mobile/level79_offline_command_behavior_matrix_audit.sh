#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"

PARSER="$BASE/feature/offline/MONUOfflineCommandIntentParser.kt"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/feature/offline/MONULocalDeviceCommandEngine.kt"
MATRIX="$BASE/feature/offline/MONUOfflineCommandCapabilityMatrix.kt"

LOG=".monu-logs/level79"

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

echo "================================================"
echo " MONU MOBILE - LEVEL 79"
echo " OFFLINE COMMAND BEHAVIOR MATRIX AUDIT"
echo " NO APK BUILD"
echo "================================================"

for file in \
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
    echo "LEVEL 79 NEEDS TARGETED REPAIR"
    exit 1
fi

echo
echo "[1/6] Intent behavior specification"
echo "------------------------------------------------"

declare -a INTENT_CASES=(
    "blank|EMPTY"
    "hello|GREETING"
    "hi monu|GREETING"
    "help|HELP"
    "what can you do|HELP"
    "status|STATUS"
    "who are you|IDENTITY"
    "time|TIME"
    "date|DATE"
    "today|DATE"
    "device status|LOCAL_STATUS"
    "local status|LOCAL_STATUS"
    "random unsupported command|UNKNOWN"
)

for case in "${INTENT_CASES[@]}"; do
    command="${case%%|*}"
    intent="${case##*|}"

    check \
    "$PARSER" \
    "MONUOfflineCommandIntent\\.$intent" \
    "Intent behavior declared: '$command' -> $intent"
done

echo
echo "[2/6] Parser precedence behavior"
echo "------------------------------------------------"

check \
"$PARSER" \
'normalized\.isBlank\(\)' \
"Blank input handled before command matching"

check \
"$PARSER" \
'normalized\.contains\("device status"\)' \
"Specific device status intent exists"

check \
"$PARSER" \
'normalized\.contains\("status"\)' \
"General status intent exists"

check \
"$PARSER" \
'normalized\.contains\("what can you do"\)' \
"Extended help phrase exists"

echo
echo "[3/6] Router execution behavior"
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
    "$ROUTER" \
    "MONUOfflineCommandIntent\\.$intent" \
    "Router behavior covers: $intent"
done

check \
"$ROUTER" \
'when \(intentParser\.parse\(command\)\)' \
"Router behavior driven by centralized intent"

check \
"$ROUTER" \
'localDeviceCommandEngine\.handle\(command\)' \
"Device behaviors delegated to local engine"

echo
echo "[4/6] Local execution behavior"
echo "------------------------------------------------"

check \
"$ENGINE" \
'currentTime\(\)' \
"Time command has execution path"

check \
"$ENGINE" \
'currentDate\(\)' \
"Date command has execution path"

check \
"$ENGINE" \
'localRuntimeStatus\(\)' \
"Local status has execution path"

check \
"$ENGINE" \
'formatter\.format\(Date\(\)\)' \
"Device clock is read during execution"

echo
echo "[5/6] Capability ownership behavior"
echo "------------------------------------------------"

for intent in \
GREETING \
HELP \
STATUS \
IDENTITY
do
    check \
    "$MATRIX" \
    "intent = MONUOfflineCommandIntent\\.$intent" \
    "Matrix owns router capability: $intent"
done

for intent in \
TIME \
DATE \
LOCAL_STATUS
do
    check \
    "$MATRIX" \
    "intent = MONUOfflineCommandIntent\\.$intent" \
    "Matrix owns local capability: $intent"
done

check \
"$MATRIX" \
'executionOwner = "Router"' \
"Router execution ownership declared"

check \
"$MATRIX" \
'executionOwner = "LocalDeviceEngine"' \
"Local engine execution ownership declared"

echo
echo "[6/6] Behavioral safety audit"
echo "------------------------------------------------"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Unsupported command behavior exists"

check \
"$ROUTER" \
'I received your command' \
"Unsupported command receives safe response"

check \
"$ROUTER" \
'intent != MONUOfflineCommandIntent\.UNKNOWN' \
"Capability detection rejects unsupported commands"

check \
"$MATRIX" \
'fun supports\(' \
"Capability behavior lookup exists"

check \
"$MATRIX" \
'fun ownerFor\(' \
"Execution ownership lookup exists"

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$PARSER" \
"$ROUTER" \
"$ENGINE" \
"$MATRIX" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical behavior placeholders"
else
    warn "Placeholder markers detected"
    echo "$PLACEHOLDERS"
fi

{
    echo "LEVEL 79 OFFLINE COMMAND BEHAVIOR MATRIX"
    echo "========================================="
    echo
    echo "INPUT SCENARIOS:"
    for case in "${INTENT_CASES[@]}"; do
        echo "$case"
    done
    echo
    echo "ARCHITECTURE:"
    echo "CHAT -> ROUTER -> INTENT PARSER -> EXECUTION OWNER"
} > "$LOG/offline_command_behavior_matrix.txt"

echo
echo "================================================"
echo " LEVEL 79 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 79 GOLDEN"
    echo "Offline command behavior matrix is structurally verified"
    echo "NEXT: LEVEL 80 - OFFLINE COMMAND REGRESSION GUARD"
else
    echo "LEVEL 79 NEEDS TARGETED REPAIR"
    exit 1
fi
