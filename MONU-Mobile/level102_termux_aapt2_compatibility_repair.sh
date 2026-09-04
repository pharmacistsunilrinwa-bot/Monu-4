#!/data/data/com.termux/files/usr/bin/bash
set -u

echo "================================================"
echo " MONU MOBILE - LEVEL 102"
echo " TERMUX AAPT2 COMPATIBILITY REPAIR"
echo "================================================"

LOG=".monu-logs/level102"
mkdir -p "$LOG"

PASS=0
FAIL=0
WARN=0

pass() { echo "[PASS] $1"; PASS=$((PASS+1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "[WARN] $1"; WARN=$((WARN+1)); }

echo
echo "[1/7] Detecting available package tools"
echo "------------------------------------------------"

command -v pkg >/dev/null 2>&1 \
    && pass "Termux pkg available" \
    || fail "Termux pkg unavailable"

command -v apt >/dev/null 2>&1 \
    && pass "APT backend available" \
    || fail "APT backend unavailable"

echo
echo "[2/7] Refreshing package metadata"
echo "------------------------------------------------"

pkg update -y > "$LOG/pkg-update.txt" 2>&1
if [ $? -eq 0 ]; then
    pass "Package metadata refreshed"
else
    warn "Package metadata refresh returned non-zero"
    tail -40 "$LOG/pkg-update.txt"
fi

echo
echo "[3/7] Searching Termux packages for AAPT2"
echo "------------------------------------------------"

pkg search aapt2 > "$LOG/aapt2-package-search.txt" 2>&1 || true
cat "$LOG/aapt2-package-search.txt"

echo
echo "[4/7] Installing compatible Android build tooling if available"
echo "------------------------------------------------"

if grep -qiE '(^| )aapt2(/| |$)' "$LOG/aapt2-package-search.txt"; then
    pkg install -y aapt2 > "$LOG/aapt2-install.txt" 2>&1

    if [ $? -eq 0 ]; then
        pass "Termux-native aapt2 installed"
    else
        warn "Termux-native aapt2 installation failed"
        tail -80 "$LOG/aapt2-install.txt"
    fi
else
    warn "No direct aapt2 package discovered"
fi

echo
echo "[5/7] Locating native AAPT2"
echo "------------------------------------------------"

NATIVE_AAPT2=""

for candidate in \
    "$(command -v aapt2 2>/dev/null || true)" \
    "$PREFIX/bin/aapt2"
do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
        if "$candidate" version >/dev/null 2>&1; then
            NATIVE_AAPT2="$candidate"
            break
        fi
    fi
done

if [ -n "$NATIVE_AAPT2" ]; then
    pass "Runnable native AAPT2 found: $NATIVE_AAPT2"
    "$NATIVE_AAPT2" version || true
else
    warn "No runnable Termux-native AAPT2 found"
fi

echo
echo "[6/7] Gradle AAPT2 override preparation"
echo "------------------------------------------------"

PROPS="gradle.properties"

touch "$PROPS"

cp "$PROPS" "$LOG/gradle.properties.before_level102.backup"

sed -i \
    '/^android\.aapt2FromMavenOverride=/d' \
    "$PROPS"

if [ -n "$NATIVE_AAPT2" ]; then
    echo "android.aapt2FromMavenOverride=$NATIVE_AAPT2" \
        >> "$PROPS"

    pass "Gradle configured to use native AAPT2 override"
else
    warn "Override not applied because native AAPT2 is unavailable"
fi

echo
echo "[7/7] Cache cleanup and compile retry"
echo "------------------------------------------------"

./gradlew --stop > "$LOG/gradle-stop.txt" 2>&1 || true

rm -rf app/build

# Remove only transformed downloaded AAPT2 executables so Gradle does not
# reuse a known incompatible host binary.
find "$HOME/.gradle/caches" \
    -type f \
    -path "*aapt2-*-linux*/aapt2" \
    -delete 2>/dev/null || true

./gradlew :app:compileDebugKotlin --stacktrace \
    > "$LOG/compile-after-repair.txt" 2>&1

COMPILE=$?

if [ "$COMPILE" -eq 0 ]; then
    pass "Kotlin/Android compile passed after environment repair"
else
    fail "Compile still blocked"

    echo
    echo "----- ERROR SUMMARY -----"
    grep -nE \
        '^e:|error:|FAILURE:|AAPT2|Exception|Caused by:' \
        "$LOG/compile-after-repair.txt" \
        | tail -100 || true

    echo
    echo "----- LAST 120 LINES -----"
    tail -120 "$LOG/compile-after-repair.txt"
fi

{
    echo "LEVEL 102 TERMUX BUILD ENVIRONMENT REPORT"
    echo "=========================================="
    echo
    echo "ARCH=$(uname -m)"
    echo "NATIVE_AAPT2=${NATIVE_AAPT2:-NONE}"
    echo "COMPILE_EXIT=$COMPILE"
    echo
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo "WARN=$WARN"
} > "$LOG/level102_report.txt"

echo
echo "================================================"
echo " LEVEL 102 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$COMPILE" -eq 0 ]; then
    echo "LEVEL 102 GOLDEN"
    echo "BUILD ENVIRONMENT COMPILE PATH RESTORED"
    echo "NEXT: LEVELS 103-108 MULTI-BRANCH REAL UI + PERSISTENCE WIRING"
else
    echo "LEVEL 102 NEEDS TARGETED BUILD ENVIRONMENT REPAIR"
    exit 1
fi
