#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 6 + LEVEL 7"
echo " REAL SERVER CONNECTION + CONNECTION TRUTH"
echo "================================================"

if [ ! -f "settings.gradle.kts" ]; then
    echo "ERROR: Run inside ~/projects/MONU-Mobile"
    exit 1
fi

echo "[1/10] Adding network dependencies..."

python - <<'PY'
from pathlib import Path

p = Path("app/build.gradle.kts")
s = p.read_text()

dependencies = [
    'implementation("com.squareup.okhttp3:okhttp:4.12.0")',
    'implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")'
]

if "dependencies {" not in s:
    raise SystemExit("ERROR: dependencies block not found")

for dep in dependencies:
    if dep not in s:
        s = s.replace(
            "dependencies {",
            "dependencies {\n    " + dep,
            1
        )

p.write_text(s)
PY

echo "[2/10] Adding Internet permission..."

python - <<'PY'
from pathlib import Path

p = Path("app/src/main/AndroidManifest.xml")
s = p.read_text()

permission = '<uses-permission android:name="android.permission.INTERNET" />'

if permission not in s:
    s = s.replace(
        "<application",
        permission + "\n\n    <application",
        1
    )

p.write_text(s)
PY

echo "[3/10] Creating server configuration..."

mkdir -p app/src/main/java/com/monu/mobile/core/network
mkdir -p app/src/main/java/com/monu/mobile/domain/model
mkdir -p app/src/main/java/com/monu/mobile/domain/repository
mkdir -p app/src/main/java/com/monu/mobile/data/network
mkdir -p app/src/main/java/com/monu/mobile/feature/connection
mkdir -p app/src/main/java/com/monu/mobile/ui/screens

cat > app/src/main/java/com/monu/mobile/core/network/ServerConfig.kt <<'EOF'
package com.monu.mobile.core.network

object ServerConfig {

    /*
     * IMPORTANT:
     *
     * Replace this later with your real MONU Server URL.
     *
     * Examples:
     * http://192.168.1.100:8000
     * https://your-server-domain.com
     */

    const val BASE_URL = ""

    const val HEALTH_ENDPOINT = "/health"
    const val CAPABILITIES_ENDPOINT = "/capabilities"

    fun isConfigured(): Boolean {
        return BASE_URL.isNotBlank()
    }

    fun healthUrl(): String {
        return BASE_URL.trimEnd('/') + HEALTH_ENDPOINT
    }

    fun capabilitiesUrl(): String {
        return BASE_URL.trimEnd('/') + CAPABILITIES_ENDPOINT
    }
}
EOF

echo "[4/10] Creating connection truth models..."

cat > app/src/main/java/com/monu/mobile/domain/model/ConnectionModels.kt <<'EOF'
package com.monu.mobile.domain.model

enum class ConnectionState {
    CONNECTED,
    DISCONNECTED,
    CHECKING,
    NOT_CONFIGURED,
    UNKNOWN
}

data class ConnectionStatus(
    val apkToServer: ConnectionState = ConnectionState.NOT_CONFIGURED,
    val serverToApk: ConnectionState = ConnectionState.UNKNOWN,
    val lastCheckedAt: Long? = null,
    val latencyMs: Long? = null,
    val message: String = "Server is not configured"
)

data class CapabilityStatus(
    val success: Boolean,
    val rawResponse: String,
    val error: String? = null
)
EOF

echo "[5/10] Creating real HTTP connection client..."

cat > app/src/main/java/com/monu/mobile/data/network/MONUServerClient.kt <<'EOF'
package com.monu.mobile.data.network

import com.monu.mobile.core.network.ServerConfig
import com.monu.mobile.domain.model.CapabilityStatus
import com.monu.mobile.domain.model.ConnectionState
import com.monu.mobile.domain.model.ConnectionStatus
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException
import java.util.concurrent.TimeUnit

class MONUServerClient {

    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .writeTimeout(15, TimeUnit.SECONDS)
        .build()

    fun checkHealth(): ConnectionStatus {

        if (!ServerConfig.isConfigured()) {
            return ConnectionStatus(
                apkToServer = ConnectionState.NOT_CONFIGURED,
                message = "MONU Server URL is not configured"
            )
        }

        val startTime = System.currentTimeMillis()

        return try {

            val request = Request.Builder()
                .url(ServerConfig.healthUrl())
                .get()
                .build()

            client.newCall(request).execute().use { response ->

                val latency =
                    System.currentTimeMillis() - startTime

                if (response.isSuccessful) {
                    ConnectionStatus(
                        apkToServer = ConnectionState.CONNECTED,
                        serverToApk = ConnectionState.UNKNOWN,
                        lastCheckedAt = System.currentTimeMillis(),
                        latencyMs = latency,
                        message = "Real server health request succeeded"
                    )
                } else {
                    ConnectionStatus(
                        apkToServer = ConnectionState.DISCONNECTED,
                        serverToApk = ConnectionState.UNKNOWN,
                        lastCheckedAt = System.currentTimeMillis(),
                        latencyMs = latency,
                        message = "Server returned HTTP ${response.code}"
                    )
                }
            }

        } catch (error: IOException) {

            ConnectionStatus(
                apkToServer = ConnectionState.DISCONNECTED,
                serverToApk = ConnectionState.UNKNOWN,
                lastCheckedAt = System.currentTimeMillis(),
                message = error.message ?: "Network connection failed"
            )

        } catch (error: Exception) {

            ConnectionStatus(
                apkToServer = ConnectionState.DISCONNECTED,
                serverToApk = ConnectionState.UNKNOWN,
                lastCheckedAt = System.currentTimeMillis(),
                message = error.message ?: "Unknown connection error"
            )
        }
    }

    fun discoverCapabilities(): CapabilityStatus {

        if (!ServerConfig.isConfigured()) {
            return CapabilityStatus(
                success = false,
                rawResponse = "",
                error = "Server URL is not configured"
            )
        }

        return try {

            val request = Request.Builder()
                .url(ServerConfig.capabilitiesUrl())
                .get()
                .build()

            client.newCall(request).execute().use { response ->

                val body =
                    response.body?.string().orEmpty()

                CapabilityStatus(
                    success = response.isSuccessful,
                    rawResponse = body,
                    error = if (response.isSuccessful) {
                        null
                    } else {
                        "HTTP ${response.code}"
                    }
                )
            }

        } catch (error: Exception) {

            CapabilityStatus(
                success = false,
                rawResponse = "",
                error = error.message
                    ?: "Capability discovery failed"
            )
        }
    }
}
EOF

echo "[6/10] Creating connection repository..."

cat > app/src/main/java/com/monu/mobile/domain/repository/ConnectionRepository.kt <<'EOF'
package com.monu.mobile.domain.repository

import com.monu.mobile.data.network.MONUServerClient
import com.monu.mobile.domain.model.CapabilityStatus
import com.monu.mobile.domain.model.ConnectionStatus

class ConnectionRepository(
    private val client: MONUServerClient = MONUServerClient()
) {

    fun checkConnection(): ConnectionStatus {
        return client.checkHealth()
    }

    fun discoverCapabilities(): CapabilityStatus {
        return client.discoverCapabilities()
    }
}
EOF

echo "[7/10] Creating heartbeat engine foundation..."

cat > app/src/main/java/com/monu/mobile/feature/connection/HeartbeatEngine.kt <<'EOF'
package com.monu.mobile.feature.connection

import com.monu.mobile.domain.model.ConnectionStatus
import com.monu.mobile.domain.repository.ConnectionRepository
import kotlinx.coroutines.*

class HeartbeatEngine(
    private val repository: ConnectionRepository = ConnectionRepository()
) {

    companion object {
        const val HEARTBEAT_INTERVAL_MS = 5 * 60 * 1000L
    }

    private var job: Job? = null

    fun start(
        scope: CoroutineScope,
        onStatus: (ConnectionStatus) -> Unit
    ) {

        stop()

        job = scope.launch(Dispatchers.IO) {

            while (isActive) {

                val status =
                    repository.checkConnection()

                withContext(Dispatchers.Main) {
                    onStatus(status)
                }

                delay(HEARTBEAT_INTERVAL_MS)
            }
        }
    }

    fun stop() {
        job?.cancel()
        job = null
    }
}
EOF

echo "[8/10] Creating real connection dashboard..."

cat > app/src/main/java/com/monu/mobile/ui/screens/ConnectionScreen.kt <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.monu.mobile.domain.model.ConnectionState
import com.monu.mobile.domain.model.ConnectionStatus
import com.monu.mobile.domain.repository.ConnectionRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun ConnectionScreen() {

    val scope = rememberCoroutineScope()

    var status by remember {
        mutableStateOf(
            ConnectionStatus()
        )
    }

    var checking by remember {
        mutableStateOf(false)
    }

    fun checkConnection() {
        scope.launch {

            checking = true

            status = withContext(Dispatchers.IO) {
                ConnectionRepository()
                    .checkConnection()
            }

            checking = false
        }
    }

    LaunchedEffect(Unit) {
        checkConnection()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement =
            Arrangement.spacedBy(18.dp)
    ) {

        Text(
            text = "SERVER CONNECTION TRUTH",
            style = MaterialTheme.typography.headlineSmall
        )

        Text(
            text = "Status is based on real network requests only.",
            style = MaterialTheme.typography.bodyMedium
        )

        ConnectionCard(
            title = "APK → MONU SERVER",
            state = status.apkToServer
        )

        ConnectionCard(
            title = "MONU SERVER → APK",
            state = status.serverToApk
        )

        Text(
            text = "Message: ${status.message}"
        )

        Text(
            text = "Latency: ${
                status.latencyMs?.let { "$it ms" }
                    ?: "Not available"
            }"
        )

        Text(
            text = "Last Check: ${
                status.lastCheckedAt?.let {
                    SimpleDateFormat(
                        "HH:mm:ss",
                        Locale.getDefault()
                    ).format(Date(it))
                } ?: "Never"
            }"
        )

        Button(
            enabled = !checking,
            onClick = {
                checkConnection()
            }
        ) {
            Text(
                if (checking)
                    "CHECKING..."
                else
                    "CHECK CONNECTION NOW"
            )
        }
    }
}

@Composable
private fun ConnectionCard(
    title: String,
    state: ConnectionState
) {

    val indicatorColor =
        when (state) {
            ConnectionState.CONNECTED ->
                Color(0xFF2E7D32)

            ConnectionState.DISCONNECTED ->
                Color(0xFFC62828)

            ConnectionState.CHECKING ->
                Color(0xFFFFA000)

            ConnectionState.NOT_CONFIGURED ->
                Color(0xFF757575)

            ConnectionState.UNKNOWN ->
                Color(0xFF757575)
        }

    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(18.dp),
            horizontalArrangement =
                Arrangement.spacedBy(12.dp)
        ) {

            Text(
                text = "●",
                color = indicatorColor,
                style =
                    MaterialTheme.typography.headlineMedium
            )

            Column {
                Text(
                    text = title,
                    style =
                        MaterialTheme.typography.titleMedium
                )

                Text(
                    text = state.name
                )
            }
        }
    }
}
EOF

echo "[9/10] Adding connection destination..."

python - <<'PY'
from pathlib import Path

p = Path(
    "app/src/main/java/com/monu/mobile/ui/navigation/MONUDestination.kt"
)

s = p.read_text()

if "CONNECTION" not in s:
    s = s.replace(
        "HOME(",
        'CONNECTION("Connection"),\n    HOME(',
        1
    )

p.write_text(s)
PY

python - <<'PY'
from pathlib import Path

p = Path(
    "app/src/main/java/com/monu/mobile/ui/MONUApp.kt"
)

s = p.read_text()

if "ConnectionScreen" not in s:
    s = s.replace(
        "import com.monu.mobile.ui.screens.HomeScreen",
        """import com.monu.mobile.ui.screens.HomeScreen
import com.monu.mobile.ui.screens.ConnectionScreen"""
    )

    marker = """MONUDestination.CHAT -> {
                        ChatScreen()
                    }"""

    replacement = """MONUDestination.CHAT -> {
                        ChatScreen()
                    }

                    MONUDestination.CONNECTION -> {
                        ConnectionScreen()
                    }"""

    s = s.replace(marker, replacement)

p.write_text(s)
PY

echo "[10/10] Updating project status..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 6
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- OkHttp real HTTP client
- Server configuration layer
- Real /health request architecture
- Real /capabilities request architecture
- Timeout handling
- Network error capture

## Level 7
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Connection truth model
- APK -> Server status
- Server -> APK unknown-state support
- Real latency measurement
- Last verified timestamp
- Manual connection check
- Five minute heartbeat engine foundation

Truth Rule:
CONNECTED is never hardcoded.
DISCONNECTED is based on actual request failure.
SERVER -> APK remains UNKNOWN until a real callback or WebSocket is implemented.
EOF

echo ""
echo "Running structural validation..."

./scripts/validate_project.sh

echo ""
echo "Checking new Level 6 + 7 files..."

find app/src/main/java/com/monu/mobile \
    -type f | sort

echo ""
echo "================================================"
echo " LEVEL 6 + LEVEL 7 SOURCE CREATED"
echo "================================================"

echo ""
echo "IMPORTANT CURRENT STATUS"
echo "------------------------"
echo "Server URL: NOT CONFIGURED"
echo "Health endpoint: NOT VERIFIED"
echo "Capabilities endpoint: NOT VERIFIED"
echo "Real compilation: NOT YET DONE"
echo ""
echo "Next step:"
echo "Compile through GitHub Actions and fix REAL compiler errors."
