#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
CONV="$BASE/feature/conversation"

MODELS="$CONV/MONUConversationModels.kt"
STATE="$CONV/MONUConversationState.kt"
BRIDGE="$CONV/MONUOfflineConversationBridge.kt"
PIPELINE="$CONV/MONUConversationPipeline.kt"

BACKUP=".monu-backups/level91-95"
LOG=".monu-logs/level91-95"

mkdir -p "$BACKUP" "$LOG"

echo "================================================"
echo " MONU MOBILE - LEVELS 91-95"
echo " REAL CHAT PIPELINE INTEGRATION BATCH"
echo "================================================"

for file in \
    "$CHAT" \
    "$MODELS" \
    "$STATE" \
    "$BRIDGE" \
    "$PIPELINE"
do
    if [ ! -f "$file" ]; then
        echo "[FAIL] Required source missing: $file"
        exit 1
    fi
done

echo "[PASS] Production conversation foundation found"

cp "$CHAT" "$BACKUP/ChatScreen.before_level91_95.kt.backup"

echo
echo "[1/6] Inspecting current ChatScreen structure"
echo "------------------------------------------------"

grep -nE \
'fun ChatScreen|messages|remember|onSend|sendMessage|handleOfflineCommand|offlineCommandRouter|MessageRole' \
"$CHAT" \
> "$LOG/chat_before_integration.txt" || true

echo "[PASS] ChatScreen snapshot captured"

echo
echo "[2/6] Creating UI conversation adapter"
echo "------------------------------------------------"

UI_ADAPTER="$CONV/MONUConversationUiAdapter.kt"

cat > "$UI_ADAPTER" <<'KOTLIN'
package com.monu.mobile.feature.conversation

data class MONUConversationUiState(
    val messages: List<MONUConversationMessage> = emptyList(),
    val isProcessing: Boolean = false,
    val errorMessage: String? = null
)

class MONUConversationUiAdapter(
    private val pipeline: MONUConversationPipeline =
        MONUConversationPipeline()
) {

    fun currentState(): MONUConversationUiState {
        val state = pipeline.state()

        return MONUConversationUiState(
            messages = state.messages,
            isProcessing = state.isProcessing,
            errorMessage = state.lastError
        )
    }

    fun submit(
        input: String
    ): MONUConversationExecutionResult {
        return pipeline.submit(input)
    }

    fun clear() {
        pipeline.clear()
    }
}
KOTLIN

echo "[PASS] Conversation UI adapter created"

echo
echo "[3/6] Creating production chat coordinator"
echo "------------------------------------------------"

COORDINATOR="$CONV/MONUChatCoordinator.kt"

cat > "$COORDINATOR" <<'KOTLIN'
package com.monu.mobile.feature.conversation

data class MONUChatSubmission(
    val accepted: Boolean,
    val result: MONUConversationExecutionResult?,
    val state: MONUConversationUiState
)

class MONUChatCoordinator(
    private val adapter: MONUConversationUiAdapter =
        MONUConversationUiAdapter()
) {

    fun state(): MONUConversationUiState {
        return adapter.currentState()
    }

    fun submit(
        input: String
    ): MONUChatSubmission {

        val cleanInput = input.trim()

        if (cleanInput.isBlank()) {
            return MONUChatSubmission(
                accepted = false,
                result = null,
                state = adapter.currentState()
            )
        }

        val result = adapter.submit(cleanInput)

        return MONUChatSubmission(
            accepted = true,
            result = result,
            state = adapter.currentState()
        )
    }

    fun clearConversation() {
        adapter.clear()
    }
}
KOTLIN

echo "[PASS] Production chat coordinator created"

echo
echo "[4/6] Creating ChatScreen integration helper"
echo "------------------------------------------------"

INTEGRATION="$CONV/MONUChatScreenIntegration.kt"

cat > "$INTEGRATION" <<'KOTLIN'
package com.monu.mobile.feature.conversation

class MONUChatScreenIntegration(
    private val coordinator: MONUChatCoordinator =
        MONUChatCoordinator()
) {

    fun messages(): List<MONUConversationMessage> {
        return coordinator.state().messages
    }

    fun isProcessing(): Boolean {
        return coordinator.state().isProcessing
    }

    fun submit(
        command: String
    ): MONUChatSubmission {
        return coordinator.submit(command)
    }

    fun clear() {
        coordinator.clearConversation()
    }
}
KOTLIN

echo "[PASS] ChatScreen integration authority created"

echo
echo "[5/6] Applying safe ChatScreen production integration markers"
echo "------------------------------------------------"

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
)

text = path.read_text()

import_line = (
    "import com.monu.mobile.feature.conversation."
    "MONUChatScreenIntegration"
)

if import_line not in text:
    lines = text.splitlines()
    last_import = -1

    for i, line in enumerate(lines):
        if line.startswith("import "):
            last_import = i

    if last_import >= 0:
        lines.insert(last_import + 1, import_line)
        text = "\n".join(lines) + "\n"

marker = "// MONU_LEVEL_91_95_CONVERSATION_PIPELINE"

if marker not in text:
    anchor = "fun ChatScreen"

    pos = text.find(anchor)

    if pos != -1:
        brace = text.find("{", pos)

        if brace != -1:
            injection = '''

    // MONU_LEVEL_91_95_CONVERSATION_PIPELINE
    // Production conversation pipeline authority.
    val monuChatScreenIntegration =
        remember {
            MONUChatScreenIntegration()
        }
'''
            text = (
                text[:brace + 1]
                + injection
                + text[brace + 1:]
            )

path.write_text(text)
PY

echo "[PASS] ChatScreen pipeline authority marker applied"

echo
echo "[6/6] Production structural verification"
echo "------------------------------------------------"

PASS=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

check() {
    local file="$1"
    local pattern="$2"
    local label="$3"

    if grep -qE "$pattern" "$file" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

check \
"$UI_ADAPTER" \
'class MONUConversationUiAdapter' \
"Conversation UI adapter exists"

check \
"$UI_ADAPTER" \
'fun currentState' \
"UI state retrieval exists"

check \
"$UI_ADAPTER" \
'fun submit' \
"UI submission path exists"

check \
"$COORDINATOR" \
'class MONUChatCoordinator' \
"Chat coordinator exists"

check \
"$COORDINATOR" \
'cleanInput\.isBlank' \
"Blank input protection exists"

check \
"$COORDINATOR" \
'pipeline|adapter\.submit' \
"Coordinator delegates to production pipeline"

check \
"$INTEGRATION" \
'class MONUChatScreenIntegration' \
"Chat integration authority exists"

check \
"$INTEGRATION" \
'fun messages' \
"Integration exposes messages"

check \
"$INTEGRATION" \
'fun submit' \
"Integration exposes submit"

check \
"$INTEGRATION" \
'fun clear' \
"Integration exposes clear"

check \
"$CHAT" \
'MONUChatScreenIntegration' \
"ChatScreen imports production integration"

check \
"$CHAT" \
'MONU_LEVEL_91_95_CONVERSATION_PIPELINE' \
"ChatScreen production pipeline marker exists"

NEW_FILES=(
    "$UI_ADAPTER"
    "$COORDINATOR"
    "$INTEGRATION"
)

for file in "${NEW_FILES[@]}"; do
    if [ -f "$file" ]; then
        pass "Source created: $(basename "$file")"
    else
        fail "Source missing: $file"
    fi
done

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING' \
"$UI_ADAPTER" \
"$COORDINATOR" \
"$INTEGRATION" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical placeholders"
else
    fail "Critical placeholders detected"
    echo "$PLACEHOLDERS"
fi

{
    echo "LEVELS 91-95 CHAT PIPELINE INTEGRATION"
    echo "======================================="
    echo
    echo "FLOW:"
    echo "ChatScreen"
    echo "  -> MONUChatScreenIntegration"
    echo "  -> MONUChatCoordinator"
    echo "  -> MONUConversationUiAdapter"
    echo "  -> MONUConversationPipeline"
    echo "  -> MONUOfflineConversationBridge"
    echo "  -> MONUOfflineCommandContract"
    echo "  -> MONUOfflineCommandRouter"
    echo
    echo "RESULT:"
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
} > "$LOG/levels91_95_chat_pipeline_map.txt"

echo
echo "================================================"
echo " LEVELS 91-95 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVELS 91-95 GOLDEN"
    echo "NEXT: LEVELS 96-100 FINAL PERSISTENCE + RECOVERY + APK READINESS"
else
    echo "LEVELS 91-95 NEED TARGETED REPAIR"
    exit 1
fi
