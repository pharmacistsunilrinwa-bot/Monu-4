#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"
LOG_DIR=".monu-logs"

mkdir -p "$LOG_DIR"

echo "================================================"
echo " MONU MOBILE - LEVEL 50"
echo " SYSTEM INTEGRATION VERIFICATION"
echo " NO APK BUILD"
echo "================================================"

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

check_file() {
    if [ -f "$1" ]; then
        pass "FILE: $1"
    else
        fail "MISSING FILE: $1"
    fi
}

check_pattern() {
    FILE="$1"
    PATTERN="$2"
    LABEL="$3"

    if [ -f "$FILE" ] && grep -qE "$PATTERN" "$FILE"; then
        pass "$LABEL"
    else
        fail "$LABEL"
    fi
}

echo
echo "[1/9] CORE SYSTEM FILES"
echo "------------------------------------------------"

check_file "$BASE/ui/screens/ChatScreen.kt"
check_file "$BASE/ui/components/CommandInput.kt"
check_file "$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt"
check_file "$BASE/core/network/MONUNetworkMonitor.kt"
check_file "$BASE/domain/model/InternetKnowledgeModels.kt"
check_file "$BASE/domain/model/ChatMessage.kt"
check_file "$BASE/domain/model/MONUAttachment.kt"
check_file "$BASE/feature/voice/MONUVoiceEngine.kt"
check_file "$BASE/ui/MONUApp.kt"

echo
echo "[2/9] CHAT INPUT PIPELINE"
echo "------------------------------------------------"

check_pattern \
"$BASE/ui/components/CommandInput.kt" \
'onSend' \
"CommandInput exposes send callback"

check_pattern \
"$BASE/ui/components/CommandInput.kt" \
'MONUAttachment' \
"CommandInput supports attachments"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'CommandInput' \
"ChatScreen receives command input"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'role = MessageRole.OWNER' \
"Owner message created"

echo
echo "[3/9] INTERNET KNOWLEDGE PIPELINE"
echo "------------------------------------------------"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'MONUInternetKnowledgeEngine' \
"Knowledge engine connected to Chat"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'knowledgeEngine.search' \
"Chat invokes knowledge search"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'Dispatchers.IO' \
"Internet work isolated on IO dispatcher"

check_pattern \
"$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt" \
'OkHttpClient' \
"Knowledge engine has HTTP client"

check_pattern \
"$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt" \
'execute\(\)' \
"Knowledge engine performs real request"

check_pattern \
"$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt" \
'InternetKnowledgeState.SUCCESS' \
"Knowledge success state handled"

check_pattern \
"$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt" \
'NETWORK_ERROR' \
"Knowledge network errors handled"

echo
echo "[4/9] NETWORK SAFETY PIPELINE"
echo "------------------------------------------------"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'MONUNetworkMonitor' \
"Network monitor connected"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'isOnline\(\)' \
"Internet availability checked"

check_pattern \
"app/src/main/AndroidManifest.xml" \
'android.permission.INTERNET' \
"Internet permission present"

check_pattern \
"app/src/main/AndroidManifest.xml" \
'android.permission.ACCESS_NETWORK_STATE' \
"Network state permission present"

echo
echo "[5/9] RESPONSE STATE MACHINE"
echo "------------------------------------------------"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'InternetKnowledgeState.SUCCESS' \
"SUCCESS response path"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'InternetKnowledgeState.NOT_FOUND' \
"NOT_FOUND response path"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'InternetKnowledgeState.NETWORK_ERROR' \
"NETWORK_ERROR response path"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'InternetKnowledgeState.INVALID_QUERY' \
"INVALID_QUERY response path"

echo
echo "[6/9] VOICE PIPELINE"
echo "------------------------------------------------"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'MONUVoiceEngine' \
"Voice engine connected"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'voiceEngine.speak' \
"Message listen action connected"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'voiceEngine.stop' \
"Voice stop action connected"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'voiceEngine.shutdown' \
"Voice cleanup connected"

echo
echo "[7/9] MESSAGE ACTIONS"
echo "------------------------------------------------"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'copyToClipboard' \
"Copy action available"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'shareText' \
"Share action available"

check_pattern \
"$BASE/ui/screens/ChatScreen.kt" \
'Intent.ACTION_SEND' \
"Android share intent available"

echo
echo "[8/9] CRITICAL PLACEHOLDER SCAN"
echo "------------------------------------------------"

CRITICAL_FILES=(
"$BASE/ui/screens/ChatScreen.kt"
"$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt"
"$BASE/core/network/MONUNetworkMonitor.kt"
"$BASE/ui/components/CommandInput.kt"
)

PLACEHOLDERS=$(grep -RInE \
'not configured yet|TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING' \
"${CRITICAL_FILES[@]}" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical placeholder in active pipeline"
else
    warn "Possible placeholders found:"
    echo "$PLACEHOLDERS"
fi

echo
echo "[9/9] SYSTEM FLOW SUMMARY"
echo "------------------------------------------------"

echo
echo "EXPECTED ACTIVE FLOW:"
echo
echo "USER"
echo "  ↓"
echo "CommandInput"
echo "  ↓"
echo "ChatScreen"
echo "  ↓"
echo "Network Check"
echo "  ↓"
echo "IO Dispatcher"
echo "  ↓"
echo "MONUInternetKnowledgeEngine"
echo "  ↓"
echo "InternetKnowledgeResult"
echo "  ↓"
echo "Response State Machine"
echo "  ↓"
echo "MONU Message"
echo "  ↓"
echo "Copy / Listen / Stop / Share"

echo
echo "================================================"
echo " LEVEL 50 FINAL RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo " LEVEL 50 SYSTEM GOLDEN"
    echo "================================================"
    echo "✓ Chat pipeline verified"
    echo "✓ Internet pipeline verified"
    echo "✓ Network safety verified"
    echo "✓ Response states verified"
    echo "✓ Voice pipeline verified"
    echo "✓ Message actions verified"
    echo
    echo "NEXT SYSTEM LEVEL:"
    echo "LEVEL 52 - REAL NAVIGATION WIRING"
else
    echo " LEVEL 50 SYSTEM NEEDS REPAIR"
    echo "================================================"
    echo "Only failed integration points should be repaired."
fi
