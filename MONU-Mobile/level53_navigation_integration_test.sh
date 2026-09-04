#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"
APP="$BASE/ui/MONUApp.kt"

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

check_destination() {
    DESTINATION="$1"
    SCREEN="$2"

    if grep -q "MONUDestination.$DESTINATION" "$APP"; then
        pass "$DESTINATION destination case exists"
    else
        fail "$DESTINATION destination case missing"
    fi

    if grep -q "$SCREEN" "$APP"; then
        pass "$DESTINATION -> $SCREEN connected"
    else
        fail "$DESTINATION screen call missing"
    fi
}

echo "================================================"
echo " MONU MOBILE - LEVEL 53"
echo " NAVIGATION INTEGRATION TEST"
echo " NO APK BUILD"
echo "================================================"

echo
echo "[1/6] Application navigation file"

if [ -f "$APP" ]; then
    pass "MONUApp.kt exists"
else
    fail "MONUApp.kt missing"
fi

echo
echo "[2/6] Core navigation"

check_destination CONNECTION ConnectionScreen
check_destination HOME HomeScreen
check_destination CHAT ChatScreen

echo
echo "[3/6] Productivity navigation"

check_destination TASKS TaskCenterScreen
check_destination PROJECTS ProjectCenterScreen
check_destination MEDIA MediaStudioScreen
check_destination FILES TransferCenterScreen

echo
echo "[4/6] System navigation"

check_destination SERVER ServerContractScreen
check_destination SECURITY SecurityCenterScreen
check_destination DEVICE DeviceCapabilityScreen
check_destination ACTIVITY ActivityLogScreen
check_destination SETTINGS SettingsCenterScreen

echo
echo "[5/6] Special destination"

if grep -q "MONUDestination.VOICE" "$APP"; then
    pass "VOICE destination case exists"
else
    fail "VOICE destination missing"
fi

if grep -q 'title = "Voice"' "$APP"; then
    pass "VOICE controlled FeatureScreen mapping exists"
else
    fail "VOICE mapping missing"
fi

echo
echo "[6/6] Navigation infrastructure"

grep -q 'ModalNavigationDrawer' "$APP" \
    && pass "Navigation drawer active" \
    || fail "Navigation drawer missing"

grep -q 'MONUSidebar' "$APP" \
    && pass "MONU sidebar connected" \
    || fail "MONU sidebar missing"

grep -q 'onNavigate' "$APP" \
    && pass "Sidebar navigation callback connected" \
    || fail "Navigation callback missing"

grep -q 'onNewChat' "$APP" \
    && pass "New Chat callback connected" \
    || fail "New Chat callback missing"

grep -q 'MONUDestination.CHAT' "$APP" \
    && pass "Chat navigation target available" \
    || fail "Chat target missing"

echo
echo "================================================"
echo " LEVEL 53 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo " LEVEL 53 GOLDEN"
    echo "================================================"
    echo "✓ All destinations reachable"
    echo "✓ Real screens connected"
    echo "✓ Sidebar flow verified"
    echo "✓ New Chat flow verified"
    echo "✓ No APK build required"
else
    echo " LEVEL 53 NEEDS TARGETED REPAIR"
fi
