#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
CHAT="$BASE/ui/screens/ChatScreen.kt"
OFFLINE="$BASE/feature/offline"

PARSER="$OFFLINE/MONUOfflineCommandIntentParser.kt"
ROUTER="$OFFLINE/MONUOfflineCommandRouter.kt"
ENGINE="$OFFLINE/MONULocalDeviceCommandEngine.kt"
MATRIX="$OFFLINE/MONUOfflineCommandCapabilityMatrix.kt"
CONTRACT="$OFFLINE/MONUOfflineCommandContract.kt"

OUT=".monu-logs/level84"
mkdir -p "$OUT"

echo "================================================"
echo " MONU MOBILE - LEVEL 84"
echo " PRODUCTION PIPELINE SOURCE SNAPSHOT"
echo "================================================"

for file in \
"$CHAT" \
"$PARSER" \
"$ROUTER" \
"$ENGINE" \
"$MATRIX" \
"$CONTRACT"
do
    if [ ! -f "$file" ]; then
        echo "[FAIL] Missing: $file"
        exit 1
    fi
done

echo "[PASS] All production pipeline sources found"

echo
echo "[1/4] Capturing source structure"

{
    echo "LEVEL 84 PRODUCTION SOURCE SNAPSHOT"
    echo "===================================="
    echo
    echo "===== CHATSCREEN ====="
    grep -nE \
    'fun |class |val offlineCommandRouter|handleOfflineCommand|MessageRole|onSend|sendMessage|messages' \
    "$CHAT" || true

    echo
    echo "===== ROUTER ====="
    grep -nE \
    'class |override fun|fun canHandle|fun handle|fun execute|intentParser|localDeviceCommandEngine' \
    "$ROUTER" || true

    echo
    echo "===== CONTRACT ====="
    cat "$CONTRACT"

    echo
    echo "===== INTENT PARSER ====="
    grep -nE \
    'enum class|class |fun parse|EMPTY|GREETING|HELP|STATUS|IDENTITY|TIME|DATE|LOCAL_STATUS|UNKNOWN' \
    "$PARSER" || true

    echo
    echo "===== LOCAL ENGINE ====="
    grep -nE \
    'class |fun canHandle|fun handle|currentTime|currentDate|localRuntimeStatus' \
    "$ENGINE" || true

    echo
    echo "===== CAPABILITY MATRIX ====="
    grep -nE \
    'data class|class |fun capabilities|fun ownerFor|fun supports|executionOwner' \
    "$MATRIX" || true

} > "$OUT/production_pipeline_source_snapshot.txt"

echo "[PASS] Source architecture snapshot created"

echo
echo "[2/4] Checking production contract integration"

PASS=0
FAIL=0

check() {
    local file="$1"
    local pattern="$2"
    local label="$3"

    if grep -qE "$pattern" "$file" 2>/dev/null; then
        echo "[PASS] $label"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $label"
        FAIL=$((FAIL + 1))
    fi
}

check \
"$ROUTER" \
'class MONUOfflineCommandRouter.*MONUOfflineCommandContract' \
"Router implements production contract"

check \
"$ROUTER" \
'override fun execute' \
"Router structured execute path exists"

check \
"$ROUTER" \
'MONUOfflineCommandResponse' \
"Router produces structured response"

check \
"$CONTRACT" \
'data class MONUOfflineCommandRequest' \
"Structured request exists"

check \
"$CONTRACT" \
'data class MONUOfflineCommandResponse' \
"Structured response exists"

echo
echo "[3/4] Capturing exact ChatScreen integration points"

grep -nE \
'handleOfflineCommand|offlineCommandRouter|MessageRole|ASSISTANT|USER|remember' \
"$CHAT" \
> "$OUT/chat_integration_points.txt" || true

echo "[PASS] Chat integration points captured"

echo
echo "[4/4] Production pipeline readiness"

{
    echo "LEVEL 84 PIPELINE"
    echo "================="
    echo
    echo "CURRENT:"
    echo "ChatScreen"
    echo "    ->"
    echo "MONUOfflineCommandRouter"
    echo "    ->"
    echo "MONUOfflineCommandIntentParser"
    echo "    ->"
    echo "Router / LocalDeviceEngine"
    echo
    echo "NEW PRODUCTION CONTRACT:"
    echo "MONUOfflineCommandRequest"
    echo "    ->"
    echo "MONUOfflineCommandContract"
    echo "    ->"
    echo "MONUOfflineCommandResponse"
    echo
    echo "NEXT BATCH:"
    echo "84-87 = Structured Chat Integration +"
    echo "Conversation State + Persistence Foundation"
} > "$OUT/level84_pipeline_plan.txt"

echo "[PASS] Next implementation batch prepared"

echo
echo "================================================"
echo " LEVEL 84 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 84 GOLDEN"
    echo "Production source structure captured safely"
    echo
    echo "IMPORTANT:"
    echo "NEXT RESPONSE WILL USE THE SNAPSHOT TO APPLY"
    echo "A LARGER MULTI-FILE IMPLEMENTATION BATCH."
else
    echo "LEVEL 84 NEEDS REPAIR"
    exit 1
fi
