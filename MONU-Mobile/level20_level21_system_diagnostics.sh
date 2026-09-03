#!/usr/bin/env bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 20 + LEVEL 21"
echo " SYSTEM HEALTH + APK SELF-DIAGNOSTICS"
echo "================================================"

BASE="app/src/main/java/com/monu/mobile"

echo "[1/14] Creating package structure..."

mkdir -p \
    "$BASE/domain/model" \
    "$BASE/feature/health" \
    "$BASE/feature/diagnostics" \
    "$BASE/ui/screens" \
    docs


echo "[2/14] Creating System Health models..."

cat > "$BASE/domain/model/SystemHealthModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUHealthStatus {
    HEALTHY,
    WARNING,
    CRITICAL,
    UNKNOWN
}

data class MONUHealthMetric(
    val id: String,
    val title: String,
    val description: String,
    val status: MONUHealthStatus,
    val value: String,
    val timestamp: Long = System.currentTimeMillis()
)

data class MONUSystemHealthReport(
    val generatedAt: Long,
    val overallStatus: MONUHealthStatus,
    val metrics: List<MONUHealthMetric>
)
EOF


echo "[3/14] Creating Diagnostics models..."

cat > "$BASE/domain/model/DiagnosticModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUDiagnosticStatus {
    PASS,
    WARNING,
    FAIL,
    UNKNOWN
}

enum class MONUDiagnosticCategory {
    APPLICATION,
    STORAGE,
    NETWORK,
    PERMISSIONS,
    DATABASE,
    SERVER,
    SECURITY
}

data class MONUDiagnosticResult(
    val id: String,
    val category: MONUDiagnosticCategory,
    val title: String,
    val description: String,
    val status: MONUDiagnosticStatus,
    val timestamp: Long = System.currentTimeMillis()
)

data class MONUDiagnosticReport(
    val startedAt: Long,
    val completedAt: Long,
    val results: List<MONUDiagnosticResult>
)
EOF


echo "[4/14] Creating real System Health engine..."

cat > "$BASE/feature/health/MONUSystemHealthEngine.kt" <<'EOF'
package com.monu.mobile.feature.health

import android.content.Context
import android.os.StatFs
import com.monu.mobile.domain.model.MONUHealthMetric
import com.monu.mobile.domain.model.MONUHealthStatus
import com.monu.mobile.domain.model.MONUSystemHealthReport

class MONUSystemHealthEngine(
    private val context: Context
) {

    fun inspect(): MONUSystemHealthReport {

        val metrics = mutableListOf<MONUHealthMetric>()

        val filesDir = context.filesDir
        val stat = StatFs(filesDir.absolutePath)

        val availableBytes =
            stat.availableBlocksLong * stat.blockSizeLong

        val totalBytes =
            stat.blockCountLong * stat.blockSizeLong

        val freePercent =
            if (totalBytes > 0) {
                (availableBytes * 100 / totalBytes)
            } else {
                0
            }

        val storageStatus =
            when {
                freePercent > 20 -> MONUHealthStatus.HEALTHY
                freePercent > 10 -> MONUHealthStatus.WARNING
                else -> MONUHealthStatus.CRITICAL
            }

        metrics += MONUHealthMetric(
            id = "storage",
            title = "Application Storage",
            description = "Real application storage availability.",
            status = storageStatus,
            value = "$freePercent% free"
        )

        metrics += MONUHealthMetric(
            id = "application",
            title = "MONU Application",
            description = "APK process is currently running.",
            status = MONUHealthStatus.HEALTHY,
            value = "RUNNING"
        )

        metrics += MONUHealthMetric(
            id = "server",
            title = "Server Connectivity",
            description =
                "Server truth is determined by the real connection engine.",
            status = MONUHealthStatus.UNKNOWN,
            value = "CHECK CONNECTION CENTER"
        )

        metrics += MONUHealthMetric(
            id = "security",
            title = "Security Authority",
            description =
                "Android capability limits apply. Kernel authority is not assumed.",
            status = MONUHealthStatus.UNKNOWN,
            value = "ANDROID SANDBOX"
        )

        val overall =
            when {
                metrics.any {
                    it.status == MONUHealthStatus.CRITICAL
                } -> MONUHealthStatus.CRITICAL

                metrics.any {
                    it.status == MONUHealthStatus.WARNING
                } -> MONUHealthStatus.WARNING

                metrics.all {
                    it.status == MONUHealthStatus.HEALTHY
                } -> MONUHealthStatus.HEALTHY

                else -> MONUHealthStatus.UNKNOWN
            }

        return MONUSystemHealthReport(
            generatedAt = System.currentTimeMillis(),
            overallStatus = overall,
            metrics = metrics
        )
    }
}
EOF


echo "[5/14] Creating APK Self-Diagnostics engine..."

cat > "$BASE/feature/diagnostics/MONUSelfDiagnostics.kt" <<'EOF'
package com.monu.mobile.feature.diagnostics

import android.content.Context
import com.monu.mobile.domain.model.MONUDiagnosticCategory
import com.monu.mobile.domain.model.MONUDiagnosticReport
import com.monu.mobile.domain.model.MONUDiagnosticResult
import com.monu.mobile.domain.model.MONUDiagnosticStatus
import java.io.File

class MONUSelfDiagnostics(
    private val context: Context
) {

    fun runDiagnostics(): MONUDiagnosticReport {

        val started = System.currentTimeMillis()

        val results = mutableListOf<MONUDiagnosticResult>()

        results += checkApplication()
        results += checkStorage()
        results += checkDatabaseDirectory()
        results += checkNetworkPermission()
        results += checkServerConfiguration()

        return MONUDiagnosticReport(
            startedAt = started,
            completedAt = System.currentTimeMillis(),
            results = results
        )
    }

    private fun checkApplication(): MONUDiagnosticResult {
        return MONUDiagnosticResult(
            id = "application",
            category = MONUDiagnosticCategory.APPLICATION,
            title = "Application Runtime",
            description =
                "MONU self-diagnostic engine executed successfully.",
            status = MONUDiagnosticStatus.PASS
        )
    }

    private fun checkStorage(): MONUDiagnosticResult {

        val writable =
            try {
                val testFile =
                    File(context.cacheDir, "monu_diagnostic_test.tmp")

                testFile.writeText("MONU")
                val readable = testFile.readText() == "MONU"
                testFile.delete()

                readable
            } catch (_: Exception) {
                false
            }

        return MONUDiagnosticResult(
            id = "storage",
            category = MONUDiagnosticCategory.STORAGE,
            title = "Local Storage Access",
            description =
                if (writable) {
                    "Application storage read/write test passed."
                } else {
                    "Application storage test failed."
                },
            status =
                if (writable) {
                    MONUDiagnosticStatus.PASS
                } else {
                    MONUDiagnosticStatus.FAIL
                }
        )
    }

    private fun checkDatabaseDirectory(): MONUDiagnosticResult {

        val databaseDirectory =
            context.getDatabasePath("monu_database").parentFile

        val available =
            databaseDirectory?.exists()
                ?: false

        return MONUDiagnosticResult(
            id = "database",
            category = MONUDiagnosticCategory.DATABASE,
            title = "Database Environment",
            description =
                if (available) {
                    "Android database directory is available."
                } else {
                    "Database directory has not yet been created."
                },
            status =
                if (available) {
                    MONUDiagnosticStatus.PASS
                } else {
                    MONUDiagnosticStatus.WARNING
                }
        )
    }

    private fun checkNetworkPermission(): MONUDiagnosticResult {

        return MONUDiagnosticResult(
            id = "network",
            category = MONUDiagnosticCategory.NETWORK,
            title = "Internet Capability",
            description =
                "Manifest permission must be combined with a real network test.",
            status = MONUDiagnosticStatus.UNKNOWN
        )
    }

    private fun checkServerConfiguration(): MONUDiagnosticResult {

        return MONUDiagnosticResult(
            id = "server",
            category = MONUDiagnosticCategory.SERVER,
            title = "Server Configuration",
            description =
                "Configuration existence does not mean server connectivity.",
            status = MONUDiagnosticStatus.UNKNOWN
        )
    }
}
EOF


echo "[6/14] Creating System Health Dashboard..."

cat > "$BASE/ui/screens/SystemHealthScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.monu.mobile.feature.health.MONUSystemHealthEngine

@Composable
fun SystemHealthScreen() {

    val context = LocalContext.current

    val report =
        MONUSystemHealthEngine(context).inspect()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU System Health")

        Text(
            "Overall Status: ${report.overallStatus}"
        )

        LazyColumn(
            verticalArrangement =
                Arrangement.spacedBy(12.dp)
        ) {
            items(report.metrics) { metric ->

                Card(
                    modifier =
                        Modifier.fillMaxWidth()
                ) {

                    Column(
                        modifier =
                            Modifier.padding(16.dp)
                    ) {
                        Text(metric.title)
                        Text(metric.description)
                        Text("Status: ${metric.status}")
                        Text("Value: ${metric.value}")
                    }
                }
            }
        }
    }
}
EOF


echo "[7/14] Creating APK Diagnostics Screen..."

cat > "$BASE/ui/screens/SelfDiagnosticsScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.monu.mobile.feature.diagnostics.MONUSelfDiagnostics

@Composable
fun SelfDiagnosticsScreen() {

    val context = LocalContext.current

    var reportText by remember {
        mutableStateOf("Diagnostics not yet executed.")
    }

    var results by remember {
        mutableStateOf(
            emptyList<com.monu.mobile.domain.model.MONUDiagnosticResult>()
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU APK Self-Diagnostics")

        Button(
            onClick = {

                val report =
                    MONUSelfDiagnostics(context)
                        .runDiagnostics()

                results = report.results

                reportText =
                    "Diagnostics completed: ${results.size} checks"
            }
        ) {
            Text("Run Real Diagnostics")
        }

        Text(reportText)

        LazyColumn(
            verticalArrangement =
                Arrangement.spacedBy(12.dp)
        ) {

            items(results) { result ->

                Card(
                    modifier =
                        Modifier.fillMaxWidth()
                ) {

                    Column(
                        modifier =
                            Modifier.padding(16.dp)
                    ) {

                        Text(result.title)
                        Text(result.description)
                        Text("Category: ${result.category}")
                        Text("Status: ${result.status}")
                    }
                }
            }
        }
    }
}
EOF


echo "[8/14] Creating capability boundary documentation..."

cat > docs/ANDROID_SECURITY_BOUNDARIES.md <<'EOF'
# MONU ANDROID SECURITY BOUNDARIES

MONU must distinguish between:

1. Permission requested
2. Permission granted
3. Capability available
4. Capability actually verified

## Truth Rule

MONU must never claim:

- Kernel access
- Root access
- Other application private-data access
- Locked-device bypass
- WhatsApp private database access

unless the actual Android environment legitimately provides
that capability.

## Android Sandbox

A normal APK runs inside the Android application sandbox.

Therefore:

NORMAL APK
!=
ROOT AUTHORITY
!=
KERNEL AUTHORITY

## Security Architecture Direction

MONU can inspect capabilities legitimately available through:

- Android runtime permissions
- Storage Access Framework
- Notification Listener
- Accessibility Service where explicitly enabled
- MediaProjection with explicit user consent
- Device Administration APIs where applicable
- VPN APIs where explicitly configured
- Enterprise / Device Owner APIs on supported devices

Every capability must have:

REQUESTED
↓
USER APPROVED
↓
GRANTED / DENIED
↓
ACTUALLY VERIFIED

No capability should be presented as available merely because
a switch exists in the UI.
EOF


echo "[9/14] Creating System Health documentation..."

cat > docs/SYSTEM_HEALTH_ARCHITECTURE.md <<'EOF'
# MONU SYSTEM HEALTH ARCHITECTURE

MONU System Health is intended to report the condition of
the APK and legitimately accessible device capabilities.

Possible health areas:

- Application runtime
- Local storage
- Database
- Network
- Server connection
- WebSocket
- Offline queue
- File transfer
- Permissions
- Background services
- Security capability state

Architecture:

REAL SOURCE
↓
HEALTH ENGINE
↓
METRIC
↓
HEALTH REPORT
↓
SYSTEM HEALTH DASHBOARD

Truth Rule:

UNKNOWN is better than a false HEALTHY status.

A green status must eventually be supported by a real check.
EOF


echo "[10/14] Adding navigation destinations..."

python - <<'PY'
from pathlib import Path

p = Path(
    "app/src/main/java/com/monu/mobile/ui/navigation/MONUDestination.kt"
)

s = p.read_text()

if "SYSTEM_HEALTH" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    SYSTEM_HEALTH,
    SELF_DIAGNOSTICS,"""
    )

p.write_text(s)
PY


echo "[11/14] Updating project validation..."

python - <<'PY'
from pathlib import Path

p = Path("scripts/validate_project.sh")
s = p.read_text()

new_files = [
    "app/src/main/java/com/monu/mobile/ui/screens/SystemHealthScreen.kt",
    "app/src/main/java/com/monu/mobile/ui/screens/SelfDiagnosticsScreen.kt",
]

for f in new_files:
    if f not in s:
        s = s.replace(
            '    ".github/workflows/android.yml"',
            f'    "{f}"\n    ".github/workflows/android.yml"'
        )

p.write_text(s)
PY


echo "[12/14] Updating project status..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 20
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- System health models
- Health status lifecycle
- Real application storage inspection
- System health engine
- System Health Dashboard
- Overall health reporting

Truth Rule:
UNKNOWN is used when a capability cannot yet be verified.

## Level 21
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- APK diagnostic models
- Self-diagnostics engine
- Local storage write/read verification
- Database environment inspection
- Network diagnostic architecture
- Server diagnostic architecture
- APK Self-Diagnostics screen
- Android capability boundary documentation

Critical Security Rule:

A normal Android APK must never falsely claim:
- Kernel authority
- Root authority
- Private application data access
- Locked-device bypass
- Security powers it does not actually possess
EOF


echo "[13/14] Running structural validation..."

./scripts/validate_project.sh


echo "[14/14] Checking Level 20 + 21 files..."

find \
    "$BASE/domain/model" \
    "$BASE/feature/health" \
    "$BASE/feature/diagnostics" \
    "$BASE/ui/screens" \
    -type f | sort


echo ""
echo "================================================"
echo " LEVEL 20 + LEVEL 21 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW CAPABILITIES:"
echo "✓ System Health Architecture"
echo "✓ Real App Storage Inspection"
echo "✓ Health Status Lifecycle"
echo "✓ Overall Health Report"
echo "✓ System Health Dashboard"
echo ""
echo "✓ APK Self-Diagnostics"
echo "✓ Real Local Write/Read Check"
echo "✓ Database Environment Check"
echo "✓ Network Diagnostic Architecture"
echo "✓ Server Diagnostic Architecture"
echo "✓ Android Security Boundary Rules"
echo ""
echo "TRUTH RULE:"
echo "UNKNOWN is preferred over simulated HEALTHY."
echo ""
echo "IMPORTANT:"
echo "This is source creation and structural validation."
echo "Real Android compilation is still pending."
echo ""
echo "NEXT BUILD LEVEL:"
echo "Level 22 + 23 -> Permission Control Center + Device Capability Inspector"

