#!/data/data/com.termux/files/usr/bin/bash
set -u

echo "================================================"
echo " MONU MOBILE - LEVEL 103"
echo " CHAT ARCHITECTURE DEEP REPAIR AUDIT"
echo " CONVERSATION + VOICE + OFFLINE INTEGRATION MAP"
echo "================================================"

LOG=".monu-logs/level103"
mkdir -p "$LOG"

PASS=0
FAIL=0
WARN=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS+1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL+1))
}

warn() {
    echo "[WARN] $1"
    WARN=$((WARN+1))
}

echo
echo "[1/12] Creating safe source backups"
echo "------------------------------------------------"

BACKUP="$LOG/source-backup"
mkdir -p "$BACKUP"

for f in \
    app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt \
    app/src/main/java/com/monu/mobile/domain/model/ChatModels.kt \
    app/src/main/java/com/monu/mobile/feature/conversation/MONUConversationModels.kt \
    app/src/main/java/com/monu/mobile/feature/conversation/MONUConversationState.kt \
    app/src/main/java/com/monu/mobile/feature/conversation/MONUChatCoordinator.kt \
    app/src/main/java/com/monu/mobile/feature/conversation/MONUChatScreenIntegration.kt \
    app/src/main/java/com/monu/mobile/feature/conversation/MONUConversationPipeline.kt \
    app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceInputEngine.kt \
    app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceEngine.kt
do
    if [ -f "$f" ]; then
        mkdir -p "$BACKUP/$(dirname "$f")"
        cp "$f" "$BACKUP/$f"
        pass "Backed up $f"
    else
        warn "Missing expected source: $f"
    fi
done

echo
echo "[2/12] Full ChatScreen source capture"
echo "------------------------------------------------"

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"

if [ -f "$CHAT" ]; then
    nl -ba "$CHAT" > "$LOG/ChatScreen_numbered.txt"
    cp "$CHAT" "$LOG/ChatScreen_original.kt"
    pass "ChatScreen captured"

    echo
    echo "--- CHATSCREEN FUNCTION DECLARATIONS ---"
    grep -nE \
        '^(fun|private fun|internal fun|public fun)|@Composable' \
        "$CHAT" \
        | tee "$LOG/ChatScreen_functions.txt" || true

    echo
    echo "--- CHATSCREEN IMPORTS ---"
    grep -n '^import ' "$CHAT" \
        | tee "$LOG/ChatScreen_imports.txt" || true
else
    fail "ChatScreen.kt not found"
fi

echo
echo "[3/12] Conversation architecture signatures"
echo "------------------------------------------------"

CONV_DIR="app/src/main/java/com/monu/mobile/feature/conversation"

if [ -d "$CONV_DIR" ]; then
    find "$CONV_DIR" -type f -name "*.kt" | sort \
        > "$LOG/conversation_files.txt"

    while IFS= read -r file; do
        echo
        echo "################################################"
        echo "FILE: $file"
        echo "################################################"
        grep -nE \
            '^(data class|sealed class|enum class|class|interface|object|fun|suspend fun|private fun|val |var )' \
            "$file" || true
    done < "$LOG/conversation_files.txt" \
        > "$LOG/conversation_public_api.txt"

    pass "Conversation API map generated"
else
    fail "Conversation feature directory missing"
fi

echo
echo "[4/12] Domain ChatModels deep inspection"
echo "------------------------------------------------"

MODEL="app/src/main/java/com/monu/mobile/domain/model/ChatModels.kt"

if [ -f "$MODEL" ]; then
    nl -ba "$MODEL" \
        > "$LOG/ChatModels_numbered.txt"

    grep -nE \
        'data class|sealed class|enum class|class |interface |object |val |var ' \
        "$MODEL" \
        > "$LOG/ChatModels_signatures.txt" || true

    pass "ChatModels API captured"

    echo "--- CHAT MODEL SIGNATURES ---"
    cat "$LOG/ChatModels_signatures.txt"
else
    warn "ChatModels.kt missing"
fi

echo
echo "[5/12] Voice architecture inspection"
echo "------------------------------------------------"

VOICE_DIR="app/src/main/java/com/monu/mobile/feature/voice"

if [ -d "$VOICE_DIR" ]; then
    find "$VOICE_DIR" -type f -name "*.kt" | sort \
        > "$LOG/voice_files.txt"

    while IFS= read -r file; do
        echo
        echo "################################################"
        echo "FILE: $file"
        echo "################################################"
        grep -nE \
            '^(data class|sealed class|enum class|class|interface|object|fun|suspend fun|val |var )' \
            "$file" || true
    done < "$LOG/voice_files.txt" \
        > "$LOG/voice_public_api.txt"

    pass "Voice API map generated"
else
    warn "Voice directory missing"
fi

echo
echo "[6/12] Search actual definitions for broken symbols"
echo "------------------------------------------------"

BROKEN_SYMBOLS="
messages
ASSISTANT
conversationId
voiceInputStatus
voiceInputEngine
voiceListening
networkMonitor
answer
"

: > "$LOG/symbol_definition_map.txt"

for symbol in $BROKEN_SYMBOLS; do
    echo "================================================" \
        >> "$LOG/symbol_definition_map.txt"
    echo "SYMBOL: $symbol" \
        >> "$LOG/symbol_definition_map.txt"
    echo "================================================" \
        >> "$LOG/symbol_definition_map.txt"

    grep -RIn \
        --include="*.kt" \
        -E "(class|data class|enum class|sealed class|object|interface|val|var|fun)[[:space:]]+${symbol}\b|\b${symbol}\b" \
        app/src/main/java \
        2>/dev/null \
        | head -80 \
        >> "$LOG/symbol_definition_map.txt" || true

    echo \
        >> "$LOG/symbol_definition_map.txt"
done

pass "Broken symbol definition map generated"

echo
echo "[7/12] Chat-to-conversation dependency scan"
echo "------------------------------------------------"

grep -RIn \
    --include="*.kt" \
    -E 'MONUChatCoordinator|MONUChatScreenIntegration|MONUConversationState|MONUConversationPipeline|MONUConversationRepository|MONULocalConversationRepository|MONUOfflineConversationBridge' \
    app/src/main/java \
    > "$LOG/chat_conversation_usage.txt" \
    2>/dev/null || true

cat "$LOG/chat_conversation_usage.txt"

if [ -s "$LOG/chat_conversation_usage.txt" ]; then
    pass "Conversation integration references found"
else
    warn "No conversation integration references discovered"
fi

echo
echo "[8/12] Voice usage scan across entire project"
echo "------------------------------------------------"

grep -RIn \
    --include="*.kt" \
    -E 'VoiceInput|voiceInput|VoiceEngine|voiceListening|startListening|stopListening' \
    app/src/main/java \
    > "$LOG/voice_usage.txt" \
    2>/dev/null || true

head -150 "$LOG/voice_usage.txt"

if [ -s "$LOG/voice_usage.txt" ]; then
    pass "Voice integration references mapped"
else
    warn "No voice integration references found"
fi

echo
echo "[9/12] Constructor and enum mismatch detector"
echo "------------------------------------------------"

grep -RIn \
    --include="*.kt" \
    -E 'enum class|sealed class|data class' \
    app/src/main/java/com/monu/mobile/domain \
    app/src/main/java/com/monu/mobile/feature/conversation \
    2>/dev/null \
    > "$LOG/model_type_inventory.txt" || true

grep -nE \
    'ASSISTANT|USER|SYSTEM|Message|Conversation|Role|Status|State' \
    "$LOG/model_type_inventory.txt" \
    > "$LOG/chat_related_types.txt" || true

cat "$LOG/chat_related_types.txt"

pass "Chat-related type inventory generated"

echo
echo "[10/12] Fresh compile with complete Kotlin diagnostics"
echo "------------------------------------------------"

./gradlew --stop > "$LOG/gradle-stop.txt" 2>&1 || true

./gradlew :app:compileDebugKotlin \
    --stacktrace \
    --info \
    > "$LOG/full_compile.txt" 2>&1

COMPILE_EXIT=$?

grep -nE \
    '^e: file:|^e: |error:|Unresolved reference|No value passed|Cannot infer type|enum entry' \
    "$LOG/full_compile.txt" \
    > "$LOG/kotlin_errors_only.txt" || true

ERROR_COUNT=$(wc -l < "$LOG/kotlin_errors_only.txt" | tr -d ' ')

echo
echo "Kotlin diagnostic lines: $ERROR_COUNT"

if [ "$COMPILE_EXIT" -eq 0 ]; then
    pass "Project compile unexpectedly passed"
else
    warn "Compile still fails - diagnostics captured"
fi

echo
echo "[11/12] Error concentration analysis"
echo "------------------------------------------------"

grep '^e: file:' "$LOG/full_compile.txt" \
    | sed -E 's/.*file:\/\/([^:]+):.*/\1/' \
    | sort \
    | uniq -c \
    | sort -nr \
    > "$LOG/error_by_file.txt" || true

echo "--- ERRORS BY FILE ---"
cat "$LOG/error_by_file.txt"

TOP_ERROR_FILE=$(head -1 "$LOG/error_by_file.txt" \
    | awk '{print $2}' || true)

if [ -n "$TOP_ERROR_FILE" ]; then
    echo "PRIMARY_BLOCKER=$TOP_ERROR_FILE" \
        | tee "$LOG/primary_blocker.txt"

    pass "Primary error concentration identified"
else
    warn "Could not determine primary blocker file"
fi

echo
echo "[12/12] Generating Level 103 repair intelligence bundle"
echo "------------------------------------------------"

{
    echo "MONU MOBILE LEVEL 103"
    echo "CHAT ARCHITECTURE REPAIR INTELLIGENCE"
    echo "============================================"
    echo
    echo "BUILD ENVIRONMENT"
    echo "-----------------"
    echo "AAPT2_NATIVE=$(command -v aapt2 2>/dev/null || echo NONE)"
    echo "JAVA=$(java -version 2>&1 | head -1)"
    echo "ARCH=$(uname -m)"
    echo
    echo "COMPILE STATUS"
    echo "--------------"
    echo "COMPILE_EXIT=$COMPILE_EXIT"
    echo "KOTLIN_DIAGNOSTIC_LINES=$ERROR_COUNT"
    echo "PRIMARY_BLOCKER=${TOP_ERROR_FILE:-UNKNOWN}"
    echo
    echo "SOURCE COUNTS"
    echo "-------------"
    echo "KOTLIN_FILES=$(find app/src/main/java -type f -name '*.kt' | wc -l)"
    echo "CONVERSATION_FILES=$(find app/src/main/java/com/monu/mobile/feature/conversation -type f -name '*.kt' 2>/dev/null | wc -l)"
    echo "VOICE_FILES=$(find app/src/main/java/com/monu/mobile/feature/voice -type f -name '*.kt' 2>/dev/null | wc -l)"
    echo
    echo "CONCLUSION"
    echo "----------"
    echo "Level 102 successfully removed the host-native AAPT2 blocker."
    echo "The active blocker is now Kotlin source integration."
    echo "The Level 103 bundle maps actual model constructors, enums,"
    echo "conversation APIs, voice APIs, and ChatScreen dependencies."
    echo
    echo "NEXT REPAIR TARGET"
    echo "------------------"
    echo "Reconcile ChatScreen against actual project APIs."
    echo "Do not invent model constructors or state fields."
    echo "Use the captured source signatures as the integration contract."
    echo
    echo "RESULT"
    echo "------"
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo "WARN=$WARN"
} > "$LOG/level103_master_report.txt"

echo
echo "================================================"
echo " LEVEL 103 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "COMPILE_EXIT : $COMPILE_EXIT"
echo
echo "IMPORTANT FILES:"
echo "  $LOG/level103_master_report.txt"
echo "  $LOG/ChatScreen_numbered.txt"
echo "  $LOG/ChatModels_numbered.txt"
echo "  $LOG/conversation_public_api.txt"
echo "  $LOG/voice_public_api.txt"
echo "  $LOG/symbol_definition_map.txt"
echo "  $LOG/kotlin_errors_only.txt"
echo "  $LOG/error_by_file.txt"
echo "================================================"

echo
echo "LEVEL 103 COMPLETE"
echo "NEXT: LEVEL 104 CHAT + CONVERSATION + VOICE + OFFLINE BIG-BATCH REPAIR"
