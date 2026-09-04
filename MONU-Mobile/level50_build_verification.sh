#!/data/data/com.termux/files/usr/bin/bash
set -u

echo "================================================"
echo " MONU MOBILE - LEVEL 50"
echo " BUILD & RUNTIME VERIFICATION"
echo "================================================"

echo
echo "[1/8] Environment"
echo "------------------------------------------------"
pwd
java -version 2>&1 | head -20 || true
echo
echo "Gradle:"
./gradlew --version 2>/dev/null | head -20 || true

echo
echo "[2/8] Critical source validation"
echo "------------------------------------------------"

BASE="app/src/main/java/com/monu/mobile"

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
echo "[3/8] Permission validation"
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
echo "[4/8] Kotlin integration validation"
echo "------------------------------------------------"

grep -q 'MONUInternetKnowledgeEngine' \
"$BASE/ui/screens/ChatScreen.kt" \
&& echo "[OK] Knowledge engine wired into chat" \
|| echo "[FAIL] Knowledge engine not wired"

grep -q 'MONUNetworkMonitor' \
"$BASE/ui/screens/ChatScreen.kt" \
&& echo "[OK] Network monitor wired into chat" \
|| echo "[FAIL] Network monitor not wired"

grep -q 'Dispatchers.IO' \
"$BASE/ui/screens/ChatScreen.kt" \
&& echo "[OK] Network work uses IO dispatcher" \
|| echo "[FAIL] IO dispatcher missing"

echo
echo "[5/8] Placeholder scan in critical chat path"
echo "------------------------------------------------"

grep -RInE \
'not configured yet|TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING' \
"$BASE/ui/screens/ChatScreen.kt" \
"$BASE/feature/knowledge" \
"$BASE/core/network" \
2>/dev/null || echo "[OK] No critical placeholder found"

echo
echo "[6/8] Gradle dependency resolution"
echo "------------------------------------------------"

./gradlew :app:dependencies \
--configuration debugRuntimeClasspath \
>/tmp/monu_level50_dependencies.log 2>&1

STATUS=$?

if [ "$STATUS" -eq 0 ]; then
    echo "[PASS] Dependencies resolved"
else
    echo "[FAIL] Dependency resolution failed"
    tail -80 /tmp/monu_level50_dependencies.log
fi

echo
echo "[7/8] DEBUG COMPILATION"
echo "------------------------------------------------"

./gradlew :app:assembleDebug \
>/tmp/monu_level50_build.log 2>&1

BUILD_STATUS=$?

if [ "$BUILD_STATUS" -eq 0 ]; then
    echo "[PASS] DEBUG APK BUILD SUCCESSFUL"

    APK=$(find app/build/outputs/apk/debug \
        -name '*.apk' \
        -type f \
        | head -1)

    if [ -n "$APK" ]; then
        echo
        echo "APK:"
        echo "$APK"
        ls -lh "$APK"
    fi
else
    echo "[FAIL] DEBUG BUILD FAILED"
    echo
    echo "========== LAST 120 BUILD LINES =========="
    tail -120 /tmp/monu_level50_build.log
fi

echo
echo "[8/8] Result"
echo "================================================"

if [ "$BUILD_STATUS" -eq 0 ]; then
    echo " LEVEL 50 GOLDEN"
    echo "================================================"
    echo "✓ Dependencies resolved"
    echo "✓ Kotlin compiled"
    echo "✓ Compose compiled"
    echo "✓ Internet integration compiled"
    echo "✓ Debug APK generated"
    echo
    echo "NEXT: LEVEL 51 - REAL NAVIGATION WIRING"
else
    echo " LEVEL 50 NEEDS FIXING"
    echo "================================================"
    echo "Do not modify unrelated files."
    echo "Send the build failure output for targeted repair."
fi
