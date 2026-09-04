#!/data/data/com.termux/files/usr/bin/bash
set -e

CHAT="app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt"
BACKUP=".monu-backups/level64/ChatScreen.before_import_repair.kt.backup"

echo "================================================"
echo " LEVEL 64 IMPORT ANCHOR REPAIR"
echo "================================================"

test -f "$CHAT"

mkdir -p "$(dirname "$BACKUP")"
cp "$CHAT" "$BACKUP"

echo "[1/3] Backup created"

python - <<'PY'
from pathlib import Path
import re

path = Path("app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt")
text = path.read_text()

imports = [
    "import android.Manifest",
    "import android.content.pm.PackageManager",
    "import androidx.activity.compose.rememberLauncherForActivityResult",
    "import androidx.activity.result.contract.ActivityResultContracts",
    "import androidx.core.content.ContextCompat",
]

missing = [imp for imp in imports if imp not in text]

if missing:
    package_match = re.search(r'^package .+\n', text, re.MULTILINE)

    if not package_match:
        raise SystemExit("FAIL: package declaration not found")

    insertion = "\n" + "\n".join(missing) + "\n"

    pos = package_match.end()
    text = text[:pos] + insertion + text[pos:]

path.write_text(text)
PY

echo "[2/3] Required imports safely inserted"

echo "[3/3] Verifying imports"

for pattern in \
    'import android.Manifest' \
    'import android.content.pm.PackageManager' \
    'import androidx.activity.compose.rememberLauncherForActivityResult' \
    'import androidx.activity.result.contract.ActivityResultContracts' \
    'import androidx.core.content.ContextCompat'
do
    grep -qF "$pattern" "$CHAT" || {
        echo "[FAIL] Missing: $pattern"
        exit 1
    }
done

echo "[PASS] All Level 64 runtime permission imports available"
echo "================================================"
echo " REPAIR COMPLETE"
echo "================================================"
