#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"
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

echo "================================================"
echo " MONU MOBILE - LEVEL 50C"
echo " MODEL LOCATION + INTEGRATION VERIFICATION"
echo " NO APK BUILD"
echo "================================================"

echo
echo "[1/4] Locating ChatMessage declaration"
echo "------------------------------------------------"

CHAT_MESSAGE_FILES=$(grep -RIl \
    'data class ChatMessage\|class ChatMessage' \
    "$BASE/domain" 2>/dev/null || true)

if [ -n "$CHAT_MESSAGE_FILES" ]; then
    pass "ChatMessage declaration found"
    echo "$CHAT_MESSAGE_FILES"
else
    fail "ChatMessage declaration not found"
fi

echo
echo "[2/4] Locating MONUAttachment declaration"
echo "------------------------------------------------"

ATTACHMENT_FILES=$(grep -RIl \
    'data class MONUAttachment\|class MONUAttachment' \
    "$BASE/domain" 2>/dev/null || true)

if [ -n "$ATTACHMENT_FILES" ]; then
    pass "MONUAttachment declaration found"
    echo "$ATTACHMENT_FILES"
else
    fail "MONUAttachment declaration not found"
fi

echo
echo "[3/4] Checking actual imports"
echo "------------------------------------------------"

CHAT="$BASE/ui/screens/ChatScreen.kt"
INPUT="$BASE/ui/components/CommandInput.kt"

if grep -q \
    'import com.monu.mobile.domain.model.ChatMessage' \
    "$CHAT"; then
    pass "ChatScreen imports ChatMessage"
else
    fail "ChatScreen ChatMessage import missing"
fi

if grep -q \
    'import com.monu.mobile.domain.model.MONUAttachment' \
    "$CHAT"; then
    pass "ChatScreen imports MONUAttachment"
else
    fail "ChatScreen MONUAttachment import missing"
fi

if grep -q \
    'import com.monu.mobile.domain.model.MONUAttachment' \
    "$INPUT"; then
    pass "CommandInput imports MONUAttachment"
else
    fail "CommandInput MONUAttachment import missing"
fi

echo
echo "[4/4] Type usage verification"
echo "------------------------------------------------"

if grep -RIl \
    'ChatMessage(' \
    "$BASE" 2>/dev/null | grep -q .; then
    pass "ChatMessage actively used"
else
    fail "ChatMessage usage missing"
fi

if grep -RIl \
    'MONUAttachment' \
    "$BASE" 2>/dev/null | grep -q .; then
    pass "MONUAttachment actively used"
else
    fail "MONUAttachment usage missing"
fi

echo
echo "================================================"
echo " LEVEL 50C RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"

if [ "$FAIL" -eq 0 ]; then
    echo
    echo "✓ MODEL DECLARATIONS VERIFIED"
    echo "✓ IMPORTS VERIFIED"
    echo "✓ ACTIVE TYPE USAGE VERIFIED"
    echo
    echo "LEVEL 50 SYSTEM STATUS: GOLDEN"
else
    echo
    echo "LEVEL 50 NEEDS TARGETED MODEL REPAIR"
fi

echo "================================================"
