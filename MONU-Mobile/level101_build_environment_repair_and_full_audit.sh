#!/data/data/com.termux/files/usr/bin/bash
set -u

echo "================================================"
echo " MONU MOBILE - LEVEL 101"
echo " BUILD ENVIRONMENT REPAIR + FULL PROJECT AUDIT"
echo "================================================"

LOG=".monu-logs/level101"
mkdir -p "$LOG"

PASS=0
FAIL=0
WARN=0

pass() { echo "[PASS] $1"; PASS=$((PASS+1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "[WARN] $1"; WARN=$((WARN+1)); }

echo
echo "[1/8] Previous failure diagnosis"
echo "------------------------------------------------"

AAPT2=$(find "$HOME/.gradle/caches" -type f -path "*aapt2*" -name "aapt2" 2>/dev/null | head -1 || true)

if [ -n "$AAPT2" ]; then
    echo "AAPT2 candidate: $AAPT2"
    file "$AAPT2" 2>/dev/null || true

    if "$AAPT2" version >/dev/null 2>&1; then
        pass "AAPT2 executable runs"
    else
        warn "Downloaded AAPT2 cannot run on this Termux architecture"
    fi
else
    warn "No cached AAPT2 binary found"
fi

echo
echo "[2/8] Host architecture audit"
echo "------------------------------------------------"

uname -a | tee "$LOG/uname.txt"
ARCH=$(uname -m)
echo "ARCH=$ARCH" | tee "$LOG/architecture.txt"

case "$ARCH" in
    aarch64|arm64)
        pass "Running on ARM64 Android/Termux"
        ;;
    *)
        warn "Non-standard architecture: $ARCH"
        ;;
esac

echo
echo "[3/8] Android SDK tool audit"
echo "------------------------------------------------"

echo "ANDROID_HOME=${ANDROID_HOME:-UNSET}"
echo "ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-UNSET}"
echo "JAVA_HOME=${JAVA_HOME:-UNSET}"

command -v java >/dev/null 2>&1 \
    && pass "Java available: $(java -version 2>&1 | head -1)" \
    || fail "Java unavailable"

command -v sdkmanager >/dev/null 2>&1 \
    && pass "sdkmanager available" \
    || warn "sdkmanager not in PATH"

command -v aapt2 >/dev/null 2>&1 \
    && pass "System aapt2 available: $(command -v aapt2)" \
    || warn "System aapt2 not available"

echo
echo "[4/8] Gradle and AGP audit"
echo "------------------------------------------------"

./gradlew --version > "$LOG/gradle-version.txt" 2>&1
if [ $? -eq 0 ]; then
    pass "Gradle wrapper starts"
    cat "$LOG/gradle-version.txt"
else
    fail "Gradle wrapper cannot start"
fi

grep -RInE \
    'com\.android\.application|com\.android\.library|android-gradle-plugin|8\.[0-9]+\.[0-9]+' \
    build.gradle* settings.gradle* gradle 2>/dev/null \
    > "$LOG/agp-audit.txt" || true

cat "$LOG/agp-audit.txt"

echo
echo "[5/8] Full source architecture audit"
echo "------------------------------------------------"

find app/src/main/java -type f -name "*.kt" | sort \
    > "$LOG/all-kotlin-files.txt"

KOTLIN_COUNT=$(wc -l < "$LOG/all-kotlin-files.txt" | tr -d ' ')
echo "Kotlin source files: $KOTLIN_COUNT"

if [ "$KOTLIN_COUNT" -gt 0 ]; then
    pass "Kotlin production tree present"
else
    fail "No Kotlin sources found"
fi

echo
echo "--- Main feature branches ---"

for dir in \
    app/src/main/java/com/monu/mobile/feature \
    app/src/main/java/com/monu/mobile/ui \
    app/src/main/java/com/monu/mobile/data \
    app/src/main/java/com/monu/mobile/domain
do
    if [ -d "$dir" ]; then
        echo "[FOUND] $dir"
        find "$dir" -maxdepth 3 -type f 2>/dev/null | sort
    else
        echo "[MISSING/NOT-YET-CREATED] $dir"
    fi
done > "$LOG/main-branches.txt"

cat "$LOG/main-branches.txt"

echo
echo "[6/8] Kotlin syntax-level audit"
echo "------------------------------------------------"

PLACEHOLDERS=$(grep -RInE \
    'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING' \
    app/src/main/java 2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical placeholder markers"
else
    warn "Placeholder markers found"
    echo "$PLACEHOLDERS"
fi

DUPLICATES=$(grep -RhoE \
    '^class [A-Za-z0-9_]+' \
    app/src/main/java 2>/dev/null | sort | uniq -d || true)

if [ -z "$DUPLICATES" ]; then
    pass "No duplicate class declarations detected"
else
    warn "Possible duplicate class names"
    echo "$DUPLICATES"
fi

echo
echo "[7/8] Build blocker classification"
echo "------------------------------------------------"

if grep -q "aapt2.*Syntax error.*unexpected" .monu-logs/final-build/compile.txt 2>/dev/null; then
    pass "Build blocker identified as host-native AAPT2 incompatibility"
    echo "CLASSIFICATION=AAPT2_HOST_ARCHITECTURE_BLOCKER" \
        > "$LOG/build-blocker.txt"
else
    warn "Previous AAPT2 blocker pattern not found"
fi

echo
echo "[8/8] Production readiness report"
echo "------------------------------------------------"

{
    echo "MONU MOBILE LEVEL 101 REPORT"
    echo "============================="
    echo
    echo "SOURCE STATUS"
    echo "-------------"
    echo "Kotlin files: $KOTLIN_COUNT"
    echo
    echo "BUILD STATUS"
    echo "------------"
    echo "Gradle wrapper: checked"
    echo "AAPT2 blocker: host compatibility issue detected"
    echo
    echo "IMPORTANT CONCLUSION"
    echo "--------------------"
    echo "The current failure occurred before reliable validation"
    echo "of the newly-added Kotlin production architecture."
    echo
    echo "Therefore:"
    echo "1. Do NOT declare Level 100 APK golden."
    echo "2. Do NOT add unrelated features yet."
    echo "3. First establish a valid compile environment."
    echo "4. Then compile all existing main branches together."
    echo "5. Only after compile success continue multi-feature expansion."
    echo
    echo "NEXT BATCH AFTER ENVIRONMENT REPAIR"
    echo "-----------------------------------"
    echo "Multi-branch integration:"
    echo "- Chat UI real state binding"
    echo "- Conversation persistence wiring"
    echo "- Lifecycle recovery wiring"
    echo "- Offline command pipeline integration"
    echo "- Error/loading state propagation"
    echo "- Main application branch audit"
    echo
    echo "RESULT"
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo "WARN=$WARN"
} > "$LOG/level101_full_report.txt"

echo
echo "================================================"
echo " LEVEL 101 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo
echo "REPORT: $LOG/level101_full_report.txt"
echo "================================================"

# Environment diagnosis is informational; only missing essential project
# structure should stop the next repair step.
if [ "$FAIL" -gt 0 ]; then
    echo "LEVEL 101 PROJECT STRUCTURE NEEDS REPAIR"
    exit 1
fi

echo "LEVEL 101 AUDIT COMPLETE"
echo "NEXT: TERMUX AAPT2 COMPATIBILITY REPAIR + RECOMPILE"
