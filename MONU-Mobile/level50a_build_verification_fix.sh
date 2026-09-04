#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"
LOG_DIR=".monu-logs"

mkdir -p "$LOG_DIR"

DEP_LOG="$LOG_DIR/level50_dependencies.log"
BUILD_LOG="$LOG_DIR/level50_build.log"

echo "================================================"
echo " MONU MOBILE - LEVEL 50A"
echo " REAL BUILD VERIFICATION FIX"
echo "================================================"

echo
echo "[1/7] Environment"
echo "------------------------------------------------"
echo "Project: $(pwd)"
echo "Java:"
java -version 2>&1 | head -5

echo
echo "Gradle:"
./gradlew --version | head -12

echo
echo "[2/7] Critical source files"
echo "------------------------------------------------"

for file in \
"$BASE/ui/screens/ChatScreen.kt" \
"$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt" \
"$BASE/core/network/MONUNetworkMonitor.kt" \
"$BASE/domain/model/InternetKnowledgeModels.kt" \
"app/src/main/AndroidManifest.xml"
do
    if [ -f "$file" ]; then
        echo "[OK] $file"
    else
        echo "[MISSING] $file"
    fi
done

echo
echo "[3/7] Permissions"
echo "------------------------------------------------"

grep -q 'android.permission.INTERNET' \
app/src/main/AndroidManifest.xml \
&& echo "[OK] INTERNET" \
|| echo "[FAIL] INTERNET missing"

grep -q 'android.permission.ACCESS_NETWORK_STATE' \
app/src/main/AndroidManifest.xml \
&& echo "[OK] ACCESS_NETWORK_STATE" \
|| echo "[FAIL] ACCESS_NETWORK_STATE missing"

echo
echo "[4/7] Dependency resolution"
echo "------------------------------------------------"

rm -f "$DEP_LOG"

./gradlew :app:dependencies \
--configuration debugRuntimeClasspath \
>"$DEP_LOG" 2>&1

DEP_STATUS=$?

if [ "$DEP_STATUS" -eq 0 ]; then
    echo "[PASS] Dependencies resolved"
else
    echo "[FAIL] Dependency resolution failed"
    echo
    tail -100 "$DEP_LOG"
fi

echo
echo "[5/7] DEBUG APK BUILD"
echo "------------------------------------------------"

rm -f "$BUILD_LOG"

./gradlew :app:assembleDebug \
>"$BUILD_LOG" 2>&1

BUILD_STATUS=$?

if [ "$BUILD_STATUS" -eq 0 ]; then

    echo "[PASS] DEBUG BUILD SUCCESSFUL"

    APK=$(find app/build/outputs/apk/debug \
        -type f \
        -name '*.apk' \
        | head -1)

    if [ -n "$APK" ]; then
        echo
        echo "APK GENERATED:"
        echo "$APK"
        ls -lh "$APK"
    else
        echo "[WARNING] Build passed but APK path not found"
    fi

else

    echo "[FAIL] DEBUG BUILD FAILED"
    echo
    echo "========== BUILD ERROR =========="
    tail -160 "$BUILD_LOG"

fi

echo
echo "[6/7] Build artifact check"
echo "------------------------------------------------"

find app/build/outputs/apk \
-type f \
-name '*.apk' \
-print 2>/dev/null || true

echo
echo "[7/7] FINAL RESULT"
echo "================================================"

if [ "$DEP_STATUS" -eq 0 ] && [ "$BUILD_STATUS" -eq 0 ]; then

    echo " LEVEL 50 GOLDEN"
    echo "================================================"
    echo "✓ Dependencies resolved"
    echo "✓ Kotlin compilation passed"
    echo "✓ Compose compilation passed"
    echo "✓ Internet knowledge integration compiled"
    echo "✓ Debug APK generated"
    echo
    echo "LOGS:"
    echo "$DEP_LOG"
    echo "$BUILD_LOG"

else

    echo " LEVEL 50 NOT GOLDEN"
    echo "================================================"
    echo "Build logs saved inside:"
    echo "$LOG_DIR"
    echo
    echo "Do not randomly modify project files."
    echo "Use the exact compiler output for targeted repair."

fi
