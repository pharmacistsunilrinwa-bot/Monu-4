#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"
APP="$BASE/ui/MONUApp.kt"

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

echo "================================================"
echo " MONU MOBILE - LEVEL 54"
echo " NAVIGATION STATE + SCREEN INTEGRITY"
echo " NO APK BUILD"
echo "================================================"

echo
echo "[1/7] Navigation state ownership"
echo "------------------------------------------------"

grep -q 'var currentDestination by remember' "$APP" \
    && pass "Navigation state is owned by MONURoot" \
    || fail "Navigation state missing"

grep -q 'MONUDestination.HOME' "$APP" \
    && pass "Home is valid initial destination" \
    || fail "Initial destination missing"

echo
echo "[2/7] Drawer state lifecycle"
echo "------------------------------------------------"

grep -q 'rememberDrawerState' "$APP" \
    && pass "Drawer state remembered" \
    || fail "Drawer state missing"

grep -q 'drawerState.open()' "$APP" \
    && pass "Drawer open action connected" \
    || fail "Drawer open action missing"

grep -q 'drawerState.close()' "$APP" \
    && pass "Drawer close action connected" \
    || fail "Drawer close action missing"

echo
echo "[3/7] Destination transition integrity"
echo "------------------------------------------------"

DESTINATIONS=(
CONNECTION HOME CHAT TASKS PROJECTS MEDIA FILES
VOICE SERVER SECURITY DEVICE ACTIVITY SETTINGS
)

for destination in "${DESTINATIONS[@]}"
do
    if grep -q "MONUDestination.$destination" "$APP"; then
        pass "$destination transition exists"
    else
        fail "$destination transition missing"
    fi
done

echo
echo "[4/7] Sidebar interaction integrity"
echo "------------------------------------------------"

grep -q 'current = currentDestination' "$APP" \
    && pass "Sidebar receives active destination" \
    || fail "Sidebar active state missing"

grep -q 'onNavigate = { destination ->' "$APP" \
    && pass "Sidebar destination callback receives target" \
    || fail "Sidebar callback missing"

grep -q 'currentDestination = destination' "$APP" \
    && pass "Destination state updates dynamically" \
    || fail "Dynamic destination update missing"

echo
echo "[5/7] Home and New Chat shortcuts"
echo "------------------------------------------------"

grep -q 'onOpenCommand' "$APP" \
    && pass "Home command shortcut connected" \
    || fail "Home command shortcut missing"

grep -q 'onNewChat' "$APP" \
    && pass "New Chat shortcut connected" \
    || fail "New Chat shortcut missing"

CHAT_TARGETS=$(grep -c 'currentDestination =.*MONUDestination.CHAT' "$APP" || true)

if [ "$CHAT_TARGETS" -ge 1 ]; then
    pass "At least one direct Chat transition exists"
else
    fail "No direct Chat transition found"
fi

echo
echo "[6/7] Screen isolation audit"
echo "------------------------------------------------"

SCREENS=(
ConnectionScreen
HomeScreen
ChatScreen
TaskCenterScreen
ProjectCenterScreen
MediaStudioScreen
TransferCenterScreen
ServerContractScreen
SecurityCenterScreen
DeviceCapabilityScreen
ActivityLogScreen
SettingsCenterScreen
)

for screen in "${SCREENS[@]}"
do
    COUNT=$(grep -c "$screen" "$APP" || true)

    if [ "$COUNT" -ge 2 ]; then
        pass "$screen imported and rendered"
    elif [ "$COUNT" -eq 1 ]; then
        warn "$screen appears only once - review if needed"
    else
        fail "$screen not present"
    fi
done

echo
echo "[7/7] Structural placeholder audit"
echo "------------------------------------------------"

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$APP" 2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No navigation placeholder found"
else
    warn "Navigation placeholder markers found:"
    echo "$PLACEHOLDERS"
fi

echo
echo "================================================"
echo " LEVEL 54 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo " LEVEL 54 GOLDEN"
    echo "================================================"
    echo "✓ Navigation state controlled"
    echo "✓ Drawer lifecycle verified"
    echo "✓ Destination transitions verified"
    echo "✓ Shortcut navigation verified"
    echo "✓ Screen integrity checked"
else
    echo " LEVEL 54 NEEDS TARGETED REPAIR"
fi
