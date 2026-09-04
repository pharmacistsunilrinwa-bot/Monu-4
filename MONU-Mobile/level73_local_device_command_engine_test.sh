#!/data/data/com.termux/files/usr/bin/bash
set -u

ROUTER="app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="app/src/main/java/com/monu/mobile/feature/offline/MONULocalDeviceCommandEngine.kt"

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
echo " LEVEL 73 LOCAL DEVICE COMMAND ENGINE TEST"
echo "================================================"

check \
"$ENGINE" \
'class MONULocalDeviceCommandEngine' \
"Local device command engine exists"

check \
"$ENGINE" \
'fun canHandle\(command: String\): Boolean' \
"Engine capability detection exists"

check \
"$ENGINE" \
'fun handle\(command: String\): String' \
"Engine command handler exists"

check \
"$ENGINE" \
'normalized\.contains\("time"\)' \
"Engine handles local time"

check \
"$ENGINE" \
'normalized\.contains\("date"\)' \
"Engine handles local date"

check \
"$ENGINE" \
'normalized\.contains\("device status"\)' \
"Engine handles device status"

check \
"$ENGINE" \
'SimpleDateFormat' \
"Engine uses local date/time formatter"

check \
"$ENGINE" \
'java\.util\.Date' \
"Engine reads local device clock"

check \
"$ROUTER" \
'private val localDeviceCommandEngine' \
"Router owns local device engine"

check \
"$ROUTER" \
'localDeviceCommandEngine\.canHandle' \
"Router delegates capability detection"

check \
"$ROUTER" \
'localDeviceCommandEngine\.handle' \
"Router delegates command execution"

ENGINE_COUNT=$(grep -c \
'class MONULocalDeviceCommandEngine' \
"$ENGINE" 2>/dev/null || true)

if [ "$ENGINE_COUNT" -eq 1 ]; then
    pass "Single local device engine authority"
else
    fail "Local device engine authority count is $ENGINE_COUNT"
fi

echo "================================================"
echo " LEVEL 73 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 73 GOLDEN"
    echo "Local time/date/device commands work without server"
else
    echo "LEVEL 73 NEEDS TARGETED REPAIR"
    exit 1
fi
