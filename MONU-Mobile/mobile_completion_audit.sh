#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

echo "================================================"
echo " MONU MOBILE - APK COMPLETION AUDIT"
echo "================================================"

echo
echo "===== 1. PROJECT BUILD FOUNDATION ====="
for f in \
settings.gradle.kts \
build.gradle.kts \
gradle.properties \
app/build.gradle.kts \
app/src/main/AndroidManifest.xml \
app/src/main/java/com/monu/mobile/MainActivity.kt \
app/src/main/java/com/monu/mobile/ui/MONUApp.kt
do
    [ -f "$f" ] && echo "[OK] $f" || echo "[MISSING] $f"
done

echo
echo "===== 2. ANDROID INTERNET CAPABILITY ====="
if grep -q 'android.permission.INTERNET' app/src/main/AndroidManifest.xml 2>/dev/null; then
    echo "[OK] INTERNET permission declared"
else
    echo "[MISSING] INTERNET permission"
fi

if grep -q 'android.permission.ACCESS_NETWORK_STATE' app/src/main/AndroidManifest.xml 2>/dev/null; then
    echo "[OK] Network state permission declared"
else
    echo "[MISSING] ACCESS_NETWORK_STATE permission"
fi

echo
echo "===== 3. REAL NETWORK IMPLEMENTATION ====="
grep -RInE \
'HttpURLConnection|OkHttpClient|Retrofit|httpx|URL\(|WebSocket|ktor' \
"$BASE" 2>/dev/null || echo "[PENDING] No clear real HTTP client implementation found"

echo
echo "===== 4. PLACEHOLDER / EMPTY IMPLEMENTATIONS ====="
grep -RInE \
'emptyList\(\)|return null|TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|integration pending|pending for' \
"$BASE" 2>/dev/null | head -400 || true

echo
echo "===== 5. EMPTY FEATURE DIRECTORIES ====="
find "$BASE/feature" -type d -empty 2>/dev/null | sort || true

echo
echo "===== 6. SCREEN NAVIGATION CHECK ====="
echo "--- Screen files ---"
find "$BASE/ui/screens" -type f -name '*.kt' | wc -l

echo "--- Navigation declarations ---"
grep -RInE \
'NavHost|composable\(|MONUDestination|navigate\(' \
"$BASE/ui" 2>/dev/null | head -300 || true

echo
echo "===== 7. NETWORK / SERVER FOUNDATIONS ====="
find "$BASE" -type f \
\( -iname '*Server*' -o -iname '*Network*' -o -iname '*Connection*' -o -iname '*Realtime*' \) \
2>/dev/null | sort

echo
echo "===== 8. OFFLINE / SYNC FOUNDATIONS ====="
find "$BASE" -type f \
\( -iname '*Offline*' -o -iname '*Sync*' -o -iname '*Transfer*' \) \
2>/dev/null | sort

echo
echo "===== 9. DATABASE FOUNDATIONS ====="
find "$BASE/data/local" -type f 2>/dev/null | sort || true

echo
echo "===== 10. TEST COVERAGE ====="
find app/src/test app/src/androidTest -type f 2>/dev/null | sort || \
echo "[PENDING] No test source directories found"

echo
echo "===== 11. BUILD PLACEHOLDERS ====="
grep -RInE \
'com.example|localhost|127.0.0.1|YOUR_|API_KEY|BASE_URL|TODO' \
app build.gradle.kts settings.gradle.kts gradle.properties \
2>/dev/null | head -300 || true

echo
echo "================================================"
echo " MONU MOBILE AUDIT COMPLETE"
echo "================================================"
echo
echo "IMPORTANT:"
echo "APK size is not a measure of strength."
echo "We will improve real capability, not add useless MB."
echo
echo "NEXT TARGETS:"
echo "1. Real Internet Knowledge capability"
echo "2. Network state + failure handling"
echo "3. Complete navigation wiring"
echo "4. Replace placeholder engines"
echo "5. Offline/online synchronization"
echo "6. Real compilation fixes"
echo "7. Runtime testing"
