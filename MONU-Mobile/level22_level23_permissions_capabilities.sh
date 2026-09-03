#!/usr/bin/env bash
set -euo pipefail

BASE="app/src/main/java/com/monu/mobile"

echo "================================================"
echo " MONU MOBILE - LEVEL 22 + LEVEL 23"
echo " PERMISSION CONTROL + DEVICE CAPABILITY INSPECTOR"
echo "================================================"

echo "[1/14] Creating package structure..."

mkdir -p \
    "$BASE/domain/model" \
    "$BASE/feature/permissions" \
    "$BASE/feature/capabilities" \
    "$BASE/ui/screens" \
    docs

echo "[2/14] Creating permission models..."

cat > "$BASE/domain/model/PermissionModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUPermissionStatus {
    NOT_REQUESTED,
    GRANTED,
    DENIED,
    UNKNOWN
}

data class MONUPermission(
    val id: String,
    val androidPermission: String,
    val title: String,
    val description: String,
    val status: MONUPermissionStatus
)
EOF

echo "[3/14] Creating device capability models..."

cat > "$BASE/domain/model/DeviceCapabilityModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUCapabilityStatus {
    AVAILABLE,
    UNAVAILABLE,
    REQUIRES_PERMISSION,
    REQUIRES_USER_ACTION,
    UNKNOWN
}

data class MONUDeviceCapability(
    val id: String,
    val title: String,
    val description: String,
    val status: MONUCapabilityStatus,
    val verified: Boolean
)
EOF

echo "[4/14] Creating Permission Control engine..."

cat > "$BASE/feature/permissions/MONUPermissionCenter.kt" <<'EOF'
package com.monu.mobile.feature.permissions

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.monu.mobile.domain.model.MONUPermission
import com.monu.mobile.domain.model.MONUPermissionStatus

class MONUPermissionCenter(
    private val context: Context
) {

    fun inspect(): List<MONUPermission> {
        return listOf(
            permission(
                "camera",
                Manifest.permission.CAMERA,
                "Camera",
                "Required only for camera features."
            ),
            permission(
                "audio",
                Manifest.permission.RECORD_AUDIO,
                "Microphone",
                "Required only for voice input."
            ),
            permission(
                "notifications",
                Manifest.permission.POST_NOTIFICATIONS,
                "Notifications",
                "Required for Android notification delivery."
            )
        )
    }

    private fun permission(
        id: String,
        permission: String,
        title: String,
        description: String
    ): MONUPermission {
        val granted =
            ContextCompat.checkSelfPermission(
                context,
                permission
            ) == PackageManager.PERMISSION_GRANTED

        return MONUPermission(
            id = id,
            androidPermission = permission,
            title = title,
            description = description,
            status = if (granted) {
                MONUPermissionStatus.GRANTED
            } else {
                MONUPermissionStatus.DENIED
            }
        )
    }
}
EOF

echo "[5/14] Creating Device Capability Inspector..."

cat > "$BASE/feature/capabilities/MONUDeviceCapabilityInspector.kt" <<'EOF'
package com.monu.mobile.feature.capabilities

import android.content.Context
import android.content.pm.PackageManager
import android.hardware.camera2.CameraManager
import com.monu.mobile.domain.model.MONUCapabilityStatus
import com.monu.mobile.domain.model.MONUDeviceCapability

class MONUDeviceCapabilityInspector(
    private val context: Context
) {

    fun inspect(): List<MONUDeviceCapability> {

        val packageManager = context.packageManager

        val hasCamera =
            packageManager.hasSystemFeature(
                PackageManager.FEATURE_CAMERA_ANY
            )

        val hasMicrophone =
            packageManager.hasSystemFeature(
                PackageManager.FEATURE_MICROPHONE
            )

        val cameraCount = try {
            val manager =
                context.getSystemService(Context.CAMERA_SERVICE)
                    as CameraManager
            manager.cameraIdList.size
        } catch (_: Exception) {
            0
        }

        return listOf(
            MONUDeviceCapability(
                id = "camera",
                title = "Camera Hardware",
                description = "Detected cameras: $cameraCount",
                status = if (hasCamera)
                    MONUCapabilityStatus.AVAILABLE
                else
                    MONUCapabilityStatus.UNAVAILABLE,
                verified = true
            ),
            MONUDeviceCapability(
                id = "microphone",
                title = "Microphone Hardware",
                description = "Device microphone hardware availability.",
                status = if (hasMicrophone)
                    MONUCapabilityStatus.AVAILABLE
                else
                    MONUCapabilityStatus.UNAVAILABLE,
                verified = true
            ),
            MONUDeviceCapability(
                id = "storage",
                title = "Application Storage",
                description = "Application sandbox storage is available.",
                status = MONUCapabilityStatus.AVAILABLE,
                verified = true
            ),
            MONUDeviceCapability(
                id = "root",
                title = "Root Authority",
                description = "Normal APK does not assume root authority.",
                status = MONUCapabilityStatus.UNKNOWN,
                verified = false
            )
        )
    }
}
EOF

echo "[6/14] Creating Permission Control Center screen..."

cat > "$BASE/ui/screens/PermissionControlScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import android.content.Context
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
import com.monu.mobile.feature.permissions.MONUPermissionCenter

@Composable
fun PermissionControlScreen() {

    val context: Context = LocalContext.current
    val permissions = MONUPermissionCenter(context).inspect()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("MONU Permission Control Center")

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(permissions) { permission ->
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(permission.title)
                        Text(permission.description)
                        Text("Permission: ${permission.androidPermission}")
                        Text("Status: ${permission.status}")
                    }
                }
            }
        }
    }
}
EOF

echo "[7/14] Creating Device Capability Inspector screen..."

cat > "$BASE/ui/screens/DeviceCapabilityScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import android.content.Context
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
import com.monu.mobile.feature.capabilities.MONUDeviceCapabilityInspector

@Composable
fun DeviceCapabilityScreen() {

    val context: Context = LocalContext.current
    val capabilities =
        MONUDeviceCapabilityInspector(context).inspect()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("MONU Device Capability Inspector")

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(capabilities) { capability ->
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(capability.title)
                        Text(capability.description)
                        Text("Status: ${capability.status}")
                        Text("Verified: ${capability.verified}")
                    }
                }
            }
        }
    }
}
EOF

echo "[8/14] Adding navigation destinations..."

python - <<'PY'
from pathlib import Path

p = Path(
    "app/src/main/java/com/monu/mobile/ui/navigation/MONUDestination.kt"
)

s = p.read_text()

if "PERMISSION_CONTROL" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    PERMISSION_CONTROL,
    DEVICE_CAPABILITIES,"""
    )

p.write_text(s)
PY

echo "[9/14] Creating permission architecture documentation..."

cat > docs/PERMISSION_ARCHITECTURE.md <<'EOF'
# MONU PERMISSION CONTROL ARCHITECTURE

MONU separates four different states:

DECLARED
↓
REQUESTED
↓
GRANTED / DENIED
↓
ACTUALLY USABLE

A permission declaration does not mean permission granted.

A granted permission does not automatically mean that a
hardware or system capability is functioning.

Truth Rule:

MONU must inspect actual permission state.

Future Permission Control Center may include:

- Permission explanations
- Request controls
- Denied capability warnings
- User action guidance
- Capability dependency mapping
EOF

echo "[10/14] Creating device capability documentation..."

cat > docs/DEVICE_CAPABILITY_ARCHITECTURE.md <<'EOF'
# MONU DEVICE CAPABILITY INSPECTOR

MONU can inspect legitimately available device features.

Possible capability areas:

- Camera hardware
- Microphone hardware
- Application storage
- Network transport
- Notification capability
- Media selection APIs
- Text-to-Speech
- Bluetooth where permission allows
- Location where permission allows

Capability states:

AVAILABLE
UNAVAILABLE
REQUIRES_PERMISSION
REQUIRES_USER_ACTION
UNKNOWN

Truth Rule:

Hardware presence
!=
Permission granted
!=
Capability verified

Root authority is never assumed.

Kernel authority is never assumed.

Other application private data access is never assumed.
EOF

echo "[11/14] Updating project validation..."

python - <<'PY'
from pathlib import Path

p = Path("scripts/validate_project.sh")
s = p.read_text()

new_files = [
    "app/src/main/java/com/monu/mobile/ui/screens/PermissionControlScreen.kt",
    "app/src/main/java/com/monu/mobile/ui/screens/DeviceCapabilityScreen.kt",
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

## Level 22
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Permission domain models
- Permission status inspection
- Permission Control Center
- Runtime permission architecture
- Permission truth separation

Truth Rule:
Declared does not mean granted.
Granted does not automatically mean verified usable.

## Level 23
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Device capability models
- Camera hardware inspection
- Microphone hardware inspection
- Application storage capability
- Device Capability Inspector
- Capability verification architecture

Truth Rule:
UNKNOWN is preferred over invented device authority.

Security Boundary:
A normal APK does not assume root, kernel, or private
cross-application database authority.
EOF

echo "[13/14] Running structural validation..."

./scripts/validate_project.sh

echo "[14/14] Checking Level 22 + 23 files..."

find \
    "$BASE/domain/model" \
    "$BASE/feature/permissions" \
    "$BASE/feature/capabilities" \
    "$BASE/ui/screens" \
    -type f | sort

echo ""
echo "================================================"
echo " LEVEL 22 + LEVEL 23 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW CAPABILITIES:"
echo "✓ Permission Control Architecture"
echo "✓ Real Runtime Permission Inspection"
echo "✓ Permission Status Separation"
echo "✓ Permission Control Center"
echo ""
echo "✓ Device Capability Inspector"
echo "✓ Camera Hardware Detection"
echo "✓ Microphone Hardware Detection"
echo "✓ Application Storage Capability"
echo "✓ Verified / Unknown Capability States"
echo ""
echo "TRUTH RULE:"
echo "Permission and hardware authority are never assumed."
echo ""
echo "IMPORTANT:"
echo "Source creation and structural validation only."
echo "Real Android compilation is still pending."
echo ""
echo "NEXT BUILD LEVEL:"
echo "Level 24 + 25 -> Settings Command Center + Backup / Restore Architecture"
