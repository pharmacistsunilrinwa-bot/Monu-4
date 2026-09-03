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
    "app/src/main/java/com/monu/mobile/ui/screens/SystemHealthScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/SelfDiagnosticsScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/PermissionControlScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/DeviceCapabilityScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/SettingsCenterScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/BackupRestoreScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/SecurityCenterScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/AuditTrailScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/IdentitySessionScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/CommandHistoryScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/WorkflowAutomationScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/RulesEngineScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/KnowledgeCenterScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/ContextIntelligenceScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/DecisionCenterScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/PlanningIntelligenceScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/ExecutionOrchestratorScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/VerificationEngineScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/EventIntelligenceScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/StateSynchronizationScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/IntegrationHubScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/ServiceCoordinationScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/OptimizationIntelligenceScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/SystemRecoveryScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/UnifiedIntelligenceScreen.kt"
    "app/src/main/java/com/monu/mobile/ui/screens/PlatformArchitectureScreen.kt"
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
