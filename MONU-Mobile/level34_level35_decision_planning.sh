#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "================================================"
echo " MONU MOBILE - LEVEL 34 + LEVEL 35"
echo " DECISION CENTER + PLANNING INTELLIGENCE"
echo "================================================"

BASE="app/src/main/java/com/monu/mobile"

echo "[1/14] Creating package structure..."

mkdir -p \
    "$BASE/domain/model" \
    "$BASE/feature/decision" \
    "$BASE/feature/planning" \
    "$BASE/ui/screens"

echo "[2/14] Creating Decision Center models..."

cat > "$BASE/domain/model/DecisionModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUDecisionStatus {
    UNKNOWN,
    PENDING,
    ANALYZING,
    READY,
    SELECTED,
    REJECTED,
    FAILED
}

enum class MONUDecisionFactorType {
    BENEFIT,
    RISK,
    COST,
    TIME,
    PRIORITY,
    DEPENDENCY,
    CONFIDENCE,
    CUSTOM
}

data class MONUDecisionFactor(
    val id: String,
    val type: MONUDecisionFactorType,
    val title: String,
    val value: String,
    val weight: Int = 0
)

data class MONUDecisionOption(
    val id: String,
    val title: String,
    val description: String,
    val factors: List<MONUDecisionFactor> = emptyList()
)

data class MONUDecision(
    val id: String,
    val title: String,
    val description: String,
    val status: MONUDecisionStatus = MONUDecisionStatus.UNKNOWN,
    val options: List<MONUDecisionOption> = emptyList(),
    val selectedOptionId: String? = null,
    val source: String = "UNKNOWN"
)
EOF


echo "[3/14] Creating Planning Intelligence models..."

cat > "$BASE/domain/model/PlanningModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUPlanStatus {
    UNKNOWN,
    CREATED,
    ANALYZING,
    READY,
    EXECUTING,
    PAUSED,
    COMPLETED,
    FAILED,
    CANCELLED
}

enum class MONUPlanStepStatus {
    PENDING,
    READY,
    RUNNING,
    BLOCKED,
    COMPLETED,
    FAILED,
    SKIPPED,
    UNKNOWN
}

data class MONUPlanStep(
    val id: String,
    val title: String,
    val description: String,
    val status: MONUPlanStepStatus = MONUPlanStepStatus.UNKNOWN,
    val dependencies: List<String> = emptyList(),
    val estimatedPriority: Int = 0
)

data class MONUPlanRisk(
    val id: String,
    val title: String,
    val description: String,
    val severity: String = "UNKNOWN"
)

data class MONUPlan(
    val id: String,
    val goal: String,
    val status: MONUPlanStatus = MONUPlanStatus.UNKNOWN,
    val steps: List<MONUPlanStep> = emptyList(),
    val risks: List<MONUPlanRisk> = emptyList(),
    val source: String = "UNKNOWN"
)
EOF


echo "[4/14] Creating Decision Center engine..."

cat > "$BASE/feature/decision/MONUDecisionCenter.kt" <<'EOF'
package com.monu.mobile.feature.decision

import com.monu.mobile.domain.model.MONUDecision
import com.monu.mobile.domain.model.MONUDecisionOption
import com.monu.mobile.domain.model.MONUDecisionStatus

class MONUDecisionCenter {

    fun createDecision(
        id: String,
        title: String,
        description: String,
        options: List<MONUDecisionOption>
    ): MONUDecision {
        return MONUDecision(
            id = id,
            title = title,
            description = description,
            status = if (options.isEmpty()) {
                MONUDecisionStatus.UNKNOWN
            } else {
                MONUDecisionStatus.PENDING
            },
            options = options,
            source = "LOCAL_ARCHITECTURE"
        )
    }

    fun selectOption(
        decision: MONUDecision,
        optionId: String
    ): MONUDecision {
        val exists = decision.options.any { it.id == optionId }

        if (!exists) return decision

        return decision.copy(
            status = MONUDecisionStatus.SELECTED,
            selectedOptionId = optionId
        )
    }
}
EOF


echo "[5/14] Creating Planning Intelligence engine..."

cat > "$BASE/feature/planning/MONUPlanningIntelligence.kt" <<'EOF'
package com.monu.mobile.feature.planning

import com.monu.mobile.domain.model.MONUPlan
import com.monu.mobile.domain.model.MONUPlanRisk
import com.monu.mobile.domain.model.MONUPlanStatus
import com.monu.mobile.domain.model.MONUPlanStep
import com.monu.mobile.domain.model.MONUPlanStepStatus

class MONUPlanningIntelligence {

    fun createPlan(
        id: String,
        goal: String,
        steps: List<MONUPlanStep>,
        risks: List<MONUPlanRisk> = emptyList()
    ): MONUPlan {
        return MONUPlan(
            id = id,
            goal = goal,
            status = if (steps.isEmpty()) {
                MONUPlanStatus.UNKNOWN
            } else {
                MONUPlanStatus.CREATED
            },
            steps = steps,
            risks = risks,
            source = "LOCAL_ARCHITECTURE"
        )
    }

    fun nextExecutableStep(
        plan: MONUPlan
    ): MONUPlanStep? {
        return plan.steps.firstOrNull { step ->
            step.status == MONUPlanStepStatus.PENDING ||
            step.status == MONUPlanStepStatus.READY
        }
    }

    fun updateStepStatus(
        plan: MONUPlan,
        stepId: String,
        status: MONUPlanStepStatus
    ): MONUPlan {
        val updatedSteps = plan.steps.map { step ->
            if (step.id == stepId) {
                step.copy(status = status)
            } else {
                step
            }
        }

        return plan.copy(steps = updatedSteps)
    }
}
EOF


echo "[6/14] Creating Decision Center screen..."

cat > "$BASE/ui/screens/DecisionCenterScreen.kt" <<'EOF'
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
import com.monu.mobile.domain.model.MONUDecision
import com.monu.mobile.domain.model.MONUDecisionStatus

@Composable
fun DecisionCenterScreen() {

    val decisions = listOf(
        MONUDecision(
            id = "decision_architecture",
            title = "Decision Architecture",
            description = "Real decisions will appear when MONU receives verified decision inputs.",
            status = MONUDecisionStatus.UNKNOWN,
            source = "LOCAL_ARCHITECTURE"
        ),
        MONUDecision(
            id = "decision_truth",
            title = "Decision Transparency",
            description = "Decision options should eventually expose their real factors and sources.",
            status = MONUDecisionStatus.UNKNOWN,
            source = "LOCAL_ARCHITECTURE"
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Decision Center")

        Text(
            "Decision architecture for evaluating options without fabricating conclusions."
        )

        LazyColumn(
            contentPadding = PaddingValues(top = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(decisions) { decision ->
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(decision.title)
                        Text(decision.description)
                        Text("Status: ${decision.status}")
                        Text("Source: ${decision.source}")
                    }
                }
            }
        }
    }
}
EOF


echo "[7/14] Creating Planning Intelligence screen..."

cat > "$BASE/ui/screens/PlanningIntelligenceScreen.kt" <<'EOF'
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
import com.monu.mobile.domain.model.MONUPlan
import com.monu.mobile.domain.model.MONUPlanStatus
import com.monu.mobile.domain.model.MONUPlanStep
import com.monu.mobile.domain.model.MONUPlanStepStatus

@Composable
fun PlanningIntelligenceScreen() {

    val plan = MONUPlan(
        id = "architecture_plan",
        goal = "Future MONU planning pipeline",
        status = MONUPlanStatus.CREATED,
        source = "LOCAL_ARCHITECTURE",
        steps = listOf(
            MONUPlanStep(
                id = "understand",
                title = "Understand Goal",
                description = "Analyze the real command or objective.",
                status = MONUPlanStepStatus.PENDING
            ),
            MONUPlanStep(
                id = "plan",
                title = "Generate Plan",
                description = "Create ordered execution steps.",
                status = MONUPlanStepStatus.PENDING
            ),
            MONUPlanStep(
                id = "verify",
                title = "Verify Result",
                description = "Confirm execution using real evidence.",
                status = MONUPlanStepStatus.PENDING
            )
        )
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {

        Text("MONU Planning Intelligence")
        Text("Goal: ${plan.goal}")
        Text("Plan Status: ${plan.status}")

        LazyColumn(
            contentPadding = PaddingValues(top = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(plan.steps) { step ->
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(step.title)
                        Text(step.description)
                        Text("Status: ${step.status}")
                        Text("Dependencies: ${step.dependencies.size}")
                    }
                }
            }
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

if "DECISION_CENTER" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    DECISION_CENTER,
    PLANNING_INTELLIGENCE,"""
    )

p.write_text(s)
PY


echo "[9/14] Creating Decision Center documentation..."

cat > docs/DECISION_CENTER_ARCHITECTURE.md <<'EOF'
# MONU DECISION CENTER ARCHITECTURE

MONU may eventually evaluate multiple options.

Architecture:

INPUT
↓
CONTEXT
↓
OPTIONS
↓
FACTORS
↓
RISK ANALYSIS
↓
DECISION CANDIDATE
↓
SELECTION
↓
VERIFICATION

Possible factors:

- Benefit
- Risk
- Cost
- Time
- Priority
- Dependencies
- Confidence

Truth Rule:

A selected option is not automatically proof that it is objectively
correct.

Decision confidence and source should eventually be traceable.
EOF


echo "[10/14] Creating Planning Intelligence documentation..."

cat > docs/PLANNING_INTELLIGENCE_ARCHITECTURE.md <<'EOF'
# MONU PLANNING INTELLIGENCE ARCHITECTURE

Planning transforms a goal into structured steps.

Architecture:

COMMAND
↓
GOAL
↓
CONTEXT
↓
PLAN
↓
STEPS
↓
DEPENDENCIES
↓
RISKS
↓
EXECUTION
↓
VERIFICATION

Possible lifecycle:

CREATED
↓
ANALYZING
↓
READY
↓
EXECUTING
↓
COMPLETED

Failure:

FAILED

Truth Rule:

A generated plan is not the same as successful execution.

Step completion must eventually require verified evidence.
EOF


echo "[11/14] Updating project validation..."

python - <<'PY'
from pathlib import Path

p = Path("scripts/validate_project.sh")
s = p.read_text()

new_files = [
    "app/src/main/java/com/monu/mobile/ui/screens/DecisionCenterScreen.kt",
    "app/src/main/java/com/monu/mobile/ui/screens/PlanningIntelligenceScreen.kt",
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

## Level 34
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Decision domain models
- Decision option architecture
- Decision factor models
- Decision status lifecycle
- Decision Center engine
- Decision Center UI

Truth Rule:
A decision must not be presented as objectively verified merely because
an option was selected.

## Level 35
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Planning domain models
- Plan lifecycle
- Plan step architecture
- Dependency models
- Risk models
- Planning Intelligence engine
- Planning Intelligence UI

Truth Rule:
A plan is not falsely presented as completed execution.
EOF


echo "[13/14] Running structural validation..."

./scripts/validate_project.sh


echo "[14/14] Checking Level 34 + 35 files..."

find \
    "$BASE/domain/model" \
    "$BASE/feature/decision" \
    "$BASE/feature/planning" \
    "$BASE/ui/screens" \
    -type f | sort


echo ""
echo "================================================"
echo " LEVEL 34 + LEVEL 35 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW CAPABILITIES:"
echo "✓ Decision Center Architecture"
echo "✓ Decision Option Models"
echo "✓ Decision Factor Models"
echo "✓ Decision Status Lifecycle"
echo "✓ Decision Selection Architecture"
echo ""
echo "✓ Planning Intelligence Architecture"
echo "✓ Goal-to-Step Planning"
echo "✓ Plan Lifecycle"
echo "✓ Dependency Architecture"
echo "✓ Risk Architecture"
echo "✓ Planning Intelligence UI"
echo ""
echo "TRUTH RULE:"
echo "Decisions and plans are not falsely treated as verified execution."
echo ""
echo "IMPORTANT:"
echo "Source creation and structural validation only."
echo "Real Android compilation is still pending."
echo ""
echo "NEXT BUILD LEVEL:"
echo "Level 36 + 37 -> Execution Orchestrator + Verification Engine"
