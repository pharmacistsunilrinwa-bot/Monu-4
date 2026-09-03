#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 8 + LEVEL 9"
echo " LOCAL MEMORY + OFFLINE COMMAND QUEUE"
echo "================================================"

if [ ! -f "settings.gradle.kts" ]; then
    echo "ERROR: Run inside ~/projects/MONU-Mobile"
    exit 1
fi

echo "[1/10] Adding Room database dependencies..."

python - <<'PY'
from pathlib import Path

p = Path("app/build.gradle.kts")
s = p.read_text()

dependencies = [
    'implementation("androidx.room:room-runtime:2.6.1")',
    'implementation("androidx.room:room-ktx:2.6.1")',
    'ksp("androidx.room:room-compiler:2.6.1")'
]

if "plugins {" in s and 'alias(libs.plugins.ksp)' not in s and 'id("com.google.devtools.ksp")' not in s:
    s = s.replace(
        "plugins {",
        '''plugins {
    id("com.google.devtools.ksp") version "2.0.21-1.0.28"''',
        1
    )

for dep in dependencies:
    if dep not in s:
        s = s.replace(
            "dependencies {",
            "dependencies {\n    " + dep,
            1
        )

p.write_text(s)
PY

echo "[2/10] Creating offline command models..."

mkdir -p app/src/main/java/com/monu/mobile/data/local
mkdir -p app/src/main/java/com/monu/mobile/data/local/entity
mkdir -p app/src/main/java/com/monu/mobile/data/local/dao
mkdir -p app/src/main/java/com/monu/mobile/feature/offline

cat > app/src/main/java/com/monu/mobile/domain/model/OfflineCommandModels.kt <<'EOF'
package com.monu.mobile.domain.model

enum class CommandSyncState {
    PENDING,
    SYNCING,
    SENT,
    ACKNOWLEDGED,
    FAILED,
    RETRY_PENDING
}

data class OfflineCommand(
    val id: String,
    val command: String,
    val createdAt: Long,
    val syncState: CommandSyncState,
    val retryCount: Int = 0,
    val lastError: String? = null
)
EOF

echo "[3/10] Creating Room command entity..."

cat > app/src/main/java/com/monu/mobile/data/local/entity/OfflineCommandEntity.kt <<'EOF'
package com.monu.mobile.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "offline_commands")
data class OfflineCommandEntity(
    @PrimaryKey
    val id: String,

    val command: String,

    val createdAt: Long,

    val syncState: String,

    val retryCount: Int = 0,

    val lastError: String? = null
)
EOF

echo "[4/10] Creating Room DAO..."

cat > app/src/main/java/com/monu/mobile/data/local/dao/OfflineCommandDao.kt <<'EOF'
package com.monu.mobile.data.local.dao

import androidx.room.*
import com.monu.mobile.data.local.entity.OfflineCommandEntity

@Dao
interface OfflineCommandDao {

    @Insert(
        onConflict = OnConflictStrategy.REPLACE
    )
    suspend fun insert(
        command: OfflineCommandEntity
    )

    @Query(
        "SELECT * FROM offline_commands ORDER BY createdAt ASC"
    )
    suspend fun getAll():
        List<OfflineCommandEntity>

    @Query(
        """
        SELECT * FROM offline_commands
        WHERE syncState IN ('PENDING', 'RETRY_PENDING')
        ORDER BY createdAt ASC
        """
    )
    suspend fun getPending():
        List<OfflineCommandEntity>

    @Update
    suspend fun update(
        command: OfflineCommandEntity
    )

    @Query(
        "DELETE FROM offline_commands WHERE id = :id"
    )
    suspend fun deleteById(
        id: String
    )

    @Query(
        "SELECT COUNT(*) FROM offline_commands"
    )
    suspend fun count(): Int
}
EOF

echo "[5/10] Creating MONU local database..."

cat > app/src/main/java/com/monu/mobile/data/local/MONULocalDatabase.kt <<'EOF'
package com.monu.mobile.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.monu.mobile.data.local.dao.OfflineCommandDao
import com.monu.mobile.data.local.entity.OfflineCommandEntity

@Database(
    entities = [
        OfflineCommandEntity::class
    ],
    version = 1,
    exportSchema = false
)
abstract class MONULocalDatabase :
    RoomDatabase() {

    abstract fun offlineCommandDao():
        OfflineCommandDao
}
EOF

echo "[6/10] Creating database provider..."

cat > app/src/main/java/com/monu/mobile/data/local/MONUDatabaseProvider.kt <<'EOF'
package com.monu.mobile.data.local

import android.content.Context
import androidx.room.Room

object MONUDatabaseProvider {

    @Volatile
    private var instance:
        MONULocalDatabase? = null

    fun get(
        context: Context
    ): MONULocalDatabase {

        return instance ?: synchronized(this) {

            instance ?: Room.databaseBuilder(
                context.applicationContext,
                MONULocalDatabase::class.java,
                "monu_mobile.db"
            ).build().also {
                instance = it
            }
        }
    }
}
EOF

echo "[7/10] Creating offline queue repository..."

cat > app/src/main/java/com/monu/mobile/feature/offline/OfflineCommandQueue.kt <<'EOF'
package com.monu.mobile.feature.offline

import android.content.Context
import com.monu.mobile.data.local.MONUDatabaseProvider
import com.monu.mobile.data.local.entity.OfflineCommandEntity
import com.monu.mobile.domain.model.CommandSyncState
import java.util.UUID

class OfflineCommandQueue(
    context: Context
) {

    private val dao =
        MONUDatabaseProvider
            .get(context)
            .offlineCommandDao()

    suspend fun enqueue(
        command: String
    ): String {

        val id =
            UUID.randomUUID().toString()

        dao.insert(
            OfflineCommandEntity(
                id = id,
                command = command,
                createdAt =
                    System.currentTimeMillis(),
                syncState =
                    CommandSyncState.PENDING.name
            )
        )

        return id
    }

    suspend fun pending():
        List<OfflineCommandEntity> {

        return dao.getPending()
    }

    suspend fun markSyncing(
        command:
            OfflineCommandEntity
    ) {
        dao.update(
            command.copy(
                syncState =
                    CommandSyncState.SYNCING.name
            )
        )
    }

    suspend fun markRetry(
        command:
            OfflineCommandEntity,
        error: String?
    ) {
        dao.update(
            command.copy(
                syncState =
                    CommandSyncState.RETRY_PENDING.name,
                retryCount =
                    command.retryCount + 1,
                lastError = error
            )
        )
    }

    suspend fun markAcknowledged(
        command:
            OfflineCommandEntity
    ) {
        dao.update(
            command.copy(
                syncState =
                    CommandSyncState.ACKNOWLEDGED.name
            )
        )
    }

    suspend fun count(): Int {
        return dao.count()
    }
}
EOF

echo "[8/10] Creating real sync engine foundation..."

cat > app/src/main/java/com/monu/mobile/feature/offline/MONUSyncEngine.kt <<'EOF'
package com.monu.mobile.feature.offline

import com.monu.mobile.domain.repository.ConnectionRepository

class MONUSyncEngine(
    private val queue:
        OfflineCommandQueue,
    private val connectionRepository:
        ConnectionRepository =
            ConnectionRepository()
) {

    /*
     * This engine intentionally does NOT
     * pretend to send commands.
     *
     * Real command API integration will be
     * added only after the MONU Server
     * command contract is verified.
     */

    suspend fun synchronize(): SyncResult {

        val connection =
            connectionRepository
                .checkConnection()

        if (
            connection.apkToServer.name
            != "CONNECTED"
        ) {
            return SyncResult(
                attempted = 0,
                acknowledged = 0,
                message =
                    "Server is not connected. Queue preserved."
            )
        }

        val pending =
            queue.pending()

        return SyncResult(
            attempted = pending.size,
            acknowledged = 0,
            message =
                "Server connected, but command endpoint is not configured. Queue preserved."
        )
    }
}

data class SyncResult(
    val attempted: Int,
    val acknowledged: Int,
    val message: String
)
EOF

echo "[9/10] Creating Offline Queue Dashboard..."

cat > app/src/main/java/com/monu/mobile/ui/screens/OfflineQueueScreen.kt <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.monu.mobile.feature.offline.OfflineCommandQueue
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@Composable
fun OfflineQueueScreen() {

    val context =
        LocalContext.current

    val scope =
        rememberCoroutineScope()

    val queue =
        remember {
            OfflineCommandQueue(context)
        }

    var command by remember {
        mutableStateOf("")
    }

    var queueCount by remember {
        mutableStateOf(0)
    }

    var message by remember {
        mutableStateOf(
            "Local queue ready"
        )
    }

    fun refreshCount() {
        scope.launch {
            queueCount =
                withContext(Dispatchers.IO) {
                    queue.count()
                }
        }
    }

    LaunchedEffect(Unit) {
        refreshCount()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(20.dp),
        verticalArrangement =
            Arrangement.spacedBy(16.dp)
    ) {

        Text(
            text = "OFFLINE COMMAND QUEUE",
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
                    text =
                        "Pending local commands: $queueCount"
                )

                Text(
                    text = message
                )
            }
        }

        OutlinedTextField(
            modifier =
                Modifier.fillMaxWidth(),
            value = command,
            onValueChange = {
                command = it
            },
            label = {
                Text(
                    "Test offline command"
                )
            }
        )

        Button(
            enabled =
                command.isNotBlank(),
            onClick = {

                val value =
                    command.trim()

                scope.launch {

                    withContext(
                        Dispatchers.IO
                    ) {
                        queue.enqueue(value)
                    }

                    command = ""

                    message =
                        "Command stored locally"

                    refreshCount()
                }
            }
        ) {
            Text(
                "STORE IN LOCAL QUEUE"
            )
        }

        Button(
            onClick = {
                refreshCount()
                message =
                    "Queue refreshed"
            }
        ) {
            Text(
                "REFRESH QUEUE"
            )
        }
    }
}
EOF

echo "[10/10] Updating documentation..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 8
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Room database architecture
- Local MONU database
- Offline command entity
- Command DAO
- Persistent command storage

## Level 9
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Offline command queue
- Pending command persistence
- Retry state architecture
- Sync engine foundation
- Queue dashboard

Truth Rule:
Commands are not marked SENT or ACKNOWLEDGED
until a real server command API exists.
EOF

echo ""
echo "Running structural validation..."

./scripts/validate_project.sh

echo ""
echo "Checking new Level 8 + 9 files..."

find app/src/main/java/com/monu/mobile \
    -type f | sort

echo ""
echo "================================================"
echo " LEVEL 8 + LEVEL 9 SOURCE CREATED"
echo "================================================"

echo ""
echo "CURRENT OFFLINE ARCHITECTURE"
echo "----------------------------"
echo "Local database: CREATED"
echo "Offline queue: CREATED"
echo "Persistent commands: CREATED"
echo "Real server command sync: NOT YET CONFIGURED"
echo ""
echo "Truth rule active:"
echo "No queued command will be falsely marked delivered."
