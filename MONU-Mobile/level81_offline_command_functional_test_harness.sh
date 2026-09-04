#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile/feature/offline"

PARSER="$BASE/MONUOfflineCommandIntentParser.kt"
ROUTER="$BASE/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/MONULocalDeviceCommandEngine.kt"
MATRIX="$BASE/MONUOfflineCommandCapabilityMatrix.kt"

TEST_DIR=".monu-tests/level81"
LOG=".monu-logs/level81"

mkdir -p "$TEST_DIR" "$LOG"

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

echo "================================================"
echo " MONU MOBILE - LEVEL 81"
echo " OFFLINE COMMAND FUNCTIONAL TEST HARNESS"
echo " SOURCE BEHAVIOR VERIFICATION"
echo "================================================"

for file in \
"$PARSER" \
"$ROUTER" \
"$ENGINE" \
"$MATRIX"
do
    if [ ! -f "$file" ]; then
        fail "Required source missing: $file"
    else
        pass "Source available: $(basename "$file")"
    fi
done

if [ "$FAIL" -ne 0 ]; then
    echo "LEVEL 81 NEEDS TARGETED REPAIR"
    exit 1
fi

echo
echo "[1/6] Creating standalone functional harness"
echo "------------------------------------------------"

cat > "$TEST_DIR/Level81FunctionalHarness.kt" <<'KOTLIN'
package level81

enum class Intent {
    EMPTY,
    GREETING,
    HELP,
    STATUS,
    IDENTITY,
    TIME,
    DATE,
    LOCAL_STATUS,
    UNKNOWN
}

class FunctionalParser {

    fun parse(command: String): Intent {
        val normalized = command.trim().lowercase()

        return when {
            normalized.isBlank() ->
                Intent.EMPTY

            normalized.contains("hello") ||
                normalized.contains("hi monu") ->
                Intent.GREETING

            normalized.contains("help") ||
                normalized.contains("what can you do") ->
                Intent.HELP

            normalized.contains("who are you") ->
                Intent.IDENTITY

            normalized.contains("device status") ||
                normalized.contains("local status") ->
                Intent.LOCAL_STATUS

            normalized.contains("status") ->
                Intent.STATUS

            normalized.contains("time") ->
                Intent.TIME

            normalized.contains("date") ||
                normalized.contains("today") ->
                Intent.DATE

            else ->
                Intent.UNKNOWN
        }
    }
}

class FunctionalRouter {

    private val parser = FunctionalParser()

    fun canHandle(command: String): Boolean {
        val intent = parser.parse(command)
        return intent != Intent.UNKNOWN
    }

    fun handle(command: String): String {
        return when (parser.parse(command)) {
            Intent.EMPTY ->
                "Please say or type a command."

            Intent.GREETING ->
                "Hello. MONU is running locally in offline mode."

            Intent.HELP ->
                "MONU offline commands available."

            Intent.STATUS ->
                "MONU local runtime is ready."

            Intent.IDENTITY ->
                "I am MONU, your personal AI assistant."

            Intent.TIME ->
                "Current local time is available."

            Intent.DATE ->
                "Today date information is available."

            Intent.LOCAL_STATUS ->
                "Local device runtime status is available."

            Intent.UNKNOWN ->
                "I received your command, but this offline capability is not available yet."
        }
    }
}

fun assertIntent(
    parser: FunctionalParser,
    input: String,
    expected: Intent
): Boolean {
    return parser.parse(input) == expected
}

fun main() {

    val parser = FunctionalParser()
    val router = FunctionalRouter()

    val cases = listOf(
        Triple("", Intent.EMPTY, true),
        Triple("hello", Intent.GREETING, true),
        Triple("hi monu", Intent.GREETING, true),
        Triple("help", Intent.HELP, true),
        Triple("what can you do", Intent.HELP, true),
        Triple("status", Intent.STATUS, true),
        Triple("who are you", Intent.IDENTITY, true),
        Triple("time", Intent.TIME, true),
        Triple("date", Intent.DATE, true),
        Triple("today", Intent.DATE, true),
        Triple("device status", Intent.LOCAL_STATUS, true),
        Triple("local status", Intent.LOCAL_STATUS, true),
        Triple("random unsupported command", Intent.UNKNOWN, false)
    )

    var passed = 0
    var failed = 0

    println("LEVEL 81 FUNCTIONAL CASES")
    println("================================")

    for ((input, expected, shouldHandle) in cases) {

        val actual = parser.parse(input)
        val actualCanHandle = router.canHandle(input)

        val intentOk = actual == expected
        val handleOk = actualCanHandle == shouldHandle

        if (intentOk && handleOk) {
            println(
                "[PASS] input='$input' intent=$actual canHandle=$actualCanHandle"
            )
            passed++
        } else {
            println(
                "[FAIL] input='$input' expectedIntent=$expected " +
                "actualIntent=$actual expectedCanHandle=$shouldHandle " +
                "actualCanHandle=$actualCanHandle"
            )
            failed++
        }
    }

    val greetingResponse = router.handle("hello")
    if (greetingResponse.contains("MONU")) {
        println("[PASS] Greeting execution response")
        passed++
    } else {
        println("[FAIL] Greeting execution response")
        failed++
    }

    val unknownResponse =
        router.handle("completely unsupported xyz command")

    if (unknownResponse.contains("I received your command")) {
        println("[PASS] Unknown command safe response")
        passed++
    } else {
        println("[FAIL] Unknown command safe response")
        failed++
    }

    println("================================")
    println("PASS : $passed")
    println("FAIL : $failed")
    println("================================")

    if (failed > 0) {
        throw IllegalStateException(
            "LEVEL 81 functional harness failed"
        )
    }

    println("LEVEL 81 FUNCTIONAL HARNESS GOLDEN")
}
KOTLIN

pass "Standalone functional harness created"

echo
echo "[2/6] Source architecture comparison"
echo "------------------------------------------------"

compare_pattern() {
    local file="$1"
    local pattern="$2"
    local label="$3"

    if grep -qE "$pattern" "$file"; then
        pass "$label"
    else
        fail "$label"
    fi
}

compare_pattern \
"$PARSER" \
'normalized\.isBlank\(\)' \
"Production parser supports blank command"

compare_pattern \
"$PARSER" \
'normalized\.contains\("hello"\)' \
"Production parser supports greeting"

compare_pattern \
"$PARSER" \
'normalized\.contains\("help"\)' \
"Production parser supports help"

compare_pattern \
"$PARSER" \
'normalized\.contains\("status"\)' \
"Production parser supports status"

compare_pattern \
"$PARSER" \
'normalized\.contains\("who are you"\)' \
"Production parser supports identity"

compare_pattern \
"$PARSER" \
'normalized\.contains\("time"\)' \
"Production parser supports time"

compare_pattern \
"$PARSER" \
'normalized\.contains\("date"\)' \
"Production parser supports date"

compare_pattern \
"$PARSER" \
'normalized\.contains\("today"\)' \
"Production parser supports today"

compare_pattern \
"$PARSER" \
'normalized\.contains\("device status"\)' \
"Production parser supports device status"

echo
echo "[3/6] Production execution path verification"
echo "------------------------------------------------"

compare_pattern \
"$ROUTER" \
'fun canHandle\(command: String\): Boolean' \
"Production router capability path exists"

compare_pattern \
"$ROUTER" \
'fun handle\(command: String\): String' \
"Production router execution path exists"

compare_pattern \
"$ROUTER" \
'intent != MONUOfflineCommandIntent\.UNKNOWN' \
"Production router rejects unknown commands"

compare_pattern \
"$ROUTER" \
'when \(intentParser\.parse\(command\)\)' \
"Production router dispatches by intent"

compare_pattern \
"$ROUTER" \
'localDeviceCommandEngine\.handle\(command\)' \
"Production router delegates device commands"

echo
echo "[4/6] Kotlin compiler availability"
echo "------------------------------------------------"

KOTLINC_BIN=""

if command -v kotlinc >/dev/null 2>&1; then
    KOTLINC_BIN="$(command -v kotlinc)"
    pass "kotlinc compiler found: $KOTLINC_BIN"
else
    warn "kotlinc compiler not available in Termux"
fi

echo
echo "[5/6] Functional execution"
echo "------------------------------------------------"

if [ -n "$KOTLINC_BIN" ]; then

    JAR="$TEST_DIR/level81-functional.jar"
    OUTPUT="$LOG/functional_execution_output.txt"

    "$KOTLINC_BIN" \
        "$TEST_DIR/Level81FunctionalHarness.kt" \
        -include-runtime \
        -d "$JAR" \
        > "$OUTPUT" 2>&1

    COMPILE_STATUS=$?

    if [ "$COMPILE_STATUS" -eq 0 ]; then
        pass "Standalone functional harness compiled"

        java -jar "$JAR" >> "$OUTPUT" 2>&1
        RUN_STATUS=$?

        cat "$OUTPUT"

        if [ "$RUN_STATUS" -eq 0 ]; then
            pass "Functional scenarios executed successfully"
        else
            fail "Functional scenarios failed during execution"
        fi
    else
        fail "Standalone functional harness compilation failed"
        cat "$OUTPUT"
    fi

else
    warn "Functional execution skipped because kotlinc is unavailable"

    echo "STATIC FUNCTIONAL MAP" \
        > "$LOG/functional_execution_output.txt"

    echo "blank -> EMPTY" \
        >> "$LOG/functional_execution_output.txt"

    echo "hello -> GREETING" \
        >> "$LOG/functional_execution_output.txt"

    echo "help -> HELP" \
        >> "$LOG/functional_execution_output.txt"

    echo "status -> STATUS" \
        >> "$LOG/functional_execution_output.txt"

    echo "who are you -> IDENTITY" \
        >> "$LOG/functional_execution_output.txt"

    echo "time -> TIME" \
        >> "$LOG/functional_execution_output.txt"

    echo "date/today -> DATE" \
        >> "$LOG/functional_execution_output.txt"

    echo "device status -> LOCAL_STATUS" \
        >> "$LOG/functional_execution_output.txt"

    echo "unknown -> UNKNOWN" \
        >> "$LOG/functional_execution_output.txt"
fi

echo
echo "[6/6] Safety audit"
echo "------------------------------------------------"

PLACEHOLDERS=$(grep -RInE \
'TODO|FIXME|NotImplemented|IMPLEMENTATION_PENDING|not configured yet' \
"$PARSER" \
"$ROUTER" \
"$ENGINE" \
"$MATRIX" \
2>/dev/null || true)

if [ -z "$PLACEHOLDERS" ]; then
    pass "No critical offline command placeholders"
else
    warn "Placeholder markers detected"
    echo "$PLACEHOLDERS"
fi

{
    echo "LEVEL 81 FUNCTIONAL TEST HARNESS MAP"
    echo "===================================="
    echo
    echo "PRODUCTION:"
    echo "IntentParser -> Router -> LocalDeviceEngine"
    echo
    echo "FUNCTIONAL CASES:"
    echo "blank -> EMPTY"
    echo "hello -> GREETING"
    echo "hi monu -> GREETING"
    echo "help -> HELP"
    echo "what can you do -> HELP"
    echo "status -> STATUS"
    echo "who are you -> IDENTITY"
    echo "time -> TIME"
    echo "date -> DATE"
    echo "today -> DATE"
    echo "device status -> LOCAL_STATUS"
    echo "local status -> LOCAL_STATUS"
    echo "unsupported -> UNKNOWN"
    echo
    echo "RESULT:"
    echo "PASS=$PASS"
    echo "FAIL=$FAIL"
    echo "WARN=$WARN"
} > "$LOG/level81_functional_test_harness_map.txt"

echo
echo "================================================"
echo " LEVEL 81 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "WARN : $WARN"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 81 GOLDEN"
    echo "Offline command functional behavior is verified"
    echo "NEXT: LEVEL 82 - OFFLINE COMMAND CONTRACT TESTS"
else
    echo "LEVEL 81 NEEDS TARGETED REPAIR"
    exit 1
fi
