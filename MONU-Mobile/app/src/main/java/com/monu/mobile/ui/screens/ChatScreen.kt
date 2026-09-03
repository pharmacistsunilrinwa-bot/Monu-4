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
