#!/data/data/com.termux/files/usr/bin/bash
set -u

MATRIX="app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandCapabilityMatrix.kt"

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

    if grep -qE "$pattern" "$MATRIX" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

echo "================================================"
echo " LEVEL 77 OFFLINE COMMAND CAPABILITY MATRIX TEST"
echo "================================================"

check \
'data class MONUOfflineCommandCapability' \
"Capability data model exists"

check \
'class MONUOfflineCommandCapabilityMatrix' \
"Capability matrix exists"

check \
'fun capabilities\(\): List<MONUOfflineCommandCapability>' \
"Capability list function exists"

check \
'fun ownerFor\(' \
"Capability owner lookup exists"

check \
'fun supports\(' \
"Capability support lookup exists"

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
    "MONUOfflineCommandIntent\\.$intent" \
    "Matrix covers intent: $intent"
done

check \
'executionOwner = "Router"' \
"Router ownership exists"

check \
'executionOwner = "LocalDeviceEngine"' \
"Local device engine ownership exists"

COUNT=$(grep -c \
'class MONUOfflineCommandCapabilityMatrix' \
"$MATRIX" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single capability matrix authority"
else
    fail "Capability matrix authority count is $COUNT"
fi

echo "================================================"
echo " LEVEL 77 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 77 GOLDEN"
    echo "Offline command capability ownership matrix verified"
else
    echo "LEVEL 77 NEEDS TARGETED REPAIR"
    exit 1
fi
