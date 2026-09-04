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
