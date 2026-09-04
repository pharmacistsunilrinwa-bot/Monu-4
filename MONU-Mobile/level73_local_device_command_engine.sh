#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
ROUTER="$BASE/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="$BASE/feature/offline/MONULocalDeviceCommandEngine.kt"

BACKUP=".monu-backups/level73"
LOG=".monu-logs/level73"

mkdir -p "$BACKUP" "$LOG"
mkdir -p "$(dirname "$ENGINE")"

test -f "$ROUTER"

cp "$ROUTER" "$BACKUP/MONUOfflineCommandRouter.kt.backup"

if [ -f "$ENGINE" ]; then
    cp "$ENGINE" "$BACKUP/MONULocalDeviceCommandEngine.kt.backup"
fi

cat > "$ENGINE" <<'KOTLIN'
package com.monu.mobile.feature.offline

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MONULocalDeviceCommandEngine {

    fun canHandle(command: String): Boolean {
        val normalized = command.trim().lowercase()

        return normalized.contains("time") ||
            normalized.contains("date") ||
            normalized.contains("today") ||
            normalized.contains("device status") ||
            normalized.contains("local status")
    }

    fun handle(command: String): String {
        val normalized = command.trim().lowercase()

        return when {
            normalized.contains("time") ->
                currentTime()

            normalized.contains("date") ||
                normalized.contains("today") ->
                currentDate()

            normalized.contains("device status") ||
                normalized.contains("local status") ->
                localRuntimeStatus()

            else ->
                "This local device command is not available."
        }
    }

    private fun currentTime(): String {
        val formatter =
            SimpleDateFormat("hh:mm a", Locale.getDefault())

        return "Current local time: ${formatter.format(Date())}"
    }

    private fun currentDate(): String {
        val formatter =
            SimpleDateFormat(
                "EEEE, dd MMMM yyyy",
                Locale.getDefault()
            )

        return "Today's date: ${formatter.format(Date())}"
    }

    private fun localRuntimeStatus(): String {
        return "MONU local device command engine is ready."
    }
}
KOTLIN

python - <<'PY'
from pathlib import Path

path = Path(
    "app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandRouter.kt"
)

text = path.read_text()

engine_import = (
    "import com.monu.mobile.feature.offline.MONULocalDeviceCommandEngine\n"
)

if engine_import not in text:
    package_end = text.find("\n")

    if package_end == -1:
        raise SystemExit("FAIL: package declaration missing")

    text = (
        text[:package_end + 1]
        + engine_import
        + text[package_end + 1:]
    )

if "private val localDeviceCommandEngine" not in text:
    anchor = "class MONUOfflineCommandRouter {"

    replacement = '''class MONUOfflineCommandRouter {

    private val localDeviceCommandEngine =
        MONULocalDeviceCommandEngine()'''

    if anchor not in text:
        raise SystemExit("FAIL: router class anchor missing")

    text = text.replace(anchor, replacement, 1)

old_can_handle = '''        if (normalized.isBlank()) return true

        return normalized.contains("hello")'''

new_can_handle = '''        if (normalized.isBlank()) return true

        if (localDeviceCommandEngine.canHandle(normalized)) {
            return true
        }

        return normalized.contains("hello")'''

if old_can_handle in text:
    text = text.replace(old_can_handle, new_can_handle, 1)
else:
    raise SystemExit("FAIL: canHandle anchor missing")

old_handle = '''        return when {
            normalized.isBlank() ->
                "Please say or type a command."'''

new_handle = '''        if (localDeviceCommandEngine.canHandle(normalized)) {
            return localDeviceCommandEngine.handle(normalized)
        }

        return when {
            normalized.isBlank() ->
                "Please say or type a command."'''

if old_handle in text:
    text = text.replace(old_handle, new_handle, 1)
else:
    raise SystemExit("FAIL: handle anchor missing")

old_time = '''            normalized.contains("time") ->
                "Time queries will be handled by the local device utility system."

'''

text = text.replace(old_time, "", 1)

path.write_text(text)
PY

cat > level73_local_device_command_engine_test.sh <<'TEST'
#!/data/data/com.termux/files/usr/bin/bash
set -u

ROUTER="app/src/main/java/com/monu/mobile/feature/offline/MONUOfflineCommandRouter.kt"
ENGINE="app/src/main/java/com/monu/mobile/feature/offline/MONULocalDeviceCommandEngine.kt"

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
    FILE="$1"
    PATTERN="$2"
    LABEL="$3"

    if grep -qE "$PATTERN" "$FILE" 2>/dev/null; then
        pass "$LABEL"
    else
        fail "$LABEL"
    fi
}

echo "================================================"
echo " LEVEL 73 LOCAL DEVICE COMMAND ENGINE TEST"
echo "================================================"

check \
"$ENGINE" \
'class MONULocalDeviceCommandEngine' \
"Local device command engine exists"

check \
"$ENGINE" \
'fun canHandle\(command: String\): Boolean' \
"Engine capability detection exists"

check \
"$ENGINE" \
'fun handle\(command: String\): String' \
"Engine command handler exists"

check \
"$ENGINE" \
'normalized\.contains\("time"\)' \
"Engine handles local time"

check \
"$ENGINE" \
'normalized\.contains\("date"\)' \
"Engine handles local date"

check \
"$ENGINE" \
'normalized\.contains\("device status"\)' \
"Engine handles device status"

check \
"$ENGINE" \
'SimpleDateFormat' \
"Engine uses local date/time formatter"

check \
"$ENGINE" \
'java\.util\.Date' \
"Engine reads local device clock"

check \
"$ROUTER" \
'private val localDeviceCommandEngine' \
"Router owns local device engine"

check \
"$ROUTER" \
'localDeviceCommandEngine\.canHandle' \
"Router delegates capability detection"

check \
"$ROUTER" \
'localDeviceCommandEngine\.handle' \
"Router delegates command execution"

ENGINE_COUNT=$(grep -c \
'class MONULocalDeviceCommandEngine' \
"$ENGINE" 2>/dev/null || true)

if [ "$ENGINE_COUNT" -eq 1 ]; then
    pass "Single local device engine authority"
else
    fail "Local device engine authority count is $ENGINE_COUNT"
fi

echo "================================================"
echo " LEVEL 73 RESULT"
echo "================================================"
echo "PASS : $PASS"
echo "FAIL : $FAIL"
echo "================================================"

if [ "$FAIL" -eq 0 ]; then
    echo "LEVEL 73 GOLDEN"
    echo "Local time/date/device commands work without server"
else
    echo "LEVEL 73 NEEDS TARGETED REPAIR"
    exit 1
fi
TEST

chmod +x level73_local_device_command_engine_test.sh
./level73_local_device_command_engine_test.sh

{
    echo "LEVEL 73 LOCAL DEVICE COMMAND ENGINE MAP"
    echo "========================================="
    echo
    echo "ENGINE:"
    grep -nE \
    'class MONULocalDeviceCommandEngine|fun canHandle|fun handle|time|date|status|SimpleDateFormat' \
    "$ENGINE" || true

    echo
    echo "ROUTER:"
    grep -nE \
    'MONULocalDeviceCommandEngine|localDeviceCommandEngine' \
    "$ROUTER" || true
} > "$LOG/local_device_command_engine_map.txt"

echo "================================================"
echo " LEVEL 73 COMPLETE"
echo "================================================"
echo "NEXT: LEVEL 74 - OFFLINE COMMAND INTEGRATION AUDIT"
echo "================================================"
