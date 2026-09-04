#!/data/data/com.termux/files/usr/bin/bash
set -u

BASE="app/src/main/java/com/monu/mobile"

echo "================================================"
echo " MONU MOBILE - LEVEL 47"
echo " NAVIGATION INTEGRATION AUDIT"
echo "================================================"

echo
echo "[1/6] ALL DESTINATIONS"
echo "------------------------------------------------"
cat "$BASE/ui/navigation/MONUDestination.kt"

echo
echo "[2/6] ALL SCREEN FUNCTIONS"
echo "------------------------------------------------"

grep -RInE \
'fun [A-Za-z0-9_]+Screen[[:space:]]*\(' \
"$BASE/ui/screens" \
2>/dev/null | sort

echo
echo "[3/6] CURRENT MONUAPP NAVIGATION"
echo "------------------------------------------------"

grep -nE \
'MONUDestination|->|Screen\(' \
"$BASE/ui/MONUApp.kt" \
2>/dev/null

echo
echo "[4/6] DESTINATION COUNT"
echo "------------------------------------------------"

grep -E '^[[:space:]]*[A-Z_]+[,(]' \
"$BASE/ui/navigation/MONUDestination.kt" \
2>/dev/null | wc -l

echo
echo "[5/6] SCREEN COUNT"
echo "------------------------------------------------"

find "$BASE/ui/screens" \
-type f \
-name '*.kt' \
| wc -l

echo
echo "[6/6] UNWIRED SCREEN CANDIDATES"
echo "------------------------------------------------"

for file in "$BASE"/ui/screens/*.kt
do
    name=$(basename "$file" .kt)

    if ! grep -q "$name" "$BASE/ui/MONUApp.kt"; then
        echo "[UNWIRED] $name"
    fi
done

echo
echo "================================================"
echo " LEVEL 47 AUDIT COMPLETE"
echo "================================================"
echo
echo "NEXT:"
echo "Automatic navigation integration will wire"
echo "all valid destinations without deleting"
echo "existing screens or architecture."
