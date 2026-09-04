#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

PARSER="$BASE/feature/offline/MONUOfflineCommandIntentParser.kt"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/feature/offline/MONULocalDeviceCommandEngine.kt"
MATRIX="$BASE/feature/offline/MONUOfflineCommandCapabilityMatrix.kt"

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
echo " MONU MOBILE - LEVEL 78"
echo " OFFLINE COMMAND SCENARIO AUDIT"
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
    echo "LEVEL 78 NEEDS TARGETED REPAIR"
    exit 1
fi

echo
echo "[1/5] Parser scenario coverage"
echo "------------------------------------------------"

check \
"$PARSER" \
'normalized\.contains\("hello"\)' \
"Scenario: hello"

check \
"$PARSER" \
'normalized\.contains\("help"\)' \
"Scenario: help"

check \
"$PARSER" \
'normalized\.contains\("status"\)' \
"Scenario: status"

check \
"$PARSER" \
'normalized\.contains\("who are you"\)' \
"Scenario: identity"

check \
"$PARSER" \
'normalized\.contains\("time"\)' \
"Scenario: time"

check \
"$PARSER" \
'normalized\.contains\("date"\)' \
"Scenario: date"

check \
"$PARSER" \
'normalized\.contains\("today"\)' \
"Scenario: today"

check \
"$PARSER" \
'normalized\.contains\("device status"\)' \
"Scenario: device status"

check \
"$PARSER" \
'normalized\.isBlank\(\)' \
"Scenario: blank command"

check \
"$PARSER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Scenario: unknown command"

echo
echo "[2/5] Router execution scenarios"
echo "------------------------------------------------"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.GREETING' \
"Router executes greeting"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.HELP' \
"Router executes help"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.STATUS' \
"Router executes status"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.IDENTITY' \
"Router executes identity"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.TIME' \
"Router routes time"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.DATE' \
"Router routes date"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.LOCAL_STATUS' \
"Router routes local status"

check \
"$ROUTER" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Router handles unknown safely"

echo
echo "[3/5] Local execution scenarios"
echo "------------------------------------------------"

check \
"$ENGINE" \
'currentTime\(\)' \
"Local time execution exists"

check \
"$ENGINE" \
'currentDate\(\)' \
"Local date execution exists"

check \
"$ENGINE" \
'localRuntimeStatus\(\)' \
"Local status execution exists"

check \
"$ENGINE" \
'formatter\.format\(Date\(\)\)' \
"Local device clock execution exists"

echo
echo "[4/5] Capability ownership consistency"
echo "------------------------------------------------"

check \
"$MATRIX" \
'MONUOfflineCommandIntent\.GREETING' \
"Matrix covers greeting"

check \
"$MATRIX" \
'MONUOfflineCommandIntent\.TIME' \
"Matrix covers time"

check \
"$MATRIX" \
'MONUOfflineCommandIntent\.DATE' \
"Matrix covers date"

check \
"$MATRIX" \
'MONUOfflineCommandIntent\.LOCAL_STATUS' \
"Matrix covers local status"

check \
"$MATRIX" \
'MONUOfflineCommandIntent\.UNKNOWN' \
"Matrix covers unknown"

check \
"$MATRIX" \
'executionOwner = "Router"' \
"Matrix declares router ownership"

check \
"$MATRIX" \
'executionOwner = "LocalDeviceEngine"' \
"Matrix declares local engine ownership"

echo
echo "[5/5] Safety and authority audit"
echo "------------------------------------------------"

PARSER_COUNT=$(grep -c \
'class MONUOfflineCommandIntentParser' \
"$PARSER" 2>/dev/null || true)

if [ "$PARSER_COUNT" -eq 1 ]; then
    pass "Single parser authority"
else
    fail "Parser authority count is $PARSER_COUNT"
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

MATRIX_COUNT=$(grep -c \
'class MONUOfflineCommandCapabilityMatrix' \
"$MATRIX" 2>/dev/null || true)

if [ "$MATRIX_COUNT" -eq 1 ]; then
    pass "Single capability matrix authority"
else
    fail "Capability matrix authority count is $MATRIX_COUNT"
fi

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$PARSER" \
"$ROUTER" \
"$ENGINE" \
"$MATRIX" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical scenario placeholders"
else
    warn "Placeholder markers detected"
    echo "$PLACEHOLDERS"
fi

echo
echo "================================================"
echo " LEVEL 78 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 78 GOLDEN"
    echo "Offline command scenarios are structurally covered"
else
    echo "LEVEL 78 NEEDS TARGETED REPAIR"
    exit 1
fi
