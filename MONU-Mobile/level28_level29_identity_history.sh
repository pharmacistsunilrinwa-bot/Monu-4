#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 28 + LEVEL 29"
echo " USER IDENTITY + COMMAND HISTORY INTELLIGENCE"
echo "================================================"

BASE="app/src/main/java/com/monu/mobile"

echo "[1/14] Creating package structure..."

mkdir -p "$BASE/feature/identity"
mkdir -p "$BASE/feature/history"
mkdir -p "$BASE/domain/model"
mkdir -p "$BASE/ui/screens"
mkdir -p docs


echo "[2/14] Creating Identity and Session models..."

cat > "$BASE/domain/model/IdentityModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUSessionStatus {
    ACTIVE,
    EXPIRED,
    LOGGED_OUT,
    UNKNOWN
}

data class MONUUserIdentity(
    val id: String,
    val displayName: String,
    val authenticated: Boolean,
    val source: String,
    val verified: Boolean
)

data class MONUSession(
    val id: String,
    val status: MONUSessionStatus,
    val createdAt: Long,
    val expiresAt: Long?,
    val verified: Boolean
)
EOF


echo "[3/14] Creating Command History models..."

cat > "$BASE/domain/model/CommandHistoryModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUCommandStatus {
    RECEIVED,
    PROCESSING,
    COMPLETED,
    FAILED,
    UNKNOWN
}

data class MONUCommandHistoryEntry(
    val id: String,
    val command: String,
    val timestamp: Long,
    val status: MONUCommandStatus,
    val resultSummary: String? = null,
    val source: String = "OWNER",
    val verified: Boolean = false
)

data class MONUCommandPattern(
    val pattern: String,
    val count: Int,
    val description: String
)
EOF


echo "[4/14] Creating Identity Center engine..."

cat > "$BASE/feature/identity/MONUIdentityCenter.kt" <<'EOF'
package com.monu.mobile.feature.identity

import com.monu.mobile.domain.model.MONUSession
import com.monu.mobile.domain.model.MONUSessionStatus
import com.monu.mobile.domain.model.MONUUserIdentity

class MONUIdentityCenter {

    fun currentIdentity(): MONUUserIdentity {
        return MONUUserIdentity(
            id = "unknown",
            displayName = "MONU Owner",
            authenticated = false,
            source = "LOCAL_ARCHITECTURE",
            verified = false
        )
    }

    fun currentSession(): MONUSession {
        return MONUSession(
            id = "unknown",
            status = MONUSessionStatus.UNKNOWN,
            createdAt = 0L,
            expiresAt = null,
            verified = false
        )
    }
}
EOF


echo "[5/14] Creating Command History Intelligence engine..."

cat > "$BASE/feature/history/MONUCommandHistory.kt" <<'EOF'
package com.monu.mobile.feature.history

import com.monu.mobile.domain.model.MONUCommandHistoryEntry
import com.monu.mobile.domain.model.MONUCommandPattern

class MONUCommandHistory {

    private val commands = mutableListOf<MONUCommandHistoryEntry>()

    fun add(entry: MONUCommandHistoryEntry) {
        commands += entry
    }

    fun all(): List<MONUCommandHistoryEntry> {
        return commands.sortedByDescending { it.timestamp }
    }

    fun analyzePatterns(): List<MONUCommandPattern> {
        if (commands.isEmpty()) return emptyList()

        val grouped = commands
            .groupBy { it.command.trim().lowercase() }

        return grouped.map { (command, entries) ->
            MONUCommandPattern(
                pattern = command,
                count = entries.size,
                description = "This command pattern occurred ${entries.size} time(s)."
            )
        }.sortedByDescending { it.count }
    }

    fun clear() {
        commands.clear()
    }
}
EOF


echo "[6/14] Creating Identity and Session Center screen..."

cat > "$BASE/ui/screens/IdentitySessionScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.monu.mobile.feature.identity.MONUIdentityCenter

@Composable
fun IdentitySessionScreen() {

    val center = remember { MONUIdentityCenter() }

    var identityText by remember {
        mutableStateOf("Identity information not yet inspected.")
    }

    var sessionText by remember {
        mutableStateOf("Session information not yet inspected.")
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Identity & Session Center")

        Button(
            modifier = Modifier.padding(top = 16.dp),
            onClick = {
                val identity = center.currentIdentity()
                val session = center.currentSession()

                identityText =
                    "Identity: ${identity.displayName}\n" +
                    "Authenticated: ${identity.authenticated}\n" +
                    "Verified: ${identity.verified}\n" +
                    "Source: ${identity.source}"

                sessionText =
                    "Session: ${session.status}\n" +
                    "Verified: ${session.verified}"
            }
        ) {
            Text("Inspect Identity")
        }

        Card(
            modifier = Modifier.padding(top = 16.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(identityText)
            }
        }

        Card(
            modifier = Modifier.padding(top = 16.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(sessionText)
            }
        }
    }
}
EOF


echo "[7/14] Creating Command History screen..."

cat > "$BASE/ui/screens/CommandHistoryScreen.kt" <<'EOF'
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
import com.monu.mobile.domain.model.MONUCommandHistoryEntry
import com.monu.mobile.domain.model.MONUCommandStatus

@Composable
fun CommandHistoryScreen() {

    val entries = listOf(
        MONUCommandHistoryEntry(
            id = "architecture",
            command = "Command history architecture",
            timestamp = 0L,
            status = MONUCommandStatus.UNKNOWN,
            resultSummary = "Real command events will appear here after integration.",
            verified = false
        ),
        MONUCommandHistoryEntry(
            id = "intelligence",
            command = "Command pattern intelligence",
            timestamp = 0L,
            status = MONUCommandStatus.UNKNOWN,
            resultSummary = "Patterns will be calculated from real recorded commands.",
            verified = false
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Command History")

        Text(
            "Command history and intelligence must be based on real recorded commands."
        )

        LazyColumn(
            contentPadding = PaddingValues(top = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(entries) { entry ->
                CommandHistoryCard(entry)
            }
        }
    }
}

@Composable
private fun CommandHistoryCard(
    entry: MONUCommandHistoryEntry
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(entry.command)
            Text(entry.resultSummary ?: "No result summary")
            Text("Status: ${entry.status}")
            Text("Verified: ${entry.verified}")
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

if "IDENTITY_SESSION" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    IDENTITY_SESSION,
    COMMAND_HISTORY,"""
    )

p.write_text(s)
PY


echo "[9/14] Creating Identity architecture documentation..."

cat > docs/IDENTITY_SESSION_ARCHITECTURE.md <<'EOF'
# MONU IDENTITY AND SESSION ARCHITECTURE

MONU distinguishes between:

1. Display identity
2. Authentication state
3. Session state
4. Server verified identity

Identity states must not be invented.

Architecture:

IDENTITY SOURCE
↓
AUTHENTICATION
↓
SESSION
↓
VERIFICATION
↓
IDENTITY CENTER

Truth Rule:

A displayed username does not automatically prove
server authentication.

UNKNOWN is preferred when no verified session exists.

Future integration:

- Server authentication
- Secure token storage
- Session refresh
- Session expiry
- Multi-device session management
- Login activity
EOF


echo "[10/14] Creating Command History Intelligence documentation..."

cat > docs/COMMAND_HISTORY_INTELLIGENCE.md <<'EOF'
# MONU COMMAND HISTORY INTELLIGENCE

MONU may eventually maintain a real history of commands.

Architecture:

OWNER COMMAND
↓
COMMAND RECEIVED
↓
PROCESSING
↓
RESULT
↓
HISTORY STORE
↓
PATTERN ANALYSIS

Possible intelligence:

- Frequently repeated commands
- Command categories
- Success rate
- Failure patterns
- Time patterns
- Project associations
- Preferred workflows

Truth Rule:

Command intelligence must be calculated from actual
recorded commands.

No artificial command history should be presented as
real owner activity.

Future production features:

- Persistent history
- Search
- Filters
- Analytics
- Server synchronization
- Privacy controls
- History export
EOF


echo "[11/14] Updating project validation..."

python - <<'PY'
from pathlib import Path

p = Path("scripts/validate_project.sh")
s = p.read_text()

new_files = [
    "app/src/main/java/com/monu/mobile/ui/screens/IdentitySessionScreen.kt",
    "app/src/main/java/com/monu/mobile/ui/screens/CommandHistoryScreen.kt",
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

## Level 28
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- User identity models
- Session status lifecycle
- Identity Center engine
- Identity and Session Center UI
- Verified identity separation
- Unknown session protection

Truth Rule:
Display identity is not falsely treated as authenticated identity.

## Level 29
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Command history models
- Command status lifecycle
- Command History engine
- Pattern analysis architecture
- Command History UI
- Future persistent command intelligence

Truth Rule:
Command intelligence must originate from real command history.
EOF


echo "[13/14] Running structural validation..."

./scripts/validate_project.sh


echo "[14/14] Checking Level 28 + 29 files..."

find \
    "$BASE/domain/model" \
    "$BASE/feature/identity" \
    "$BASE/feature/history" \
    "$BASE/ui/screens" \
    -type f | sort


echo ""
echo "================================================"
echo " LEVEL 28 + LEVEL 29 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW CAPABILITIES:"
echo "✓ User Identity Architecture"
echo "✓ Session Lifecycle Models"
echo "✓ Identity Center"
echo "✓ Verified Identity Separation"
echo "✓ Unknown Session Protection"
echo ""
echo "✓ Command History Architecture"
echo "✓ Command Status Tracking"
echo "✓ Command Pattern Analysis"
echo "✓ History Intelligence Foundation"
echo "✓ Future Persistent Command Store"
echo ""
echo "TRUTH RULE:"
echo "Identity and command history are never fabricated."
echo ""
echo "IMPORTANT:"
echo "Source creation and structural validation only."
echo "Real Android compilation is still pending."
echo ""
echo "NEXT BUILD LEVEL:"
echo "Level 30 + 31 -> Workflow Automation Center + MONU Rules Engine"
