#!/usr/bin/env bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 14 + LEVEL 15"
echo " TASK CENTER + PROJECT COMMAND CENTER"
echo "================================================"

BASE="app/src/main/java/com/monu/mobile"

mkdir -p "$BASE/domain/model"
mkdir -p "$BASE/feature/tasks"
mkdir -p "$BASE/feature/projects"
mkdir -p "$BASE/data/local"
mkdir -p "$BASE/ui/screens"

echo "[1/12] Creating task models..."

cat > "$BASE/domain/model/TaskModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUTaskStatus {
    QUEUED,
    STARTING,
    RUNNING,
    PROCESSING,
    VERIFYING,
    COMPLETED,
    FAILED,
    DIAGNOSING,
    RECOVERING,
    RETRYING,
    CANCELLED
}

enum class MONUTaskPriority {
    LOW,
    NORMAL,
    HIGH,
    CRITICAL
}

data class MONUTask(
    val id: String,
    val title: String,
    val description: String = "",
    val status: MONUTaskStatus = MONUTaskStatus.QUEUED,
    val priority: MONUTaskPriority = MONUTaskPriority.NORMAL,
    val progress: Int = 0,
    val currentStage: String = "",
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis(),
    val source: String = "LOCAL"
)
EOF

echo "[2/12] Creating task activity models..."

cat > "$BASE/domain/model/TaskActivityModels.kt" <<'EOF'
package com.monu.mobile.domain.model

data class TaskActivity(
    val id: String,
    val taskId: String,
    val message: String,
    val timestamp: Long = System.currentTimeMillis()
)
EOF

echo "[3/12] Creating task center engine..."

cat > "$BASE/feature/tasks/MONUTaskCenter.kt" <<'EOF'
package com.monu.mobile.feature.tasks

import com.monu.mobile.domain.model.MONUTask
import com.monu.mobile.domain.model.MONUTaskStatus

class MONUTaskCenter {

    private val tasks = mutableListOf<MONUTask>()

    fun addTask(task: MONUTask) {
        tasks.add(0, task)
    }

    fun allTasks(): List<MONUTask> {
        return tasks.toList()
    }

    fun activeTasks(): List<MONUTask> {
        return tasks.filter {
            it.status in setOf(
                MONUTaskStatus.QUEUED,
                MONUTaskStatus.STARTING,
                MONUTaskStatus.RUNNING,
                MONUTaskStatus.PROCESSING,
                MONUTaskStatus.VERIFYING,
                MONUTaskStatus.RECOVERING,
                MONUTaskStatus.RETRYING
            )
        }
    }

    fun completedTasks(): List<MONUTask> {
        return tasks.filter {
            it.status == MONUTaskStatus.COMPLETED
        }
    }

    fun failedTasks(): List<MONUTask> {
        return tasks.filter {
            it.status == MONUTaskStatus.FAILED
        }
    }
}
EOF

echo "[4/12] Creating project models..."

cat > "$BASE/domain/model/ProjectModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUProjectStatus {
    PLANNING,
    ACTIVE,
    PAUSED,
    BLOCKED,
    COMPLETED,
    ARCHIVED
}

data class MONUProject(
    val id: String,
    val name: String,
    val description: String = "",
    val status: MONUProjectStatus = MONUProjectStatus.PLANNING,
    val progress: Int = 0,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)

data class MONUProjectSummary(
    val projectId: String,
    val goals: Int = 0,
    val tasks: Int = 0,
    val files: Int = 0,
    val employees: Int = 0,
    val reports: Int = 0
)
EOF

echo "[5/12] Creating project command center..."

cat > "$BASE/feature/projects/MONUProjectCenter.kt" <<'EOF'
package com.monu.mobile.feature.projects

import com.monu.mobile.domain.model.MONUProject
import com.monu.mobile.domain.model.MONUProjectStatus

class MONUProjectCenter {

    private val projects = mutableListOf<MONUProject>()

    fun addProject(project: MONUProject) {
        projects.add(0, project)
    }

    fun allProjects(): List<MONUProject> {
        return projects.toList()
    }

    fun activeProjects(): List<MONUProject> {
        return projects.filter {
            it.status == MONUProjectStatus.ACTIVE
        }
    }

    fun findProject(id: String): MONUProject? {
        return projects.find {
            it.id == id
        }
    }
}
EOF

echo "[6/12] Creating task center screen..."

cat > "$BASE/ui/screens/TaskCenterScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.monu.mobile.domain.model.MONUTask
import com.monu.mobile.domain.model.MONUTaskPriority
import com.monu.mobile.domain.model.MONUTaskStatus

@Composable
fun TaskCenterScreen() {

    val tasks = listOf(
        MONUTask(
            id = "task-1",
            title = "MONU Task Center",
            description = "Task lifecycle architecture initialized",
            status = MONUTaskStatus.RUNNING,
            priority = MONUTaskPriority.NORMAL,
            progress = 45,
            currentStage = "Building mobile architecture"
        ),
        MONUTask(
            id = "task-2",
            title = "Server Integration",
            description = "Waiting for real endpoint configuration",
            status = MONUTaskStatus.QUEUED,
            priority = MONUTaskPriority.HIGH,
            progress = 0,
            currentStage = "Waiting"
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Live Task Center")

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.padding(top = 16.dp)
        ) {
            items(tasks) { task ->
                TaskCard(task)
            }
        }
    }
}

@Composable
private fun TaskCard(task: MONUTask) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(task.title)
            Text(task.description)
            Text("Status: ${task.status}")
            Text("Stage: ${task.currentStage}")
            Text("Progress: ${task.progress}%")

            LinearProgressIndicator(
                progress = { task.progress / 100f },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp)
            )
        }
    }
}
EOF

echo "[7/12] Creating project center screen..."

cat > "$BASE/ui/screens/ProjectCenterScreen.kt" <<'EOF'
package com.monu.mobile.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.monu.mobile.domain.model.MONUProject
import com.monu.mobile.domain.model.MONUProjectStatus

@Composable
fun ProjectCenterScreen() {

    val projects = listOf(
        MONUProject(
            id = "monu-mobile",
            name = "MONU Mobile Command OS",
            description = "Android owner command center",
            status = MONUProjectStatus.ACTIVE,
            progress = 35
        ),
        MONUProject(
            id = "monu-server",
            name = "MONU Server",
            description = "Central AI brain and workforce",
            status = MONUProjectStatus.ACTIVE,
            progress = 70
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Project Command Center")

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.padding(top = 16.dp)
        ) {
            items(projects) { project ->
                ProjectCard(project)
            }
        }
    }
}

@Composable
private fun ProjectCard(project: MONUProject) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(project.name)
            Text(project.description)
            Text("Status: ${project.status}")
            Text("Progress: ${project.progress}%")

            LinearProgressIndicator(
                progress = { project.progress / 100f },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp)
            )

            Text(
                "Goals • Tasks • Files • Employees • Reports",
                modifier = Modifier.padding(top = 8.dp)
            )
        }
    }
}
EOF

echo "[8/12] Adding navigation destinations..."

NAV="$BASE/ui/navigation/MONUDestination.kt"

python - <<'PY'
from pathlib import Path

p = Path("app/src/main/java/com/monu/mobile/ui/navigation/MONUDestination.kt")
s = p.read_text()

if "TASK_CENTER" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    TASK_CENTER,
    PROJECT_CENTER,"""
    )

p.write_text(s)
PY

echo "[9/12] Creating task lifecycle documentation..."

cat > docs/TASK_ARCHITECTURE.md <<'EOF'
# MONU TASK CENTER ARCHITECTURE

Every MONU task follows a lifecycle.

QUEUED
↓
STARTING
↓
RUNNING
↓
PROCESSING
↓
VERIFYING
↓
COMPLETED

Failure lifecycle:

FAILED
↓
DIAGNOSING
↓
RECOVERING
↓
RETRYING

Future integrations:

- Server task events
- WebSocket progress
- Background workers
- Task cancellation
- Retry controls
- Activity timeline
- Result attachments

Truth Rule:

Task progress must eventually originate from real task events.
EOF

echo "[10/12] Creating project architecture documentation..."

cat > docs/PROJECT_ARCHITECTURE.md <<'EOF'
# MONU PROJECT COMMAND CENTER

Each project may contain:

GOALS
TASKS
FILES
ACTIVITY
EMPLOYEES
STATUS
REPORTS

Future integration:

MONU Server can expose project information and the APK
will synchronize it into the Project Command Center.

Projects may also have dedicated conversations.

Architecture direction:

PROJECT
├── Goals
├── Tasks
├── Files
├── Conversations
├── Employees
├── Activity
└── Reports
EOF

echo "[11/12] Updating project status..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 14
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Task domain models
- Task lifecycle states
- Task priority
- Task activity architecture
- Task center engine
- Live task center UI
- Progress visualization
- Failure and recovery states

## Level 15
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Project domain models
- Project status lifecycle
- Project center engine
- Project command center UI
- Project progress visualization
- Future goals/tasks/files/employees/reports architecture

Truth Rule:
Server task and project data will only be displayed as real
after actual API or WebSocket integration.
EOF

echo "[12/12] Running structural validation..."

./scripts/validate_project.sh

echo ""
echo "================================================"
echo " LEVEL 14 + LEVEL 15 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW CAPABILITIES:"
echo "✓ Task Lifecycle Architecture"
echo "✓ Live Task Center"
echo "✓ Task Progress Model"
echo "✓ Failure Recovery States"
echo "✓ Project Command Center"
echo "✓ Project Status Model"
echo "✓ Project Progress"
echo "✓ Goals / Tasks / Files Architecture"
echo "✓ Employee / Report Architecture"
echo ""

echo "Checking new source files..."
find "$BASE/domain/model" "$BASE/feature/tasks" \
     "$BASE/feature/projects" "$BASE/ui/screens" \
     -type f | sort

echo ""
echo "NEXT BUILD LEVEL:"
echo "Level 16 + 17 -> AI Employee Dashboard + Live Activity Log"
