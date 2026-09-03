#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=========================================="
echo " MONU MOBILE - LEVEL 1 BUILD FOUNDATION"
echo "=========================================="

# Verify project root
if [ ! -f "settings.gradle.kts" ]; then
    echo "ERROR: Run this inside MONU-Mobile project root."
    exit 1
fi

echo ""
echo "[1/6] Creating Gradle wrapper configuration..."

mkdir -p gradle/wrapper

cat > gradle/wrapper/gradle-wrapper.properties <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

echo ""
echo "[2/6] Creating GitHub build verification workflow..."

cat > .github/workflows/android.yml <<'EOF'
name: MONU Mobile Android Build

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build:
    name: Build MONU APK
    runs-on: ubuntu-latest

    steps:

      - name: Checkout Source
        uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"

      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v4

      - name: Show Project
        run: |
          echo "MONU Mobile Build Started"
          find . -maxdepth 3 -type f | sort

      - name: Build Debug APK
        run: gradle :app:assembleDebug --stacktrace

      - name: Verify APK Exists
        run: |
          test -f app/build/outputs/apk/debug/app-debug.apk
          echo "APK VERIFIED SUCCESSFULLY"

      - name: Upload Debug APK
        uses: actions/upload-artifact@v4
        with:
          name: MONU-Mobile-debug-APK
          path: app/build/outputs/apk/debug/app-debug.apk
          if-no-files-found: error
          retention-days: 30
EOF

echo ""
echo "[3/6] Creating Android project validation script..."

mkdir -p scripts

cat > scripts/validate_project.sh <<'EOF'
#!/usr/bin/env bash
set -e

echo "================================"
echo " MONU PROJECT VALIDATION"
echo "================================"

REQUIRED_FILES=(
    "settings.gradle.kts"
    "build.gradle.kts"
    "gradle.properties"
    "app/build.gradle.kts"
    "app/src/main/AndroidManifest.xml"
    "app/src/main/java/com/monu/mobile/MainActivity.kt"
    "app/src/main/java/com/monu/mobile/ui/MONUApp.kt"
    ".github/workflows/android.yml"
    "README.md"
)

FAILED=0

for FILE in "${REQUIRED_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "[OK] $FILE"
    else
        echo "[MISSING] $FILE"
        FAILED=1
    fi
done

echo ""

if [ "$FAILED" -eq 1 ]; then
    echo "VALIDATION FAILED"
    exit 1
fi

echo "VALIDATION PASSED"
EOF

chmod +x scripts/validate_project.sh

echo ""
echo "[4/6] Creating project architecture registry..."

cat > docs/PROJECT_STATUS.md <<'EOF'
# MONU MOBILE PROJECT STATUS

## Level 0
Status: COMPLETE

Created:
- Android project foundation
- Kotlin configuration
- Compose foundation
- Initial MONU home
- Architecture folders
- GitHub workflow foundation

## Level 1
Status: COMPLETE

Added:
- GitHub APK verification
- Project validation
- Build artifact verification
- Build documentation

## Development Rule

A feature is not considered complete merely because:
- UI exists
- A status light exists
- A mock response exists
- A unit test passes

A feature is GOLDEN only after its intended real behavior is verified.

## Current External Configuration

Server API:
NOT CONFIGURED

WebSocket:
NOT CONFIGURED

AI Provider:
NOT CONFIGURED

Search Provider:
NOT CONFIGURED

Push Notifications:
NOT CONFIGURED
EOF

echo ""
echo "[5/6] Validating project..."

./scripts/validate_project.sh

echo ""
echo "[6/6] Checking Git status..."

if command -v git >/dev/null 2>&1; then
    git status --short 2>/dev/null || true
else
    echo "Git not installed in current environment."
fi

echo ""
echo "=========================================="
echo " LEVEL 1 FOUNDATION VALIDATION COMPLETE"
echo "=========================================="
echo ""
echo "Next build target:"
echo "GitHub Actions -> Debug APK artifact"
echo ""
echo "Current project files:"
find . -maxdepth 3 -type f | sort
