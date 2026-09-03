#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 10 + LEVEL 11"
echo " SERVER CONTRACT + REALTIME WEBSOCKET FOUNDATION"
echo "================================================"

if [ ! -f "settings.gradle.kts" ]; then
    echo "ERROR: Run inside ~/projects/MONU-Mobile"
    exit 1
fi

echo "[1/11] Creating server contract models..."

mkdir -p app/src/main/java/com/monu/mobile/domain/model
mkdir -p app/src/main/java/com/monu/mobile/feature/realtime
mkdir -p app/src/main/java/com/monu/mobile/ui/screens

cat > app/src/main/java/com/monu/mobile/domain/model/ServerContractModels.kt <<'EOF'
package com.monu.mobile.domain.model

data class ServerEndpointConfig(
    val baseUrl: String = "",
    val healthPath: String = "/health",
    val capabilitiesPath: String = "/capabilities",
    val commandPath: String = "",
    val chatPath: String = "",
    val websocketUrl: String = ""
)

enum class WebSocketState {
    NOT_CONFIGURED,
    CONNECTING,
    CONNECTED,
    DISCONNECTED,
    FAILED
}

data class WebSocketStatus(
    val state: WebSocketState,
    val message: String,
    val lastEventAt: Long? = null
)
EOF

echo "[2/11] Creating persistent server configuration store..."

mkdir -p app/src/main/java/com/monu/mobile/data/config

cat > app/src/main/java/com/monu/mobile/data/config/ServerConfigStore.kt <<'EOF'
package com.monu.mobile.data.config

import android.content.Context
import com.monu.mobile.domain.model.ServerEndpointConfig

class ServerConfigStore(
    context: Context
) {

    private val preferences =
        context.getSharedPreferences(
            "monu_server_config",
            Context.MODE_PRIVATE
        )

    fun save(
        config: ServerEndpointConfig
    ) {
        preferences.edit()
            .putString("baseUrl", config.baseUrl)
            .putString("healthPath", config.healthPath)
            .putString("capabilitiesPath", config.capabilitiesPath)
            .putString("commandPath", config.commandPath)
            .putString("chatPath", config.chatPath)
            .putString("websocketUrl", config.websocketUrl)
            .apply()
    }

    fun load(): ServerEndpointConfig {
        return ServerEndpointConfig(
            baseUrl =
                preferences.getString(
                    "baseUrl",
                    ""
                ) ?: "",

            healthPath =
                preferences.getString(
                    "healthPath",
                    "/health"
                ) ?: "/health",

            capabilitiesPath =
                preferences.getString(
                    "capabilitiesPath",
                    "/capabilities"
                ) ?: "/capabilities",

            commandPath =
                preferences.getString(
                    "commandPath",
                    ""
                ) ?: "",

            chatPath =
                preferences.getString(
                    "chatPath",
                    ""
                ) ?: "",

            websocketUrl =
                preferences.getString(
                    "websocketUrl",
                    ""
                ) ?: ""
        )
    }
}
EOF

echo "[3/11] Creating WebSocket engine..."

cat > app/src/main/java/com/monu/mobile/feature/realtime/MONUWebSocketEngine.kt <<'EOF'
package com.monu.mobile.feature.realtime

import com.monu.mobile.domain.model.WebSocketState
import com.monu.mobile.domain.model.WebSocketStatus
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import okhttp3.*

class MONUWebSocketEngine {

    private val client =
        OkHttpClient()

    private var socket:
        WebSocket? = null

    private val _status =
        MutableStateFlow(
            WebSocketStatus(
                state =
                    WebSocketState.NOT_CONFIGURED,
                message =
                    "WebSocket URL not configured"
            )
        )

    val status:
        StateFlow<WebSocketStatus> =
            _status.asStateFlow()

    fun connect(
        websocketUrl: String
    ) {

        if (websocketUrl.isBlank()) {

            _status.value =
                WebSocketStatus(
                    state =
                        WebSocketState.NOT_CONFIGURED,
                    message =
                        "WebSocket URL not configured"
                )

            return
        }

        disconnect()

        _status.value =
            WebSocketStatus(
                state =
                    WebSocketState.CONNECTING,
                message =
                    "Connecting..."
            )

        val request =
            Request.Builder()
                .url(websocketUrl)
                .build()

        socket =
            client.newWebSocket(
                request,
                object : WebSocketListener() {

                    override fun onOpen(
                        webSocket: WebSocket,
                        response: Response
                    ) {

                        _status.value =
                            WebSocketStatus(
                                state =
                                    WebSocketState.CONNECTED,
                                message =
                                    "Real WebSocket connected",
                                lastEventAt =
                                    System.currentTimeMillis()
                            )
                    }

                    override fun onMessage(
                        webSocket: WebSocket,
                        text: String
                    ) {

                        _status.value =
                            WebSocketStatus(
                                state =
                                    WebSocketState.CONNECTED,
                                message =
                                    "Event received",
                                lastEventAt =
                                    System.currentTimeMillis()
                            )
                    }

                    override fun onClosing(
                        webSocket: WebSocket,
                        code: Int,
                        reason: String
                    ) {

                        _status.value =
                            WebSocketStatus(
                                state =
                                    WebSocketState.DISCONNECTED,
                                message =
                                    "Server closing: $reason"
                            )
                    }

                    override fun onClosed(
                        webSocket: WebSocket,
                        code: Int,
                        reason: String
                    ) {

                        _status.value =
                            WebSocketStatus(
                                state =
                                    WebSocketState.DISCONNECTED,
                                message =
                                    "WebSocket closed: $reason"
                            )
                    }

                    override fun onFailure(
                        webSocket: WebSocket,
                        throwable: Throwable,
                        response: Response?
                    ) {

                        _status.value =
                            WebSocketStatus(
                                state =
                                    WebSocketState.FAILED,
                                message =
                                    throwable.message
                                        ?: "WebSocket connection failed"
                            )
                    }
                }
            )
    }

    fun send(
        message: String
    ): Boolean {

        return socket?.send(
            message
        ) ?: false
    }

    fun disconnect() {

        socket?.close(
            1000,
            "MONU client disconnect"
        )

        socket = null

        _status.value =
            WebSocketStatus(
                state =
                    WebSocketState.DISCONNECTED,
                message =
                    "WebSocket disconnected"
            )
    }
}
EOF

echo "[4/11] Creating realtime event models..."

cat > app/src/main/java/com/monu/mobile/domain/model/RealtimeEvent.kt <<'EOF'
package com.monu.mobile.domain.model

data class RealtimeEvent(
    val type: String,
    val payload: String,
    val receivedAt: Long =
        System.currentTimeMillis()
)
EOF

echo "[5/11] Creating server configuration screen..."

cat > app/src/main/java/com/monu/mobile/ui/screens/ServerContractScreen.kt <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.monu.mobile.data.config.ServerConfigStore
import com.monu.mobile.domain.model.ServerEndpointConfig

@Composable
fun ServerContractScreen() {

    val context =
        LocalContext.current

    val store =
        remember {
            ServerConfigStore(context)
        }

    var config by remember {
        mutableStateOf(
            store.load()
        )
    }

    var message by remember {
        mutableStateOf(
            "Load your REAL MONU Server contract here."
        )
    }

    Column(
        modifier =
            Modifier
                .fillMaxSize()
                .padding(16.dp),
        verticalArrangement =
            Arrangement.spacedBy(10.dp)
    ) {

        Text(
            "SERVER API CONTRACT",
            style =
                MaterialTheme.typography
                    .headlineSmall
        )

        Text(
            "These values must match the real MONU Server. Nothing is simulated."
        )

        OutlinedTextField(
            modifier =
                Modifier.fillMaxWidth(),
            value = config.baseUrl,
            onValueChange = {
                config =
                    config.copy(
                        baseUrl = it
                    )
            },
            label = {
                Text("Server Base URL")
            },
            placeholder = {
                Text("http://192.168.x.x:8000")
            }
        )

        OutlinedTextField(
            modifier =
                Modifier.fillMaxWidth(),
            value = config.healthPath,
            onValueChange = {
                config =
                    config.copy(
                        healthPath = it
                    )
            },
            label = {
                Text("Health endpoint")
            }
        )

        OutlinedTextField(
            modifier =
                Modifier.fillMaxWidth(),
            value = config.capabilitiesPath,
            onValueChange = {
                config =
                    config.copy(
                        capabilitiesPath = it
                    )
            },
            label = {
                Text("Capabilities endpoint")
            }
        )

        OutlinedTextField(
            modifier =
                Modifier.fillMaxWidth(),
            value = config.commandPath,
            onValueChange = {
                config =
                    config.copy(
                        commandPath = it
                    )
            },
            label = {
                Text("Command endpoint")
            }
        )

        OutlinedTextField(
            modifier =
                Modifier.fillMaxWidth(),
            value = config.chatPath,
            onValueChange = {
                config =
                    config.copy(
                        chatPath = it
                    )
            },
            label = {
                Text("Chat endpoint")
            }
        )

        OutlinedTextField(
            modifier =
                Modifier.fillMaxWidth(),
            value = config.websocketUrl,
            onValueChange = {
                config =
                    config.copy(
                        websocketUrl = it
                    )
            },
            label = {
                Text("WebSocket URL")
            },
            placeholder = {
                Text("ws://server/ws")
            }
        )

        Button(
            modifier =
                Modifier.fillMaxWidth(),
            onClick = {
                store.save(config)

                message =
                    "Configuration saved locally. Endpoints are not verified until real connection testing."
            }
        ) {
            Text(
                "SAVE REAL SERVER CONFIGURATION"
            )
        }

        Card(
            modifier =
                Modifier.fillMaxWidth()
        ) {
            Text(
                modifier =
                    Modifier.padding(12.dp),
                text = message
            )
        }
    }
}
EOF

echo "[6/11] Creating WebSocket monitor screen..."

cat > app/src/main/java/com/monu/mobile/ui/screens/RealtimeScreen.kt <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.monu.mobile.data.config.ServerConfigStore
import com.monu.mobile.domain.model.WebSocketState
import com.monu.mobile.feature.realtime.MONUWebSocketEngine

@Composable
fun RealtimeScreen() {

    val context =
        LocalContext.current

    val store =
        remember {
            ServerConfigStore(context)
        }

    val engine =
        remember {
            MONUWebSocketEngine()
        }

    val status by
        engine.status.collectAsState()

    val websocketUrl =
        remember {
            store.load().websocketUrl
        }

    Column(
        modifier =
            Modifier
                .fillMaxSize()
                .padding(20.dp),
        verticalArrangement =
            Arrangement.spacedBy(16.dp)
    ) {

        Text(
            "REAL-TIME CONNECTION",
            style =
                MaterialTheme.typography
                    .headlineSmall
        )

        Card(
            modifier =
                Modifier.fillMaxWidth()
        ) {

            Column(
                modifier =
                    Modifier.padding(16.dp)
            ) {

                Text(
                    "State: ${status.state}"
                )

                Text(
                    "Status: ${status.message}"
                )

                Text(
                    "WebSocket URL: " +
                        if (
                            websocketUrl.isBlank()
                        ) {
                            "NOT CONFIGURED"
                        } else {
                            websocketUrl
                        }
                )
            }
        }

        Button(
            modifier =
                Modifier.fillMaxWidth(),
            enabled =
                websocketUrl.isNotBlank() &&
                    status.state !=
                    WebSocketState.CONNECTING,
            onClick = {
                engine.connect(
                    websocketUrl
                )
            }
        ) {
            Text("CONNECT REAL WEBSOCKET")
        }

        OutlinedButton(
            modifier =
                Modifier.fillMaxWidth(),
            onClick = {
                engine.disconnect()
            }
        ) {
            Text("DISCONNECT")
        }

        Text(
            "Truth Rule: CONNECTED appears only after WebSocket onOpen()."
        )
    }
}
EOF

echo "[7/11] Updating navigation model..."

python - <<'PY'
from pathlib import Path

p = Path(
    "app/src/main/java/com/monu/mobile/ui/navigation/MONUDestination.kt"
)

s = p.read_text()

if "SERVER_CONTRACT" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    SERVER_CONTRACT,
    REALTIME,"""
    )

p.write_text(s)
PY

echo "[8/11] Checking MONUApp navigation source..."

APP="app/src/main/java/com/monu/mobile/ui/MONUApp.kt"

if [ -f "$APP" ]; then
    echo "MONUApp found."
    echo "Manual compile verification will confirm navigation integration."
else
    echo "ERROR: MONUApp.kt missing"
    exit 1
fi

echo "[9/11] Creating server contract documentation..."

cat > docs/SERVER_API_CONTRACT.md <<'EOF'
# MONU MOBILE <-> MONU SERVER CONTRACT

This document intentionally separates:

1. Known endpoints
2. Configured endpoints
3. Verified endpoints

## APK -> Server

The APK may eventually use:

- Health endpoint
- Capabilities endpoint
- Chat endpoint
- Command endpoint
- Upload endpoint
- WebSocket endpoint

## Truth Rules

An endpoint is not considered available merely because:

- A URL was entered
- A UI screen exists
- A button exists
- A test string exists

It becomes VERIFIED only after a real request succeeds.

## WebSocket

CONNECTED only after:

WebSocketListener.onOpen()

FAILED after:

WebSocketListener.onFailure()

## Server Contract Discovery

Before production integration, inspect the real MONU Server routes.

Never invent endpoint names if the server already defines them.
EOF

echo "[10/11] Updating project status..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 10
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Server API contract models
- Persistent server configuration
- Server endpoint configuration screen
- Real endpoint documentation

## Level 11
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- OkHttp WebSocket engine
- Real connection state
- onOpen based CONNECTED truth
- Failure detection
- Real-time connection monitor

Truth Rule:
A WebSocket is never displayed as CONNECTED
until the actual WebSocket onOpen callback occurs.
EOF

echo "[11/11] Running structural validation..."

./scripts/validate_project.sh

echo ""
echo "================================================"
echo " LEVEL 10 + LEVEL 11 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW FILES:"
find app/src/main/java/com/monu/mobile \
    -type f | sort

echo ""
echo "CURRENT REALITY STATUS"
echo "----------------------"
echo "Server contract UI: CREATED"
echo "Persistent config: CREATED"
echo "WebSocket engine: CREATED"
echo "Real endpoint values: NOT YET VERIFIED"
echo "Real compilation: NOT YET DONE"
echo ""
echo "NEXT CRITICAL STAGE:"
echo "Inspect MONU Server routes -> configure APK -> compile APK"
