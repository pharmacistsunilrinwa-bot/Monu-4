#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 2 + LEVEL 3"
echo " COMMAND CENTER + CHAT ENGINE"
echo "================================================"

if [ ! -f "settings.gradle.kts" ]; then
    echo "ERROR: Run this inside ~/projects/MONU-Mobile"
    exit 1
fi

echo "[1/10] Creating package structure..."

mkdir -p app/src/main/java/com/monu/mobile/ui/{components,navigation,screens}
mkdir -p app/src/main/java/com/monu/mobile/domain/model
mkdir -p app/src/main/java/com/monu/mobile/feature/chat
mkdir -p app/src/main/java/com/monu/mobile/feature/home

echo "[2/10] Creating navigation model..."

cat > app/src/main/java/com/monu/mobile/ui/navigation/MONUDestination.kt <<'EOF'
package com.monu.mobile.ui.navigation

enum class MONUDestination(
    val title: String,
    val icon: String
) {
    HOME("Home", "⌂"),
    CHAT("Command Center", "◉"),
    TASKS("Tasks", "✓"),
    PROJECTS("Projects", "▣"),
    MEDIA("Media Studio", "◈"),
    FILES("Files", "▤"),
    VOICE("Voice", "◌"),
    SERVER("Server", "◆"),
    SECURITY("Security", "◈"),
    DEVICE("Device", "▣"),
    ACTIVITY("Activity", "≡"),
    SETTINGS("Settings", "⚙")
}
EOF

echo "[3/10] Creating chat data models..."

cat > app/src/main/java/com/monu/mobile/domain/model/ChatModels.kt <<'EOF'
package com.monu.mobile.domain.model

data class ChatConversation(
    val id: String,
    val title: String,
    val messages: List<ChatMessage> = emptyList(),
    val createdAt: Long = System.currentTimeMillis()
)

enum class MessageRole {
    OWNER,
    MONU,
    SYSTEM
}

data class ChatMessage(
    val id: String,
    val conversationId: String,
    val content: String,
    val role: MessageRole,
    val timestamp: Long = System.currentTimeMillis(),
    val audioProgressMs: Long = 0L,
    val isAudioAvailable: Boolean = false
)
EOF

echo "[4/10] Creating sidebar component..."

cat > app/src/main/java/com/monu/mobile/ui/components/MONUSidebar.kt <<'EOF'
package com.monu.mobile.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.monu.mobile.ui.navigation.MONUDestination

@Composable
fun MONUSidebar(
    current: MONUDestination,
    onNavigate: (MONUDestination) -> Unit,
    onNewChat: () -> Unit
) {
    ModalDrawerSheet(
        modifier = Modifier.width(310.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .padding(12.dp)
        ) {

            Text(
                text = "MONU",
                style = MaterialTheme.typography.headlineMedium
            )

            Text(
                text = "Personal Command OS",
                style = MaterialTheme.typography.bodySmall
            )

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                modifier = Modifier.fillMaxWidth(),
                onClick = onNewChat
            ) {
                Text("+ New Command")
            }

            Spacer(modifier = Modifier.height(12.dp))

            HorizontalDivider()

            Spacer(modifier = Modifier.height(8.dp))

            LazyColumn(
                modifier = Modifier.weight(1f)
            ) {
                items(MONUDestination.entries.size) { index ->
                    val destination = MONUDestination.entries[index]

                    NavigationDrawerItem(
                        label = {
                            Text("${destination.icon}  ${destination.title}")
                        },
                        selected = current == destination,
                        onClick = {
                            onNavigate(destination)
                        },
                        modifier = Modifier.padding(vertical = 2.dp)
                    )
                }
            }

            HorizontalDivider()

            Spacer(modifier = Modifier.height(10.dp))

            Text(
                text = "MONU Mobile Command Center",
                style = MaterialTheme.typography.labelSmall
            )
        }
    }
}
EOF

echo "[5/10] Creating universal command input..."

cat > app/src/main/java/com/monu/mobile/ui/components/CommandInput.kt <<'EOF'
package com.monu.mobile.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun CommandInput(
    placeholder: String = "Tell MONU what to do...",
    onSend: (String) -> Unit
) {
    var text by remember { mutableStateOf("") }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(12.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {

        OutlinedTextField(
            modifier = Modifier.weight(1f),
            value = text,
            onValueChange = { text = it },
            placeholder = {
                Text(placeholder)
            },
            singleLine = false,
            maxLines = 4
        )

        Button(
            modifier = Modifier.height(56.dp),
            enabled = text.isNotBlank(),
            onClick = {
                val command = text.trim()
                if (command.isNotEmpty()) {
                    onSend(command)
                    text = ""
                }
            }
        ) {
            Text("➤")
        }
    }
}
EOF

echo "[6/10] Creating Home Command Dashboard..."

cat > app/src/main/java/com/monu/mobile/ui/screens/HomeScreen.kt <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

data class MONUFeatureCard(
    val title: String,
    val description: String,
    val icon: String
)

@Composable
fun HomeScreen(
    onOpenCommand: () -> Unit
) {
    val features = listOf(
        MONUFeatureCard("Command Center", "Text, voice and multimodal commands", "◉"),
        MONUFeatureCard("Server", "Real connection and capability status", "◆"),
        MONUFeatureCard("Tasks", "Monitor long-running operations", "✓"),
        MONUFeatureCard("Projects", "Projects, goals and activity", "▣"),
        MONUFeatureCard("Media Studio", "Image, video and audio operations", "◈"),
        MONUFeatureCard("Files", "Upload, download and file operations", "▤"),
        MONUFeatureCard("Voice", "Voice commands and spoken responses", "◌"),
        MONUFeatureCard("Security", "Permissions and device protection", "◈"),
        MONUFeatureCard("Device Intelligence", "Mobile health and diagnostics", "▣"),
        MONUFeatureCard("Activity", "Live MONU activity feed", "≡")
    )

    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {

        item {
            Text(
                text = "MONU COMMAND CENTER",
                style = MaterialTheme.typography.headlineMedium
            )

            Text(
                text = "Your personal AI operating interface",
                style = MaterialTheme.typography.bodyMedium
            )

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                modifier = Modifier.fillMaxWidth(),
                onClick = onOpenCommand
            ) {
                Text("OPEN UNIVERSAL COMMAND")
            }
        }

        items(features.size) { index ->
            val feature = features[index]

            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable {
                        if (feature.title == "Command Center") {
                            onOpenCommand()
                        }
                    }
            ) {
                Row(
                    modifier = Modifier.padding(18.dp)
                ) {
                    Text(
                        text = feature.icon,
                        style = MaterialTheme.typography.headlineSmall
                    )

                    Spacer(modifier = Modifier.width(14.dp))

                    Column {
                        Text(
                            text = feature.title,
                            style = MaterialTheme.typography.titleMedium
                        )

                        Text(
                            text = feature.description,
                            style = MaterialTheme.typography.bodyMedium
                        )
                    }
                }
            }
        }
    }
}
EOF

echo "[7/10] Creating Chat Command Center..."

cat > app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt <<'EOF'
package com.monu.mobile.ui.screens

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.monu.mobile.domain.model.ChatMessage
import com.monu.mobile.domain.model.MessageRole
import com.monu.mobile.ui.components.CommandInput
import java.util.UUID

@Composable
fun ChatScreen() {
    val context = LocalContext.current

    var messages by remember {
        mutableStateOf(
            listOf(
                ChatMessage(
                    id = UUID.randomUUID().toString(),
                    conversationId = "default",
                    content = "MONU Command Center ready. Server intelligence is not configured yet.",
                    role = MessageRole.SYSTEM
                )
            )
        )
    }

    Column(
        modifier = Modifier.fillMaxSize()
    ) {

        Text(
            modifier = Modifier.padding(16.dp),
            text = "COMMAND CENTER",
            style = MaterialTheme.typography.headlineSmall
        )

        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentPadding = PaddingValues(12.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            items(messages) { message ->
                MessageCard(
                    message = message,
                    onCopy = {
                        copyToClipboard(context, message.content)
                    }
                )
            }
        }

        CommandInput { command ->
            val ownerMessage = ChatMessage(
                id = UUID.randomUUID().toString(),
                conversationId = "default",
                content = command,
                role = MessageRole.OWNER
            )

            val systemMessage = ChatMessage(
                id = UUID.randomUUID().toString(),
                conversationId = "default",
                content = "Command stored locally. No fake server response generated.",
                role = MessageRole.SYSTEM
            )

            messages = messages + ownerMessage + systemMessage
        }
    }
}

@Composable
fun MessageCard(
    message: ChatMessage,
    onCopy: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(14.dp)
        ) {

            val roleName = when (message.role) {
                MessageRole.OWNER -> "YOU"
                MessageRole.MONU -> "MONU"
                MessageRole.SYSTEM -> "SYSTEM"
            }

            Text(
                text = roleName,
                style = MaterialTheme.typography.labelMedium
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = message.content,
                style = MaterialTheme.typography.bodyLarge
            )

            Spacer(modifier = Modifier.height(10.dp))

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedButton(onClick = onCopy) {
                    Text("Copy")
                }

                OutlinedButton(onClick = { }) {
                    Text("Listen")
                }

                OutlinedButton(onClick = { }) {
                    Text("Share")
                }
            }
        }
    }
}

private fun copyToClipboard(
    context: Context,
    text: String
) {
    val clipboard =
        context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager

    clipboard.setPrimaryClip(
        ClipData.newPlainText("MONU Message", text)
    )
}
EOF

echo "[8/10] Creating generic feature screen..."

cat > app/src/main/java/com/monu/mobile/ui/screens/FeatureScreen.kt <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun FeatureScreen(
    title: String,
    description: String
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp)
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.headlineMedium
        )

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = description,
            style = MaterialTheme.typography.bodyLarge
        )

        Spacer(modifier = Modifier.height(24.dp))

        Card(
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                modifier = Modifier.padding(18.dp),
                text = "This module is registered in the MONU architecture and will receive its real operational engine in a dedicated implementation level."
            )
        }
    }
}
EOF

echo "[9/10] Rebuilding MONUApp navigation shell..."

cat > app/src/main/java/com/monu/mobile/ui/MONUApp.kt <<'EOF'
package com.monu.mobile.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import com.monu.mobile.ui.components.MONUSidebar
import com.monu.mobile.ui.navigation.MONUDestination
import com.monu.mobile.ui.screens.ChatScreen
import com.monu.mobile.ui.screens.FeatureScreen
import com.monu.mobile.ui.screens.HomeScreen

@Composable
fun MONUApp() {
    MaterialTheme(
        colorScheme = darkColorScheme(
            primary = Color(0xFF4FC3F7),
            secondary = Color(0xFF80CBC4),
            background = Color(0xFF0B1020),
            surface = Color(0xFF121A2B)
        )
    ) {
        MONURoot()
    }
}

@Composable
private fun MONURoot() {
    var currentDestination by remember {
        mutableStateOf(MONUDestination.HOME)
    }

    val drawerState = rememberDrawerState(
        initialValue = DrawerValue.Closed
    )

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            MONUSidebar(
                current = currentDestination,
                onNavigate = { destination ->
                    currentDestination = destination
                },
                onNewChat = {
                    currentDestination = MONUDestination.CHAT
                }
            )
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Text(
                            text = currentDestination.title
                        )
                    },
                    navigationIcon = {
                        IconButton(
                            onClick = {
                                // Drawer gesture support is available.
                            }
                        ) {
                            Text("☰")
                        }
                    }
                )
            }
        ) { paddingValues ->

            Surface(
                modifier = Modifier.fillMaxSize()
            ) {
                when (currentDestination) {

                    MONUDestination.HOME -> {
                        HomeScreen(
                            onOpenCommand = {
                                currentDestination =
                                    MONUDestination.CHAT
                            }
                        )
                    }

                    MONUDestination.CHAT -> {
                        ChatScreen()
                    }

                    else -> {
                        FeatureScreen(
                            title = currentDestination.title,
                            description =
                                "MONU ${currentDestination.title} module."
                        )
                    }
                }
            }
        }
    }
}
EOF

echo "[10/10] Updating project documentation..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 2
Status: COMPLETE - SOURCE CREATED

Added:
- Desktop-style navigation shell
- Sidebar
- Feature navigation registry
- Unified Home Command Center
- Main feature dashboard

## Level 3
Status: COMPLETE - SOURCE CREATED

Added:
- Chat message models
- Command input
- Local message storage foundation
- Individual Copy controls
- Listen control placeholder
- Share control placeholder

Important:
Server responses are not simulated.
EOF

echo ""
echo "================================================"
echo " LEVEL 2 + LEVEL 3 SOURCE CREATED"
echo "================================================"

echo ""
echo "Running validation..."
./scripts/validate_project.sh

echo ""
echo "Important new source files:"
find app/src/main/java/com/monu/mobile -type f | sort

echo ""
echo "NEXT:"
echo "Commit -> Push -> GitHub Actions -> Real APK Build"
