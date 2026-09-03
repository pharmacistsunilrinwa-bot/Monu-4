#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 4 + LEVEL 5"
echo " REAL VOICE + MULTIMODAL FILE INPUT"
echo "================================================"

if [ ! -f "settings.gradle.kts" ]; then
    echo "ERROR: Run inside ~/projects/MONU-Mobile"
    exit 1
fi

echo "[1/9] Adding Android dependencies..."

python - <<'PY'
from pathlib import Path

p = Path("app/build.gradle.kts")
s = p.read_text()

needle = 'implementation("androidx.navigation:navigation-compose:2.8.5")'

addition = '''implementation("androidx.navigation:navigation-compose:2.8.5")
    implementation("androidx.activity:activity-ktx:1.9.3")'''

if 'androidx.activity:activity-ktx:1.9.3' not in s:
    s = s.replace(needle, addition)

p.write_text(s)
PY

echo "[2/9] Creating Voice Engine..."

mkdir -p app/src/main/java/com/monu/mobile/feature/voice

cat > app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceEngine.kt <<'EOF'
package com.monu.mobile.feature.voice

import android.content.Context
import android.speech.tts.TextToSpeech
import java.util.Locale

class MONUVoiceEngine(
    context: Context,
    private val onReady: (Boolean) -> Unit = {}
) : TextToSpeech.OnInitListener {

    private val textToSpeech = TextToSpeech(context.applicationContext, this)

    private var initialized = false

    override fun onInit(status: Int) {
        initialized = status == TextToSpeech.SUCCESS

        if (initialized) {
            textToSpeech.language = Locale.getDefault()
            textToSpeech.setSpeechRate(1.0f)
            textToSpeech.setPitch(1.0f)
        }

        onReady(initialized)
    }

    fun speak(
        text: String,
        speechRate: Float = 1.0f,
        pitch: Float = 1.0f
    ) {
        if (!initialized || text.isBlank()) return

        textToSpeech.setSpeechRate(speechRate)
        textToSpeech.setPitch(pitch)

        textToSpeech.speak(
            text,
            TextToSpeech.QUEUE_FLUSH,
            null,
            "MONU_MESSAGE"
        )
    }

    fun stop() {
        if (initialized) {
            textToSpeech.stop()
        }
    }

    fun shutdown() {
        textToSpeech.stop()
        textToSpeech.shutdown()
    }
}
EOF

echo "[3/9] Creating attachment models..."

cat > app/src/main/java/com/monu/mobile/domain/model/AttachmentModels.kt <<'EOF'
package com.monu.mobile.domain.model

enum class AttachmentType {
    IMAGE,
    VIDEO,
    PDF,
    DOCUMENT,
    UNKNOWN
}

data class MONUAttachment(
    val uri: String,
    val name: String,
    val type: AttachmentType,
    val mimeType: String? = null,
    val sizeBytes: Long? = null
)
EOF

echo "[4/9] Creating real Android attachment picker..."

mkdir -p app/src/main/java/com/monu/mobile/ui/components

cat > app/src/main/java/com/monu/mobile/ui/components/AttachmentPicker.kt <<'EOF'
package com.monu.mobile.ui.components

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.monu.mobile.domain.model.AttachmentType
import com.monu.mobile.domain.model.MONUAttachment

@Composable
fun AttachmentPicker(
    onAttachmentSelected: (MONUAttachment) -> Unit
) {
    val launcher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocument()
    ) { uri ->
        if (uri != null) {
            onAttachmentSelected(
                buildAttachment(uri)
            )
        }
    }

    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        OutlinedButton(
            onClick = {
                launcher.launch(
                    arrayOf("image/*")
                )
            }
        ) {
            Text("📷")
        }

        OutlinedButton(
            onClick = {
                launcher.launch(
                    arrayOf("video/*")
                )
            }
        ) {
            Text("🎬")
        }

        OutlinedButton(
            onClick = {
                launcher.launch(
                    arrayOf("application/pdf")
                )
            }
        ) {
            Text("PDF")
        }

        OutlinedButton(
            onClick = {
                launcher.launch(
                    arrayOf("*/*")
                )
            }
        ) {
            Text("📎")
        }
    }
}

private fun buildAttachment(
    uri: Uri
): MONUAttachment {

    val mime = uri.toString()

    val type = when {
        mime.contains("image", ignoreCase = true) ->
            AttachmentType.IMAGE

        mime.contains("video", ignoreCase = true) ->
            AttachmentType.VIDEO

        mime.contains("pdf", ignoreCase = true) ->
            AttachmentType.PDF

        else ->
            AttachmentType.DOCUMENT
    }

    return MONUAttachment(
        uri = uri.toString(),
        name = uri.lastPathSegment ?: "Selected file",
        type = type,
        mimeType = null
    )
}
EOF

echo "[5/9] Rebuilding Command Input with attachments..."

cat > app/src/main/java/com/monu/mobile/ui/components/CommandInput.kt <<'EOF'
package com.monu.mobile.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.monu.mobile.domain.model.MONUAttachment

@Composable
fun CommandInput(
    placeholder: String = "Tell MONU what to do...",
    onSend: (String, List<MONUAttachment>) -> Unit
) {
    var text by remember { mutableStateOf("") }
    var attachments by remember {
        mutableStateOf<List<MONUAttachment>>(emptyList())
    }

    Column(
        modifier = Modifier.fillMaxWidth()
    ) {

        if (attachments.isNotEmpty()) {
            Text(
                modifier = Modifier.padding(horizontal = 12.dp),
                text = "Attached: ${attachments.joinToString { it.name }}"
            )
        }

        AttachmentPicker { attachment ->
            attachments = attachments + attachment
        }

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
                maxLines = 4
            )

            Button(
                modifier = Modifier.height(56.dp),
                enabled = text.isNotBlank() || attachments.isNotEmpty(),
                onClick = {
                    onSend(
                        text.trim(),
                        attachments
                    )

                    text = ""
                    attachments = emptyList()
                }
            ) {
                Text("➤")
            }
        }
    }
}
EOF

echo "[6/9] Rebuilding Chat Screen with real voice engine..."

cat > app/src/main/java/com/monu/mobile/ui/screens/ChatScreen.kt <<'EOF'
package com.monu.mobile.ui.screens

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
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
import com.monu.mobile.domain.model.MONUAttachment
import com.monu.mobile.feature.voice.MONUVoiceEngine
import com.monu.mobile.ui.components.CommandInput
import java.util.UUID

@Composable
fun ChatScreen() {
    val context = LocalContext.current

    var voiceReady by remember {
        mutableStateOf(false)
    }

    val voiceEngine = remember {
        MONUVoiceEngine(context) {
            voiceReady = it
        }
    }

    DisposableEffect(Unit) {
        onDispose {
            voiceEngine.shutdown()
        }
    }

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

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "COMMAND CENTER",
                style = MaterialTheme.typography.headlineSmall
            )

            Text(
                text = if (voiceReady) "VOICE READY" else "VOICE INITIALIZING",
                style = MaterialTheme.typography.labelSmall
            )
        }

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
                    },
                    onListen = {
                        voiceEngine.speak(message.content)
                    },
                    onStop = {
                        voiceEngine.stop()
                    },
                    onShare = {
                        shareText(context, message.content)
                    }
                )
            }
        }

        CommandInput { command, attachments ->

            val attachmentText =
                if (attachments.isEmpty()) {
                    ""
                } else {
                    "\nAttachments selected: ${
                        attachments.joinToString { it.name }
                    }"
                }

            val ownerMessage = ChatMessage(
                id = UUID.randomUUID().toString(),
                conversationId = "default",
                content = command + attachmentText,
                role = MessageRole.OWNER
            )

            val systemMessage = ChatMessage(
                id = UUID.randomUUID().toString(),
                conversationId = "default",
                content = "Command stored locally. Attachments selected locally. Server upload is not configured yet.",
                role = MessageRole.SYSTEM
            )

            messages =
                messages + ownerMessage + systemMessage
        }
    }
}

@Composable
fun MessageCard(
    message: ChatMessage,
    onCopy: () -> Unit,
    onListen: () -> Unit,
    onStop: () -> Unit,
    onShare: () -> Unit
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
                horizontalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                OutlinedButton(onClick = onCopy) {
                    Text("Copy")
                }

                OutlinedButton(onClick = onListen) {
                    Text("Listen")
                }

                OutlinedButton(onClick = onStop) {
                    Text("Stop")
                }

                OutlinedButton(onClick = onShare) {
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
        context.getSystemService(Context.CLIPBOARD_SERVICE)
                as ClipboardManager

    clipboard.setPrimaryClip(
        ClipData.newPlainText(
            "MONU Message",
            text
        )
    )
}

private fun shareText(
    context: Context,
    text: String
) {
    val intent = Intent(Intent.ACTION_SEND).apply {
        type = "text/plain"
        putExtra(Intent.EXTRA_TEXT, text)
    }

    context.startActivity(
        Intent.createChooser(
            intent,
            "Share MONU Message"
        )
    )
}
EOF

echo "[7/9] Fixing drawer control and navigation..."

cat > app/src/main/java/com/monu/mobile/ui/MONUApp.kt <<'EOF'
package com.monu.mobile.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import kotlinx.coroutines.launch
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

    val scope = rememberCoroutineScope()

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            MONUSidebar(
                current = currentDestination,
                onNavigate = { destination ->
                    currentDestination = destination
                    scope.launch {
                        drawerState.close()
                    }
                },
                onNewChat = {
                    currentDestination = MONUDestination.CHAT
                    scope.launch {
                        drawerState.close()
                    }
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
                                scope.launch {
                                    drawerState.open()
                                }
                            }
                        ) {
                            Text("☰")
                        }
                    }
                )
            }
        ) {
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

echo "[8/9] Updating documentation..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 4
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Android Text-to-Speech engine
- Individual message speaking
- Stop speaking
- Voice initialization status
- Share intent

## Level 5
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Android OpenDocument picker
- Image selection
- Video selection
- PDF selection
- Generic file selection
- Attachment model

Connection rule:
No server upload is simulated.
EOF

echo "[9/9] Running structural validation..."

./scripts/validate_project.sh

echo ""
echo "================================================"
echo " LEVEL 4 + LEVEL 5 SOURCE CREATED"
echo "================================================"

echo ""
echo "Voice source:"
test -f app/src/main/java/com/monu/mobile/feature/voice/MONUVoiceEngine.kt

echo "Attachment source:"
test -f app/src/main/java/com/monu/mobile/ui/components/AttachmentPicker.kt

echo ""
echo "IMPORTANT:"
echo "Source files are created."
echo "Real compilation is still required."
echo ""
echo "NEXT STAGE:"
echo "Git repository -> GitHub -> GitHub Actions -> Real APK compilation"
