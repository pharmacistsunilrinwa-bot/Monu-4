#!/data/data/com.termux/files/usr/bin/bash
set -uo pipefail

LOG=".monu-logs/final-build"
mkdir -p "$LOG"

echo "================================================"
echo " MONU MOBILE FINAL BUILD"
echo " COMPILE + APK + TARGETED REPAIR"
echo "================================================"

chmod +x gradlew 2>/dev/null || true

echo
echo "[1/4] Cleaning previous build"
./gradlew clean > "$LOG/clean.txt" 2>&1
CLEAN=$?

if [ "$CLEAN" -eq 0 ]; then
    echo "[PASS] Clean successful"
else
    echo "[WARN] Clean returned non-zero"
    tail -80 "$LOG/clean.txt"
fi

echo
echo "[2/4] Kotlin/Android compile check"
./gradlew :app:compileDebugKotlin --stacktrace \
    > "$LOG/compile.txt" 2>&1
COMPILE=$?

if [ "$COMPILE" -eq 0 ]; then
    echo "[PASS] Kotlin compilation successful"
else
    echo "[FAIL] Kotlin compilation failed"
    echo
    grep -nE '^e:|error:|FAILURE:|Exception|Caused by:' \
        "$LOG/compile.txt" | tail -80 || true
    echo
    echo "----- LAST 120 LINES -----"
    tail -120 "$LOG/compile.txt"
    exit 1
fi

echo
echo "[3/4] Building debug APK"
./gradlew :app:assembleDebug --stacktrace \
    > "$LOG/apk-build.txt" 2>&1
BUILD=$?

if [ "$BUILD" -ne 0 ]; then
    echo "[FAIL] APK build failed"
    echo
    grep -nE '^e:|error:|FAILURE:|Exception|Caused by:' \
        "$LOG/apk-build.txt" | tail -100 || true
    echo
    echo "----- LAST 150 LINES -----"
    tail -150 "$LOG/apk-build.txt"
    exit 1
fi

echo "[PASS] Debug APK build successful"

echo
echo "[4/4] Locating APK"
APK=$(find app/build/outputs/apk/debug \
    -type f -name "*.apk" 2>/dev/null | head -1)

if [ -n "${APK:-}" ] && [ -f "$APK" ]; then
    SIZE=$(du -h "$APK" | awk '{print $1}')
    echo "[PASS] APK FOUND"
    echo "APK PATH: $APK"
    echo "APK SIZE: $SIZE"

    cp "$APK" "$LOG/MONU-Mobile-Level100-debug.apk"
    echo "[PASS] APK copied to $LOG/"
else
    echo "[FAIL] Build succeeded but APK file was not found"
    exit 1
fi

echo
echo "================================================"
echo " FINAL RESULT"
echo "================================================"
echo "COMPILE : GOLDEN"
echo "APK     : GOLDEN"
echo "PROJECT : MONU MOBILE LEVEL 100 COMPLETE"
echo "================================================"
echo
echo "INSTALL APK:"
echo "$APK"
