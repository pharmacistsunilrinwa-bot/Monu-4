#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

echo "================================================"
echo " MONU MOBILE - LEVEL 51"
echo " NAVIGATION REAL SCREEN MAPPING AUDIT"
echo "================================================"

echo
echo "[1/7] MAIN DESTINATIONS"
echo "------------------------------------------------"

cat "$BASE/ui/navigation/MONUDestination.kt"

echo
echo "[2/7] PRIMARY DESTINATION -> PROPOSED SCREEN"
echo "------------------------------------------------"

declare -A MAP

MAP[CONNECTION]="ConnectionScreen"
MAP[HOME]="HomeScreen"
MAP[CHAT]="ChatScreen"
MAP[TASKS]="TaskCenterScreen"
MAP[PROJECTS]="ProjectCenterScreen"
MAP[MEDIA]="MediaStudioScreen"
MAP[FILES]="TransferCenterScreen"
MAP[VOICE]="FeatureScreen"
MAP[SERVER]="ServerContractScreen"
MAP[SECURITY]="SecurityCenterScreen"
MAP[DEVICE]="DeviceCapabilityScreen"
MAP[ACTIVITY]="ActivityLogScreen"
MAP[SETTINGS]="SettingsCenterScreen"

for destination in \
CONNECTION \
HOME \
CHAT \
TASKS \
PROJECTS \
MEDIA \
FILES \
VOICE \
SERVER \
SECURITY \
DEVICE \
ACTIVITY \
SETTINGS
do

    screen="${MAP[$destination]}"

    FOUND=$(find "$BASE/ui/screens" \
        -type f \
        -name "${screen}.kt" \
        | head -1)

    if [ -n "$FOUND" ]; then
        echo "[MAP OK] $destination -> $screen"
    else
        echo "[MAP REVIEW] $destination -> $screen (file missing)"
    fi

done

echo
echo "[3/7] ALL AVAILABLE SCREEN FUNCTIONS"
echo "------------------------------------------------"

grep -RInE \
'^fun [A-Za-z0-9_]+Screen[[:space:]]*\(' \
"$BASE/ui/screens" \
2>/dev/null \
| sort

echo
echo "[4/7] CURRENTLY WIRED IN MONUApp"
echo "------------------------------------------------"

grep -nE \
'HomeScreen|ChatScreen|ConnectionScreen|FeatureScreen' \
"$BASE/ui/MONUApp.kt" \
2>/dev/null || true

echo
echo "[5/7] SCREEN FILE IMPORT REQUIREMENTS"
echo "------------------------------------------------"

for screen in \
ConnectionScreen \
HomeScreen \
ChatScreen \
TaskCenterScreen \
ProjectCenterScreen \
MediaStudioScreen \
TransferCenterScreen \
ServerContractScreen \
SecurityCenterScreen \
DeviceCapabilityScreen \
ActivityLogScreen \
SettingsCenterScreen
do

    file=$(find "$BASE/ui/screens" \
        -name "${screen}.kt" \
        -type f \
        | head -1)

    if [ -n "$file" ]; then
        echo
        echo "--- $screen ---"
        head -12 "$file"
    fi

done

echo
echo "[6/7] FUNCTION SIGNATURE CHECK"
echo "------------------------------------------------"

for screen in \
ConnectionScreen \
HomeScreen \
ChatScreen \
TaskCenterScreen \
ProjectCenterScreen \
MediaStudioScreen \
TransferCenterScreen \
ServerContractScreen \
SecurityCenterScreen \
DeviceCapabilityScreen \
ActivityLogScreen \
SettingsCenterScreen
do

    echo
    echo "Checking $screen"

    grep -RIn \
"fun $screen" \
"$BASE/ui/screens" \
2>/dev/null || \
echo "[NOT FOUND] $screen"

done

echo
echo "[7/7] NAVIGATION READINESS"
echo "================================================"

TOTAL=13

WIRED=0

for destination in \
CONNECTION \
HOME \
CHAT \
TASKS \
PROJECTS \
MEDIA \
FILES \
VOICE \
SERVER \
SECURITY \
DEVICE \
ACTIVITY \
SETTINGS
do

    screen="${MAP[$destination]}"

    if [ "$screen" = "FeatureScreen" ]; then
        echo "[SPECIAL REVIEW] $destination needs dedicated decision"
    else
        if find "$BASE/ui/screens" \
            -name "${screen}.kt" \
            -type f \
            | grep -q .; then

            WIRED=$((WIRED + 1))
        fi
    fi
done

echo
echo "Primary destinations: $TOTAL"
echo "Real screen candidates found: $WIRED"

echo
echo "IMPORTANT:"
echo "This level changes NOTHING."
echo "It verifies screen signatures before"
echo "Level 52 performs actual navigation wiring."

echo
echo "================================================"
echo " LEVEL 51 AUDIT COMPLETE"
echo "================================================"
