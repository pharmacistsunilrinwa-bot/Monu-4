#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
PARSER="$BASE/feature/offline/MONUOfflineCommandIntentParser.kt"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/feature/offline/MONULocalDeviceCommandEngine.kt"
MATRIX="$BASE/feature/offline/MONUOfflineCommandCapabilityMatrix.kt"

BACKUP=".monu-backups/level77"
LOG=".monu-logs/level77"

mkdir -p "$BACKUP" "$LOG"
mkdir -p "$(dirname "$MATRIX")"

test -f "$PARSER"
test -f "$ROUTER"
test -f "$ENGINE"

cp "$PARSER" "$BACKUP/MONUOfflineCommandIntentParser.kt.backup"
cp "$ROUTER" "$BACKUP/MONUOfflineCommandRouter.kt.backup"
cp "$ENGINE" "$BACKUP/MONULocalDeviceCommandEngine.kt.backup"

if [ -f "$MATRIX" ]; then
    cp "$MATRIX" \
    "$BACKUP/MONUOfflineCommandCapabilityMatrix.kt.backup"
fi

cat > "$MATRIX" <<'KOTLIN'
package com.monu.mobile.feature.offline

data class MONUOfflineCommandCapability(
    val intent: MONUOfflineCommandIntent,
    val executionOwner: String,
    val description: String
)

class MONUOfflineCommandCapabilityMatrix {

    fun capabilities(): List<MONUOfflineCommandCapability> {
        return listOf(
            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.EMPTY,
                executionOwner = "Router",
                description = "Handles blank commands safely."
            ),

            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.GREETING,
                executionOwner = "Router",
                description = "Handles local greetings."
            ),

            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.HELP,
                executionOwner = "Router",
                description = "Provides available offline commands."
            ),

            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.STATUS,
                executionOwner = "Router",
                description = "Reports MONU offline runtime status."
            ),

            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.IDENTITY,
                executionOwner = "Router",
                description = "Explains MONU identity."
            ),

            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.TIME,
                executionOwner = "LocalDeviceEngine",
                description = "Reads current local device time."
            ),

            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.DATE,
                executionOwner = "LocalDeviceEngine",
                description = "Reads current local device date."
            ),

            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.LOCAL_STATUS,
                executionOwner = "LocalDeviceEngine",
                description = "Reports local device command runtime status."
            ),

            MONUOfflineCommandCapability(
                intent = MONUOfflineCommandIntent.UNKNOWN,
                executionOwner = "Router",
                description = "Safely handles unsupported offline commands."
            )
        )
    }

    fun ownerFor(
        intent: MONUOfflineCommandIntent
    ): String? {
        return capabilities()
            .firstOrNull { it.intent == intent }
            ?.executionOwner
    }

    fun supports(
        intent: MONUOfflineCommandIntent
    ): Boolean {
        return capabilities()
            .any { it.intent == intent }
    }
}
KOTLIN

cat > level77_offline_command_capability_matrix_test.sh <<'TEST'
#!/data/data/com.termux/files/usr/bin/bash
set -u

MATRIX="app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandCapabilityMatrix.kt"

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
    local pattern="$1"
    local label="$2"

    if grep -qE "$pattern" "$MATRIX" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

echo "================================================"
echo " LEVEL 77 OFFLINE COMMAND CAPABILITY MATRIX TEST"
echo "================================================"

check \
'data class MONUOfflineCommandCapability' \
"Capability data model exists"

check \
'class MONUOfflineCommandCapabilityMatrix' \
"Capability matrix exists"

check \
'fun capabilities\(\): List<MONUOfflineCommandCapability>' \
"Capability list function exists"

check \
'fun ownerFor\(' \
"Capability owner lookup exists"

check \
'fun supports\(' \
"Capability support lookup exists"

for intent in \
EMPTY \
GREETING \
HELP \
STATUS \
IDENTITY \
TIME \
DATE \
LOCAL_STATUS \
UNKNOWN
do
    check \
    "MONUOfflineCommandIntent\\.$intent" \
    "Matrix covers intent: $intent"
done

check \
'executionOwner = "Router"' \
"Router ownership exists"

check \
'executionOwner = "LocalDeviceEngine"' \
"Local device engine ownership exists"

COUNT=$(grep -c \
'class MONUOfflineCommandCapabilityMatrix' \
"$MATRIX" 2>/dev/null || true)

if [ "$COUNT" -eq 1 ]; then
    pass "Single capability matrix authority"
else
    fail "Capability matrix authority count is $COUNT"
fi

echo "================================================"
echo " LEVEL 77 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 77 GOLDEN"
    echo "Offline command capability ownership matrix verified"
else
    echo "LEVEL 77 NEEDS TARGETED REPAIR"
    exit 1
fi
TEST

chmod +x level77_offline_command_capability_matrix_test.sh

./level77_offline_command_capability_matrix_test.sh

{
    echo "LEVEL 77 OFFLINE COMMAND CAPABILITY MATRIX MAP"
    echo "==============================================="
    echo
    grep -nE \
    'MONUOfflineCommandCapability|MONUOfflineCommandIntent|executionOwner|ownerFor|supports' \
    "$MATRIX" || true
} > "$LOG/offline_command_capability_matrix_map.txt"

echo
echo "================================================"
echo " LEVEL 77 COMPLETE"
echo "================================================"

if [ -f "level78_offline_command_scenario_audit.sh" ]; then
    echo "RE-RUNNING LEVEL 78 SCENARIO AUDIT"
    echo "================================================"
    ./level78_offline_command_scenario_audit.sh
else
    echo "LEVEL 78 AUDIT SCRIPT NOT FOUND"
    echo "NEXT: LEVEL 78 - OFFLINE COMMAND SCENARIO AUDIT"
fi

echo "================================================"
echo " LEVEL 77 COMPLETE"
echo "================================================"
echo "EXPECTED FLOW:"
echo "LEVEL 77 -> CAPABILITY MATRIX"
echo "LEVEL 78 -> SCENARIO AUDIT"
echo "================================================"
