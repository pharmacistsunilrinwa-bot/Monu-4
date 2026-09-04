#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

CHAT="$BASE/ui/screens/ChatScreen.kt"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/feature/offline/MONULocalDeviceCommandEngine.kt"

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
echo " MONU MOBILE - LEVEL 74"
echo " OFFLINE COMMAND INTEGRATION AUDIT"
echo " NO APK BUILD"
echo "================================================"

test -f "$CHAT" || {
    echo "[FAIL] ChatScreen.kt missing"
    exit 1
}

test -f "$ROUTER" || {
    echo "[FAIL] MONUOfflineCommandRouter.kt missing"
    exit 1
}

test -f "$ENGINE" || {
    echo "[FAIL] MONULocalDeviceCommandEngine.kt missing"
    exit 1
}

echo
echo "[1/8] Chat integration"
echo "------------------------------------------------"

check \
"$CHAT" \
'import com\.monu\.mobile\.feature\.offline\.MONUOfflineCommandRouter' \
"Chat imports offline router"

check \
"$CHAT" \
'val offlineCommandRouter = remember' \
"Chat owns router instance"

check \
"$CHAT" \
'fun handleOfflineCommand' \
"Chat offline handler exists"

check \
"$CHAT" \
'offlineCommandRouter\.handle\(cleanCommand\)' \
"Chat delegates command to router"

check \
"$CHAT" \
'role = MessageRole\.ASSISTANT' \
"Offline result enters assistant channel"

echo
echo "[2/8] Router authority"
echo "------------------------------------------------"

check \
"$ROUTER" \
'class MONUOfflineCommandRouter' \
"Dedicated router exists"

check \
"$ROUTER" \
'fun canHandle\(command: String\): Boolean' \
"Router capability detection exists"

check \
"$ROUTER" \
'fun handle\(command: String\): String' \
"Router execution function exists"

check \
"$ROUTER" \
'private val localDeviceCommandEngine' \
"Router owns local engine"

echo
echo "[3/8] Router delegation"
echo "------------------------------------------------"

check \
"$ROUTER" \
'localDeviceCommandEngine\.canHandle\(normalized\)' \
"Router checks local engine capability"

check \
"$ROUTER" \
'return localDeviceCommandEngine\.handle\(normalized\)' \
"Router delegates execution"

check \
"$ROUTER" \
'normalized\.contains\("hello"\)' \
"Router retains greeting capability"

check \
"$ROUTER" \
'normalized\.contains\("help"\)' \
"Router retains help capability"

check \
"$ROUTER" \
'normalized\.contains\("status"\)' \
"Router retains status capability"

echo
echo "[4/8] Local device engine"
echo "------------------------------------------------"

check \
"$ENGINE" \
'class MONULocalDeviceCommandEngine' \
"Local device engine exists"

check \
"$ENGINE" \
'fun canHandle\(command: String\): Boolean' \
"Engine capability detection exists"

check \
"$ENGINE" \
'fun handle\(command: String\): String' \
"Engine execution function exists"

check \
"$ENGINE" \
'normalized\.contains\("time"\)' \
"Engine supports time"

check \
"$ENGINE" \
'normalized\.contains\("date"\)' \
"Engine supports date"

check \
"$ENGINE" \
'normalized\.contains\("today"\)' \
"Engine supports today"

echo
echo "[5/8] Device utility independence"
echo "------------------------------------------------"

check \
"$ENGINE" \
'SimpleDateFormat' \
"Uses local formatter"

check \
"$ENGINE" \
'java\.util\.Date' \
"Uses local device clock"

check \
"$ENGINE" \
'Locale\.getDefault\(\)' \
"Uses device locale"

check \
"$ENGINE" \
'Current local time' \
"Local time response exists"

check \
"$ENGINE" \
'Today' \
"Local date response exists"

echo
echo "[6/8] Offline safety"
echo "------------------------------------------------"

check \
"$ROUTER" \
'normalized\.isBlank\(\)' \
"Blank command safety exists"

check \
"$ENGINE" \
'command\.trim\(\)\.lowercase\(\)' \
"Device commands normalized"

check \
"$ROUTER" \
'I received your command' \
"Unknown command fallback exists"

check \
"$CHAT" \
'handleOfflineCommand\(cleanCommand\)' \
"Command flow has offline fallback connection"

echo
echo "[7/8] Ownership and duplication audit"
echo "------------------------------------------------"

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

CHAT_ROUTER_COUNT=$(grep -c \
'val offlineCommandRouter = remember' \
"$CHAT" 2>/dev/null || true)

if [ "$CHAT_ROUTER_COUNT" -eq 1 ]; then
    pass "Single Chat router owner"
else
    warn "Chat router owner count is $CHAT_ROUTER_COUNT"
fi

echo
echo "[8/8] Critical placeholder audit"
echo "------------------------------------------------"

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$CHAT" \
"$ROUTER" \
"$ENGINE" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical offline command placeholders"
else
    warn "Placeholder markers detected"
    echo "$PLACEHOLDERS"
fi

echo
echo "================================================"
echo " LEVEL 74 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 74 GOLDEN"
    echo "CHAT -> ROUTER -> LOCAL ENGINE integration verified"
    echo "Offline command architecture is structurally connected"
else
    echo "LEVEL 74 NEEDS TARGETED REPAIR"
    exit 1
fi
