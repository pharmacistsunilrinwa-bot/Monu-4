#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"

echo "================================================"
echo " MONU MOBILE - LEVEL 48"
echo " SAFE INTEGRATION INSPECTION"
echo "================================================"

echo
echo "===== 1. BUILD CONFIG ====="
echo "--- app/build.gradle.kts ---"
cat app/build.gradle.kts

echo
echo "===== 2. MAIN APP ====="
echo "--- MONUApp.kt ---"
cat "$BASE/ui/MONUApp.kt"

echo
echo "===== 3. CHAT SCREEN ====="
echo "--- ChatScreen.kt ---"
cat "$BASE/ui/screens/ChatScreen.kt"

echo
echo "===== 4. COMMAND INPUT ====="
echo "--- CommandInput.kt ---"
cat "$BASE/ui/components/CommandInput.kt"

echo
echo "===== 5. KNOWLEDGE ENGINE ====="
echo "--- MONUInternetKnowledgeEngine.kt ---"
cat "$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt"

echo
echo "===== 6. ALL SCREEN FILES ====="
find "$BASE/ui/screens" -type f -name '*.kt' | sort

echo
echo "===== 7. DESTINATIONS ====="
cat "$BASE/ui/navigation/MONUDestination.kt"

echo
echo "================================================"
echo " LEVEL 48 INSPECTION COMPLETE"
echo "================================================"
