#!/usr/bin/env bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 12 + LEVEL 13"
echo " PERSONALIZED HOME + NOTIFICATION CENTER"
echo "================================================"

BASE="app/src/main/java/com/monu/mobile"

echo "[1/12] Creating personalization models..."

mkdir -p "$BASE/domain/model"
mkdir -p "$BASE/feature/home"
mkdir -p "$BASE/feature/notification"
mkdir -p "$BASE/ui/screens"
mkdir -p "$BASE/data/preferences"

cat > "$BASE/domain/model/HomeModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class HomeBackgroundMode {
    DEFAULT,
    SOLID_COLOR,
    IMAGE,
    GENERATED_IMAGE
}

data class HomeAppearance(
    val mode: HomeBackgroundMode = HomeBackgroundMode.DEFAULT,
    val backgroundValue: String? = null,
    val title: String = "MONU",
    val subtitle: String = "Your Mobile Command Center"
)

data class HomeQuickAction(
    val id: String,
    val title: String,
    val description: String,
    val destination: String
)
EOF

echo "[2/12] Creating home appearance preferences..."

cat > "$BASE/data/preferences/HomeAppearanceStore.kt" <<'EOF'
package com.monu.mobile.data.preferences

import android.content.Context
import android.content.SharedPreferences
import com.monu.mobile.domain.model.HomeAppearance
import com.monu.mobile.domain.model.HomeBackgroundMode

class HomeAppearanceStore(context: Context) {

    private val preferences: SharedPreferences =
        context.getSharedPreferences(
            "monu_home_appearance",
            Context.MODE_PRIVATE
        )

    fun save(appearance: HomeAppearance) {
        preferences.edit()
            .putString("mode", appearance.mode.name)
            .putString("background", appearance.backgroundValue)
            .putString("title", appearance.title)
            .putString("subtitle", appearance.subtitle)
            .apply()
    }

    fun load(): HomeAppearance {
        val modeName = preferences.getString(
            "mode",
            HomeBackgroundMode.DEFAULT.name
        ) ?: HomeBackgroundMode.DEFAULT.name

        return HomeAppearance(
            mode = runCatching {
                HomeBackgroundMode.valueOf(modeName)
            }.getOrDefault(HomeBackgroundMode.DEFAULT),
            backgroundValue = preferences.getString(
                "background",
                null
            ),
            title = preferences.getString(
                "title",
                "MONU"
            ) ?: "MONU",
            subtitle = preferences.getString(
                "subtitle",
                "Your Mobile Command Center"
            ) ?: "Your Mobile Command Center"
        )
    }
}
EOF

echo "[3/12] Creating home personalization engine..."

cat > "$BASE/feature/home/MONUHomePersonalization.kt" <<'EOF'
package com.monu.mobile.feature.home

import com.monu.mobile.domain.model.HomeAppearance
import com.monu.mobile.domain.model.HomeBackgroundMode

class MONUHomePersonalization {

    fun defaultAppearance(): HomeAppearance {
        return HomeAppearance(
            mode = HomeBackgroundMode.DEFAULT,
            title = "MONU",
            subtitle = "Your Mobile Command Center"
        )
    }

    fun imageAppearance(
        imageUri: String
    ): HomeAppearance {
        return HomeAppearance(
            mode = HomeBackgroundMode.IMAGE,
            backgroundValue = imageUri,
            title = "MONU",
            subtitle = "Personalized Command Center"
        )
    }

    fun generatedImageAppearance(
        imageReference: String
    ): HomeAppearance {
        return HomeAppearance(
            mode = HomeBackgroundMode.GENERATED_IMAGE,
            backgroundValue = imageReference,
            title = "MONU",
            subtitle = "AI Personalized Environment"
        )
    }
}
EOF

echo "[4/12] Creating notification models..."

cat > "$BASE/domain/model/MONUNotificationModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUNotificationSource {
    MOBILE,
    SERVER,
    HEARTBEAT,
    TASK,
    SYSTEM,
    SECURITY,
    APPROVAL
}

enum class MONUNotificationPriority {
    LOW,
    NORMAL,
    HIGH,
    CRITICAL
}

data class MONUNotification(
    val id: String,
    val source: MONUNotificationSource,
    val priority: MONUNotificationPriority,
    val title: String,
    val message: String,
    val timestamp: Long = System.currentTimeMillis(),
    val read: Boolean = false
)
EOF

echo "[5/12] Creating notification repository..."

cat > "$BASE/feature/notification/MONUNotificationCenter.kt" <<'EOF'
package com.monu.mobile.feature.notification

import com.monu.mobile.domain.model.MONUNotification
import com.monu.mobile.domain.model.MONUNotificationPriority
import com.monu.mobile.domain.model.MONUNotificationSource
import java.util.UUID

class MONUNotificationCenter {

    private val notifications = mutableListOf<MONUNotification>()

    fun add(
        source: MONUNotificationSource,
        priority: MONUNotificationPriority,
        title: String,
        message: String
    ): MONUNotification {

        val notification = MONUNotification(
            id = UUID.randomUUID().toString(),
            source = source,
            priority = priority,
            title = title,
            message = message
        )

        notifications.add(0, notification)

        return notification
    }

    fun all(): List<MONUNotification> {
        return notifications.toList()
    }

    fun unreadCount(): Int {
        return notifications.count { !it.read }
    }

    fun bySource(
        source: MONUNotificationSource
    ): List<MONUNotification> {
        return notifications.filter {
            it.source == source
        }
    }
}
EOF

echo "[6/12] Creating notification center screen..."

cat > "$BASE/ui/screens/NotificationCenterScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.monu.mobile.domain.model.MONUNotification
import com.monu.mobile.domain.model.MONUNotificationPriority
import com.monu.mobile.domain.model.MONUNotificationSource

@Composable
fun NotificationCenterScreen() {

    val demoNotifications = listOf(
        MONUNotification(
            id = "server",
            source = MONUNotificationSource.SERVER,
            priority = MONUNotificationPriority.NORMAL,
            title = "Server Notifications",
            message = "Real server notifications will appear here."
        ),
        MONUNotification(
            id = "heartbeat",
            source = MONUNotificationSource.HEARTBEAT,
            priority = MONUNotificationPriority.NORMAL,
            title = "Heartbeat Updates",
            message = "Real heartbeat results will appear here."
        ),
        MONUNotification(
            id = "mobile",
            source = MONUNotificationSource.MOBILE,
            priority = MONUNotificationPriority.NORMAL,
            title = "Mobile Notifications",
            message = "MONU mobile system events will appear here."
        ),
        MONUNotification(
            id = "task",
            source = MONUNotificationSource.TASK,
            priority = MONUNotificationPriority.HIGH,
            title = "Task Updates",
            message = "Real task progress and completion events will appear here."
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Notification Center")

        LazyColumn(
            contentPadding = PaddingValues(top = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(demoNotifications) { notification ->
                NotificationCard(notification)
            }
        }
    }
}

@Composable
private fun NotificationCard(
    notification: MONUNotification
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(notification.title)
            Text(notification.message)
            Text("Source: ${notification.source}")
            Text("Priority: ${notification.priority}")
        }
    }
}
EOF

echo "[7/12] Creating home customization screen..."

cat > "$BASE/ui/screens/HomeCustomizationScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun HomeCustomizationScreen() {

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Home Personalization")

        Text(
            "Future personalization options:"
        )

        Text("• Default MONU theme")
        Text("• Custom colors")
        Text("• Personal photo background")
        Text("• Generated AI background")
        Text("• Mood-based appearance")
        Text("• Server-generated visual themes")
        Text("• Dynamic home cards")

        Button(
            onClick = { }
        ) {
            Text("Background Configuration")
        }
    }
}
EOF

echo "[8/12] Adding navigation destinations..."

NAV="$BASE/ui/navigation/MONUDestination.kt"

if [ -f "$NAV" ]; then

python - <<'PY'
from pathlib import Path

p = Path("app/src/main/java/com/monu/mobile/ui/navigation/MONUDestination.kt")
s = p.read_text()

if "HOME_CUSTOMIZATION" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    HOME_CUSTOMIZATION,
    NOTIFICATIONS,"""
    )

p.write_text(s)
PY

else
    echo "ERROR: Navigation file missing."
    exit 1
fi

echo "[9/12] Creating personalization documentation..."

cat > docs/HOME_PERSONALIZATION.md <<'EOF'
# MONU HOME PERSONALIZATION

The MONU homepage is designed to become dynamically customizable.

Possible appearance sources:

1. Default application theme
2. User selected colors
3. User selected local image
4. AI generated image
5. Server generated visual
6. Mood based appearance
7. Time based appearance

Architecture Rule:

The homepage visual system is configurable.

Future server integration may allow commands such as:

"MONU, make my home screen look futuristic."

or:

"MONU, generate a peaceful desert background."

The generated result can later be stored as the active
home background reference.
EOF

echo "[10/12] Creating notification architecture documentation..."

cat > docs/NOTIFICATION_ARCHITECTURE.md <<'EOF'
# MONU NOTIFICATION ARCHITECTURE

Notification sources are intentionally separated.

## MOBILE

Events generated by the APK itself.

Examples:

- Permission changes
- Upload state
- Download state
- Local errors

## SERVER

Events received from MONU Server.

Examples:

- Server report
- Research complete
- System warning
- Command result

## HEARTBEAT

Connection monitoring events.

Examples:

- Server reachable
- Server unreachable
- Connection restored

## TASK

Long-running job updates.

Examples:

- Started
- Progress
- Completed
- Failed

## SECURITY

Security related events.

## APPROVAL

Actions requiring owner approval.

Truth Rule:

A notification claiming a server event must originate
from a real server event when integration is implemented.
EOF

echo "[11/12] Updating project status..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 12
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Dynamic home appearance architecture
- Persistent home preferences
- Background modes
- Image background model
- Generated image background model
- Home personalization engine
- Customization screen

Future direction:
The owner may select a personal image or request MONU
to generate a visual background.

## Level 13
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Notification domain models
- Notification source separation
- Priority architecture
- MONU notification center
- Server notification category
- Heartbeat notification category
- Mobile notification category
- Task notification category
- Security notification category
- Approval notification category

Truth Rule:
Real server notifications must come from real server events.
EOF

echo "[12/12] Running structural validation..."

./scripts/validate_project.sh

echo ""
echo "================================================"
echo " LEVEL 12 + LEVEL 13 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW CAPABILITIES:"
echo "✓ Personalized Home Architecture"
echo "✓ Custom Image Background Model"
echo "✓ AI Generated Background Model"
echo "✓ Mood-Based Future Architecture"
echo "✓ Notification Center"
echo "✓ Separate Server Notifications"
echo "✓ Separate Heartbeat Notifications"
echo "✓ Separate Mobile Notifications"
echo "✓ Separate Task Notifications"
echo "✓ Security Notification Architecture"
echo ""
echo "IMPORTANT:"
echo "Source creation completed."
echo "Real Android compilation is still pending."
echo ""
echo "NEXT BUILD LEVEL:"
echo "Level 14 + 15 -> Task Center + Project Command Center"
