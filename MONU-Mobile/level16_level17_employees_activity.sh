#!/usr/bin/env bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 16 + LEVEL 17"
echo " AI EMPLOYEE DASHBOARD + LIVE ACTIVITY LOG"
echo "================================================"

BASE="app/src/main/java/com/monu/mobile"

echo "[1/12] Creating package structure..."

mkdir -p "$BASE/domain/model"
mkdir -p "$BASE/feature/employees"
mkdir -p "$BASE/feature/activity"
mkdir -p "$BASE/ui/screens"
mkdir -p docs


echo "[2/12] Creating AI Employee domain models..."

cat > "$BASE/domain/model/EmployeeModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUEmployeeStatus {
    IDLE,
    STARTING,
    WORKING,
    PROCESSING,
    WAITING,
    VERIFYING,
    COMPLETED,
    FAILED,
    OFFLINE,
    UNKNOWN
}

enum class MONUEmployeeType {
    DEVELOPER,
    RESEARCHER,
    DATA_ANALYST,
    BUSINESS,
    SUPPORT,
    MEDIA,
    SECURITY,
    SYSTEM,
    CUSTOM
}

data class MONUEmployee(
    val id: String,
    val name: String,
    val type: MONUEmployeeType,
    val status: MONUEmployeeStatus,
    val currentTask: String? = null,
    val progress: Int? = null,
    val lastActivity: String? = null,
    val error: String? = null
)
EOF


echo "[3/12] Creating Employee activity models..."

cat > "$BASE/domain/model/EmployeeActivityModels.kt" <<'EOF'
package com.monu.mobile.domain.model

data class MONUEmployeeActivity(
    val id: String,
    val employeeId: String,
    val timestamp: Long,
    val title: String,
    val description: String,
    val taskId: String? = null
)
EOF


echo "[4/12] Creating Live Activity domain models..."

cat > "$BASE/domain/model/ActivityLogModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUActivitySource {
    OWNER,
    MONU,
    SERVER,
    EMPLOYEE,
    SYSTEM,
    TASK,
    SECURITY,
    CONNECTION
}

enum class MONUActivitySeverity {
    INFO,
    SUCCESS,
    WARNING,
    ERROR,
    CRITICAL
}

data class MONUActivityLog(
    val id: String,
    val timestamp: Long,
    val source: MONUActivitySource,
    val severity: MONUActivitySeverity,
    val title: String,
    val description: String,
    val relatedTaskId: String? = null,
    val relatedEmployeeId: String? = null,
    val relatedProjectId: String? = null
)
EOF


echo "[5/12] Creating AI Employee Dashboard engine..."

cat > "$BASE/feature/employees/MONUEmployeeCenter.kt" <<'EOF'
package com.monu.mobile.feature.employees

import com.monu.mobile.domain.model.MONUEmployee
import com.monu.mobile.domain.model.MONUEmployeeStatus
import com.monu.mobile.domain.model.MONUEmployeeType

class MONUEmployeeCenter {

    private val employees = mutableListOf<MONUEmployee>()

    fun replaceEmployees(
        newEmployees: List<MONUEmployee>
    ) {
        employees.clear()
        employees.addAll(newEmployees)
    }

    fun getEmployees(): List<MONUEmployee> {
        return employees.toList()
    }

    fun getEmployee(
        employeeId: String
    ): MONUEmployee? {
        return employees.find {
            it.id == employeeId
        }
    }

    fun updateEmployeeStatus(
        employeeId: String,
        status: MONUEmployeeStatus,
        task: String? = null,
        progress: Int? = null
    ) {
        val index = employees.indexOfFirst {
            it.id == employeeId
        }

        if (index >= 0) {
            val old = employees[index]

            employees[index] = old.copy(
                status = status,
                currentTask = task ?: old.currentTask,
                progress = progress ?: old.progress
            )
        }
    }

    fun countByStatus(
        status: MONUEmployeeStatus
    ): Int {
        return employees.count {
            it.status == status
        }
    }

    fun countByType(
        type: MONUEmployeeType
    ): Int {
        return employees.count {
            it.type == type
        }
    }
}
EOF


echo "[6/12] Creating Live Activity Log engine..."

cat > "$BASE/feature/activity/MONUActivityCenter.kt" <<'EOF'
package com.monu.mobile.feature.activity

import com.monu.mobile.domain.model.MONUActivityLog
import com.monu.mobile.domain.model.MONUActivitySeverity
import com.monu.mobile.domain.model.MONUActivitySource

class MONUActivityCenter {

    private val activities = mutableListOf<MONUActivityLog>()

    fun addActivity(
        activity: MONUActivityLog
    ) {
        activities.add(activity)
    }

    fun getActivities(): List<MONUActivityLog> {
        return activities
            .sortedByDescending {
                it.timestamp
            }
    }

    fun getActivitiesBySource(
        source: MONUActivitySource
    ): List<MONUActivityLog> {
        return getActivities().filter {
            it.source == source
        }
    }

    fun getActivitiesBySeverity(
        severity: MONUActivitySeverity
    ): List<MONUActivityLog> {
        return getActivities().filter {
            it.severity == severity
        }
    }

    fun clear() {
        activities.clear()
    }
}
EOF


echo "[7/12] Creating AI Employee Dashboard screen..."

cat > "$BASE/ui/screens/EmployeeDashboardScreen.kt" <<'EOF'
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
import com.monu.mobile.domain.model.MONUEmployee
import com.monu.mobile.domain.model.MONUEmployeeStatus
import com.monu.mobile.domain.model.MONUEmployeeType

@Composable
fun EmployeeDashboardScreen() {

    val employees = listOf(
        MONUEmployee(
            id = "developer",
            name = "Developer Employee",
            type = MONUEmployeeType.DEVELOPER,
            status = MONUEmployeeStatus.UNKNOWN,
            currentTask = "Awaiting real server data"
        ),
        MONUEmployee(
            id = "researcher",
            name = "Research Employee",
            type = MONUEmployeeType.RESEARCHER,
            status = MONUEmployeeStatus.UNKNOWN,
            currentTask = "Awaiting real server data"
        ),
        MONUEmployee(
            id = "data",
            name = "Data Employee",
            type = MONUEmployeeType.DATA_ANALYST,
            status = MONUEmployeeStatus.UNKNOWN,
            currentTask = "Awaiting real server data"
        ),
        MONUEmployee(
            id = "business",
            name = "Business Employee",
            type = MONUEmployeeType.BUSINESS,
            status = MONUEmployeeStatus.UNKNOWN,
            currentTask = "Awaiting real server data"
        ),
        MONUEmployee(
            id = "media",
            name = "Media Employee",
            type = MONUEmployeeType.MEDIA,
            status = MONUEmployeeStatus.UNKNOWN,
            currentTask = "Awaiting real server data"
        ),
        MONUEmployee(
            id = "security",
            name = "Security Employee",
            type = MONUEmployeeType.SECURITY,
            status = MONUEmployeeStatus.UNKNOWN,
            currentTask = "Awaiting real server data"
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU AI Workforce")

        Text(
            "Employee states become LIVE only after real server integration."
        )

        LazyColumn(
            contentPadding = PaddingValues(top = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(employees) { employee ->
                EmployeeCard(employee)
            }
        }
    }
}

@Composable
private fun EmployeeCard(
    employee: MONUEmployee
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(employee.name)
            Text("Type: ${employee.type}")
            Text("Status: ${employee.status}")

            employee.currentTask?.let {
                Text("Current Task: $it")
            }

            employee.progress?.let {
                Text("Progress: $it%")
            }

            employee.lastActivity?.let {
                Text("Last Activity: $it")
            }

            employee.error?.let {
                Text("Error: $it")
            }
        }
    }
}
EOF


echo "[8/12] Creating Live Activity Log screen..."

cat > "$BASE/ui/screens/ActivityLogScreen.kt" <<'EOF'
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
import com.monu.mobile.domain.model.MONUActivityLog
import com.monu.mobile.domain.model.MONUActivitySeverity
import com.monu.mobile.domain.model.MONUActivitySource

@Composable
fun ActivityLogScreen() {

    val activities = listOf(
        MONUActivityLog(
            id = "architecture",
            timestamp = 0L,
            source = MONUActivitySource.SYSTEM,
            severity = MONUActivitySeverity.INFO,
            title = "Live Activity Architecture Ready",
            description = "Real MONU activity events will appear here after server integration."
        ),
        MONUActivityLog(
            id = "transparency",
            timestamp = 0L,
            source = MONUActivitySource.MONU,
            severity = MONUActivitySeverity.INFO,
            title = "Transparency Timeline",
            description = "Commands, planning, assignments and execution events can be recorded here."
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Live Activity")

        Text(
            "This timeline is designed for real system transparency."
        )

        LazyColumn(
            contentPadding = PaddingValues(top = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(activities) { activity ->
                ActivityCard(activity)
            }
        }
    }
}

@Composable
private fun ActivityCard(
    activity: MONUActivityLog
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(activity.title)
            Text(activity.description)
            Text("Source: ${activity.source}")
            Text("Severity: ${activity.severity}")
        }
    }
}
EOF


echo "[9/12] Adding navigation destinations..."

python - <<'PY'
from pathlib import Path

p = Path(
    "app/src/main/java/com/monu/mobile/ui/navigation/MONUDestination.kt"
)

s = p.read_text()

if "EMPLOYEES" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    EMPLOYEES,
    ACTIVITY_LOG,"""
    )

p.write_text(s)
PY


echo "[10/12] Creating architecture documentation..."

cat > docs/AI_WORKFORCE_ARCHITECTURE.md <<'EOF'
# MONU AI WORKFORCE ARCHITECTURE

MONU may operate multiple specialized AI Employees.

Example workforce:

- Developer Employee
- Research Employee
- Data Employee
- Business Employee
- Support Employee
- Media Employee
- Security Employee
- System Employee
- Custom Employees

Each employee may expose:

- Identity
- Type
- Current status
- Current task
- Progress
- Previous activities
- Errors
- Result
- Related project

Future server integration:

APK
↓
Server Employee API / WebSocket
↓
Employee Registry
↓
Employee Dashboard

Truth Rule:

Employee status must not be falsely presented as active.

UNKNOWN means:

The APK has no verified live information.
EOF


cat > docs/LIVE_ACTIVITY_ARCHITECTURE.md <<'EOF'
# MONU LIVE ACTIVITY ARCHITECTURE

MONU should not behave like a black box.

The owner should eventually be able to inspect a timeline.

Example:

10:30 Command received

10:30 Intent detected

10:31 Context analyzed

10:31 Plan generated

10:32 Developer Employee assigned

10:33 Code inspection started

10:34 Verification started

10:35 Task completed

Possible activity sources:

OWNER
MONU
SERVER
EMPLOYEE
SYSTEM
TASK
SECURITY
CONNECTION

Activity severity:

INFO
SUCCESS
WARNING
ERROR
CRITICAL

Future event transport:

Server
↓
WebSocket
↓
Realtime Event Parser
↓
Local Activity Store
↓
MONU Activity Timeline

Truth Rule:

Historical and live events should identify their real source.
EOF


echo "[11/12] Updating project status..."

cat >> docs/PROJECT_STATUS.md <<'EOF'

## Level 16
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- AI Employee domain models
- Employee type architecture
- Employee status lifecycle
- Employee activity models
- AI Workforce center
- Employee Dashboard UI
- Current task architecture
- Employee progress architecture
- Error visibility architecture

Truth Rule:
UNKNOWN is used when live server employee data is unavailable.

## Level 17
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Live activity domain models
- Activity source architecture
- Severity architecture
- Activity center engine
- Transparency timeline
- Live activity log UI

Architecture direction:

Owner Command
↓
MONU
↓
Intent
↓
Plan
↓
Employee
↓
Execution
↓
Verification
↓
Activity Timeline

Truth Rule:
A live activity event must eventually originate from a real system event.
EOF


echo "[12/12] Running structural validation..."

./scripts/validate_project.sh


echo ""
echo "================================================"
echo " LEVEL 16 + LEVEL 17 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW CAPABILITIES:"
echo "✓ AI Workforce Architecture"
echo "✓ Developer Employee Model"
echo "✓ Research Employee Model"
echo "✓ Data Employee Model"
echo "✓ Business Employee Model"
echo "✓ Media Employee Model"
echo "✓ Security Employee Model"
echo "✓ Employee Status Tracking"
echo "✓ Employee Task Tracking"
echo "✓ Employee Progress Architecture"
echo ""
echo "✓ Live Activity Timeline"
echo "✓ MONU Transparency Architecture"
echo "✓ Activity Source Tracking"
echo "✓ Severity Tracking"
echo "✓ Future WebSocket Activity Integration"
echo ""

echo "Checking new source files..."

find \
    "$BASE/domain/model" \
    "$BASE/feature/employees" \
    "$BASE/feature/activity" \
    "$BASE/ui/screens" \
    -type f | sort

echo ""
echo "IMPORTANT:"
echo "Employee and activity architecture source created."
echo "Real Android compilation is still pending."
echo ""
echo "NEXT BUILD LEVEL:"
echo "Level 18 + 19 -> Media Studio + Advanced File Transfer Engine"
