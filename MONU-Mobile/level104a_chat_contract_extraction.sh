#!/data/data/com.termux/files/usr/bin/bash
set -u

echo "================================================"
echo " MONU MOBILE - LEVEL 104A"
echo " EXACT CHAT INTEGRATION CONTRACT EXTRACTION"
echo " NO SOURCE MODIFICATION"
echo "================================================"

LOG=".monu-logs/level104a"
mkdir -p "$LOG"

PASS=0
FAIL=0
WARN=0

pass() { echo "[PASS] $1"; PASS=$((PASS+1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "[WARN] $1"; WARN=$((WARN+1)); }

capture() {
    local f="$1"
    local name
    name=$(basename "$f")

    echo
    echo "================================================"
    echo "FILE: $f"
    echo "================================================"

    if [ -f "$f" ]; then
        nl -ba "$f"
        pass "Captured $name"
    else
        warn "Missing $f"
    fi
}

echo
echo "[1/10] Capturing exact ChatScreen source"
echo "------------------------------------------------"

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"

if [ -f "$CHAT" ]; then
    nl -ba "$CHAT" > "$LOG/ChatScreen_exact.txt"
    cp "$CHAT" "$LOG/ChatScreen_original.kt"
    pass "ChatScreen exact source captured"
else
    fail "ChatScreen.kt missing"
fi

echo
echo "[2/10] Capturing domain chat model contract"
echo "------------------------------------------------"

MODEL="app/src/main/java/com/monu/mobile/domain/model/ChatModels.kt"

if [ -f "$MODEL" ]; then
    nl -ba "$MODEL" > "$LOG/ChatModels_exact.txt"
    pass "ChatModels exact contract captured"
else
    fail "ChatModels.kt missing"
fi

echo
echo "[3/10] Capturing complete conversation layer"
echo "------------------------------------------------"

CONV_DIR="app/src/main/java/com/monu/mobile/feature/conversation"

: > "$LOG/conversation_exact_sources.txt"

if [ -d "$CONV_DIR" ]; then
    while IFS= read -r f; do
        echo >> "$LOG/conversation_exact_sources.txt"
        echo "################################################" >> "$LOG/conversation_exact_sources.txt"
        echo "FILE: $f" >> "$LOG/conversation_exact_sources.txt"
        echo "################################################" >> "$LOG/conversation_exact_sources.txt"
        nl -ba "$f" >> "$LOG/conversation_exact_sources.txt"
        echo >> "$LOG/conversation_exact_sources.txt"
    done < <(find "$CONV_DIR" -type f -name "*.kt" | sort)

    pass "Complete conversation layer captured"
else
    fail "Conversation directory missing"
fi

echo
echo "[4/10] Capturing exact voice layer"
echo "------------------------------------------------"

VOICE_DIR="app/src/main/java/com/monu/mobile/feature/voice"

: > "$LOG/voice_exact_sources.txt"

if [ -d "$VOICE_DIR" ]; then
    while IFS= read -r f; do
        echo >> "$LOG/voice_exact_sources.txt"
        echo "################################################" >> "$LOG/voice_exact_sources.txt"
        echo "FILE: $f" >> "$LOG/voice_exact_sources.txt"
        echo "################################################" >> "$LOG/voice_exact_sources.txt"
        nl -ba "$f" >> "$LOG/voice_exact_sources.txt"
        echo >> "$LOG/voice_exact_sources.txt"
    done < <(find "$VOICE_DIR" -type f -name "*.kt" | sort)

    pass "Complete voice layer captured"
else
    fail "Voice directory missing"
fi

echo
echo "[5/10] Capturing network monitor contract"
echo "------------------------------------------------"

NET="app/src/main/java/com/monu/mobile/core/network/MONUNetworkMonitor.kt"

if [ -f "$NET" ]; then
    nl -ba "$NET" > "$LOG/MONUNetworkMonitor_exact.txt"
    pass "Network monitor contract captured"
else
    warn "MONUNetworkMonitor.kt not found at expected path"

    find app/src/main/java \
        -type f \
        -name "*.kt" \
        -exec grep -l "class MONUNetworkMonitor\|object MONUNetworkMonitor" {} \; \
        > "$LOG/network_monitor_locations.txt" 2>/dev/null || true

    cat "$LOG/network_monitor_locations.txt"

    while IFS= read -r f; do
        [ -f "$f" ] || continue
        echo "FILE: $f" >> "$LOG/MONUNetworkMonitor_exact.txt"
        nl -ba "$f" >> "$LOG/MONUNetworkMonitor_exact.txt"
    done < "$LOG/network_monitor_locations.txt"
fi

echo
echo "[6/10] Capturing offline command router contract"
echo "------------------------------------------------"

OFFLINE_DIR="app/src/main/java/com/monu/mobile/feature/offline"

: > "$LOG/offline_exact_sources.txt"

if [ -d "$OFFLINE_DIR" ]; then
    while IFS= read -r f; do
        if grep -q "MONUOfflineCommandRouter" "$f"; then
            echo "################################################" >> "$LOG/offline_exact_sources.txt"
            echo "FILE: $f" >> "$LOG/offline_exact_sources.txt"
            echo "################################################" >> "$LOG/offline_exact_sources.txt"
            nl -ba "$f" >> "$LOG/offline_exact_sources.txt"
        fi
    done < <(find "$OFFLINE_DIR" -type f -name "*.kt" | sort)

    if [ -s "$LOG/offline_exact_sources.txt" ]; then
        pass "Offline router contract captured"
    else
        warn "Offline router definition not found"
    fi
else
    warn "Offline feature directory missing"
fi

echo
echo "[7/10] Capturing internet knowledge contract"
echo "------------------------------------------------"

KNOW_DIR="app/src/main/java/com/monu/mobile/feature/knowledge"

: > "$LOG/knowledge_exact_sources.txt"

if [ -d "$KNOW_DIR" ]; then
    while IFS= read -r f; do
        if grep -q "MONUInternetKnowledgeEngine" "$f"; then
            echo "################################################" >> "$LOG/knowledge_exact_sources.txt"
            echo "FILE: $f" >> "$LOG/knowledge_exact_sources.txt"
            echo "################################################" >> "$LOG/knowledge_exact_sources.txt"
            nl -ba "$f" >> "$LOG/knowledge_exact_sources.txt"
        fi
    done < <(find "$KNOW_DIR" -type f -name "*.kt" | sort)

    if [ -s "$LOG/knowledge_exact_sources.txt" ]; then
        pass "Internet knowledge contract captured"
    else
        warn "Internet knowledge engine definition not found"
    fi
else
    warn "Knowledge feature directory missing"
fi

echo
echo "[8/10] Extracting ChatScreen broken regions"
echo "------------------------------------------------"

if [ -f "$CHAT" ]; then
    sed -n '35,250p' "$CHAT" > "$LOG/ChatScreen_broken_region_35_250.txt"
    sed -n '250,470p' "$CHAT" > "$LOG/ChatScreen_ui_region_250_470.txt"

    pass "ChatScreen broken and UI regions isolated"
else
    fail "Cannot isolate ChatScreen regions"
fi

echo
echo "[9/10] Building symbol-to-definition evidence map"
echo "------------------------------------------------"

SYMBOLS="
messages
MessageRole
ChatMessage
MONUChatScreenIntegration
MONUVoiceEngine
MONUVoiceInputEngine
MONUNetworkMonitor
MONUOfflineCommandRouter
MONUInternetKnowledgeEngine
conversationId
answer
"

: > "$LOG/exact_symbol_evidence.txt"

for symbol in $SYMBOLS; do
    {
        echo
        echo "================================================"
        echo "SYMBOL: $symbol"
        echo "================================================"

        grep -RIn \
            --include="*.kt" \
            --include="*.kts" \
            -F "$symbol" \
            app/src/main/java \
            2>/dev/null | head -120 || true
    } >> "$LOG/exact_symbol_evidence.txt"
done

pass "Exact symbol evidence map generated"

echo
echo "[10/10] Fresh compile confirmation"
echo "------------------------------------------------"

./gradlew --stop > "$LOG/gradle-stop.txt" 2>&1 || true

./gradlew :app:compileDebugKotlin \
    --stacktrace \
    > "$LOG/compile_before_repair.txt" 2>&1

COMPILE_EXIT=$?

grep -nE \
    '^e:|error:|Unresolved reference|No value passed|Cannot infer type|enum entry' \
    "$LOG/compile_before_repair.txt" \
    > "$LOG/current_errors.txt" || true

ERROR_COUNT=$(wc -l < "$LOG/current_errors.txt" | tr -d ' ')

if [ "$COMPILE_EXIT" -ne 0 ]; then
    pass "Current compile blocker reconfirmed"
else
    warn "Compile passed unexpectedly"
fi

echo
echo "================================================"
echo " LEVEL 104A EVIDENCE SUMMARY"
echo "================================================"

echo "COMPILE_EXIT=$COMPILE_EXIT"
echo "ERROR_LINES=$ERROR_COUNT"
echo "PASS=$PASS"
echo "FAIL=$FAIL"
echo "WARN=$WARN"

{
    echo "MONU MOBILE LEVEL 104A"
    echo "EXACT CHAT INTEGRATION CONTRACT BUNDLE"
    echo "========================================"
    echo
    echo "COMPILE_EXIT=$COMPILE_EXIT"
    echo "ERROR_LINES=$ERROR_COUNT"
    echo
    echo "PRIMARY SOURCE"
    echo "--------------"
    echo "$CHAT"
    echo
    echo "CONTRACT FILES"
    echo "--------------"
    echo "ChatScreen_exact.txt"
    echo "ChatModels_exact.txt"
    echo "conversation_exact_sources.txt"
    echo "voice_exact_sources.txt"
    echo "MONUNetworkMonitor_exact.txt"
    echo "offline_exact_sources.txt"
    echo "knowledge_exact_sources.txt"
    echo "exact_symbol_evidence.txt"
    echo "current_errors.txt"
    echo
    echo "RULE"
    echo "----"
    echo "Level 104B must repair ChatScreen only against"
    echo "actual constructors, methods, enums and state APIs"
    echo "captured in this evidence bundle."
    echo
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo "WARN=$WARN"
} > "$LOG/level104a_master_report.txt"

echo
echo "IMPORTANT OUTPUT:"
echo "  $LOG/level104a_master_report.txt"
echo "  $LOG/ChatScreen_exact.txt"
echo "  $LOG/ChatModels_exact.txt"
echo "  $LOG/conversation_exact_sources.txt"
echo "  $LOG/voice_exact_sources.txt"
echo "  $LOG/MONUNetworkMonitor_exact.txt"
echo "  $LOG/offline_exact_sources.txt"
echo "  $LOG/knowledge_exact_sources.txt"
echo "  $LOG/exact_symbol_evidence.txt"
echo "  $LOG/current_errors.txt"

echo "================================================"

if [ "$FAIL" -gt 0 ]; then
    echo "LEVEL 104A COMPLETED WITH MISSING CRITICAL EVIDENCE"
    exit 1
fi

echo "LEVEL 104A GOLDEN"
echo "NEXT: LEVEL 104B EVIDENCE-BASED CHATSCREEN REPAIR"
