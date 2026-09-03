#!/usr/bin/env bash
set -e

BASE="app/src/main/java/com/monu/mobile"

echo "================================================"
echo " MONU MOBILE - LEVEL 32 + LEVEL 33"
echo " KNOWLEDGE CENTER + CONTEXT INTELLIGENCE"
echo "================================================"

echo "[1/14] Creating package structure..."

mkdir -p \
    "$BASE/domain/model" \
    "$BASE/feature/knowledge" \
    "$BASE/feature/context" \
    "$BASE/ui/screens" \
    docs

echo "[2/14] Creating Knowledge Center models..."

cat > "$BASE/domain/model/KnowledgeModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUKnowledgeSource {
    USER,
    PROJECT,
    DOCUMENT,
    CONVERSATION,
    SERVER,
    SYSTEM,
    UNKNOWN
}

enum class MONUKnowledgeStatus {
    DRAFT,
    ACTIVE,
    ARCHIVED,
    UNKNOWN
}

data class MONUKnowledgeItem(
    val id: String,
    val title: String,
    val content: String,
    val source: MONUKnowledgeSource,
    val status: MONUKnowledgeStatus = MONUKnowledgeStatus.UNKNOWN,
    val tags: List<String> = emptyList(),
    val createdAt: Long? = null,
    val updatedAt: Long? = null
)

data class MONUKnowledgeCollection(
    val id: String,
    val name: String,
    val description: String,
    val itemCount: Int = 0
)
EOF

echo "[3/14] Creating Context Intelligence models..."

cat > "$BASE/domain/model/ContextModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class MONUContextType {
    COMMAND,
    CONVERSATION,
    PROJECT,
    TASK,
    DOCUMENT,
    SESSION,
    SYSTEM,
    UNKNOWN
}

enum class MONUContextStatus {
    AVAILABLE,
    EXPIRED,
    ARCHIVED,
    UNKNOWN
}

data class MONUContextItem(
    val id: String,
    val type: MONUContextType,
    val title: String,
    val summary: String,
    val status: MONUContextStatus = MONUContextStatus.UNKNOWN,
    val priority: Int = 0,
    val timestamp: Long? = null
)

data class MONUContextSnapshot(
    val id: String,
    val title: String,
    val items: List<MONUContextItem> = emptyList(),
    val createdAt: Long? = null
)
EOF

echo "[4/14] Creating Knowledge Center engine..."

cat > "$BASE/feature/knowledge/MONUKnowledgeCenter.kt" <<'EOF'
package com.monu.mobile.feature.knowledge

import com.monu.mobile.domain.model.MONUKnowledgeItem
import com.monu.mobile.domain.model.MONUKnowledgeSource
import com.monu.mobile.domain.model.MONUKnowledgeStatus

class MONUKnowledgeCenter {

    fun demoKnowledge(): List<MONUKnowledgeItem> {
        return listOf(
            MONUKnowledgeItem(
                id = "architecture",
                title = "MONU Mobile Architecture",
                content = "Project architecture knowledge can be indexed here.",
                source = MONUKnowledgeSource.PROJECT,
                status = MONUKnowledgeStatus.UNKNOWN,
                tags = listOf("architecture", "mobile")
            ),
            MONUKnowledgeItem(
                id = "owner_preferences",
                title = "Owner Knowledge",
                content = "Explicitly saved and verified owner preferences may appear here.",
                source = MONUKnowledgeSource.USER,
                status = MONUKnowledgeStatus.UNKNOWN,
                tags = listOf("owner", "preferences")
            )
        )
    }

    fun search(
        query: String,
        items: List<MONUKnowledgeItem>
    ): List<MONUKnowledgeItem> {
        if (query.isBlank()) return items

        return items.filter {
            it.title.contains(query, ignoreCase = true) ||
            it.content.contains(query, ignoreCase = true) ||
            it.tags.any { tag -> tag.contains(query, ignoreCase = true) }
        }
    }
}
EOF

echo "[5/14] Creating Context Intelligence engine..."

cat > "$BASE/feature/context/MONUContextIntelligence.kt" <<'EOF'
package com.monu.mobile.feature.context

import com.monu.mobile.domain.model.MONUContextItem
import com.monu.mobile.domain.model.MONUContextSnapshot
import com.monu.mobile.domain.model.MONUContextStatus
import com.monu.mobile.domain.model.MONUContextType

class MONUContextIntelligence {

    fun demoContext(): List<MONUContextItem> {
        return listOf(
            MONUContextItem(
                id = "project_context",
                type = MONUContextType.PROJECT,
                title = "Current Project Context",
                summary = "Verified project information can be assembled here.",
                status = MONUContextStatus.UNKNOWN,
                priority = 10
            ),
            MONUContextItem(
                id = "command_context",
                type = MONUContextType.COMMAND,
                title = "Recent Command Context",
                summary = "Real command history may later provide contextual continuity.",
                status = MONUContextStatus.UNKNOWN,
                priority = 8
            )
        )
    }

    fun createSnapshot(
        title: String,
        items: List<MONUContextItem>
    ): MONUContextSnapshot {
        return MONUContextSnapshot(
            id = "context_snapshot",
            title = title,
            items = items
        )
    }

    fun prioritize(
        items: List<MONUContextItem>
    ): List<MONUContextItem> {
        return items.sortedByDescending { it.priority }
    }
}
EOF

echo "[6/14] Creating Knowledge Center screen..."

cat > "$BASE/ui/screens/KnowledgeCenterScreen.kt" <<'EOF'
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
import com.monu.mobile.feature.knowledge.MONUKnowledgeCenter

@Composable
fun KnowledgeCenterScreen() {

    val knowledge = MONUKnowledgeCenter().demoKnowledge()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("MONU Knowledge Center")

        Text(
            "Knowledge is designed to originate from real documents, projects, conversations and explicitly stored information."
        )

        LazyColumn(
            contentPadding = PaddingValues(top = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(knowledge) { item ->
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(item.title)
                        Text(item.content)
                        Text("Source: ${item.source}")
                        Text("Status: ${item.status}")
                        Text("Tags: ${item.tags.joinToString()}")
                    }
                }
            }
        }
    }
}
EOF

echo "[7/14] Creating Context Intelligence screen..."

cat > "$BASE/ui/screens/ContextIntelligenceScreen.kt" <<'EOF'
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
import com.monu.mobile.feature.context.MONUContextIntelligence

@Composable
fun ContextIntelligenceScreen() {

    val engine = MONUContextIntelligence()
    val context = engine.prioritize(engine.demoContext())

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text("MONU Context Intelligence")

        Text(
            "Context should be assembled from verified information rather than fabricated assumptions."
        )

        LazyColumn(
            contentPadding = PaddingValues(top = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(context) { item ->
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(item.title)
                        Text(item.summary)
                        Text("Type: ${item.type}")
                        Text("Status: ${item.status}")
                        Text("Priority: ${item.priority}")
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

if "KNOWLEDGE_CENTER" not in s:
    s = s.replace(
        "enum class MONUDestination {",
        """enum class MONUDestination {
    KNOWLEDGE_CENTER,
    CONTEXT_INTELLIGENCE,"""
    )

p.write_text(s)
PY

echo "[9/14] Creating Knowledge Center documentation..."

cat > docs/KNOWLEDGE_CENTER_ARCHITECTURE.md <<'EOF'
# MONU KNOWLEDGE CENTER ARCHITECTURE

MONU Knowledge Center provides an architecture for organizing
verified information.

Possible sources:

- Owner-provided information
- Project information
- Documents
- Conversations
- Server knowledge
- System-generated verified records

Architecture:

SOURCE
↓
VALIDATION
↓
KNOWLEDGE ITEM
↓
TAGGING
↓
INDEX
↓
SEARCH
↓
CONTEXT USE

Future capabilities:

- Persistent knowledge store
- Document indexing
- Semantic search
- Project knowledge graphs
- Knowledge relationships
- Server synchronization

Truth Rule:

Knowledge must identify its source.

Unknown information must not be silently presented as verified fact.
EOF

echo "[10/14] Creating Context Intelligence documentation..."

cat > docs/CONTEXT_INTELLIGENCE_ARCHITECTURE.md <<'EOF'
# MONU CONTEXT INTELLIGENCE ARCHITECTURE

Context Intelligence helps MONU assemble relevant information
for a command or task.

Possible context sources:

COMMAND
↓
CONVERSATION
↓
PROJECT
↓
TASK
↓
DOCUMENT
↓
SESSION
↓
SYSTEM

Architecture:

REAL CONTEXT SOURCES
↓
CONTEXT COLLECTION
↓
VALIDATION
↓
PRIORITIZATION
↓
CONTEXT SNAPSHOT
↓
MONU DECISION SUPPORT

Context priority may consider:

- Relevance
- Recency
- Project relationship
- Task relationship
- Explicit owner selection
- Verified source

Truth Rule:

Missing context remains UNKNOWN.

MONU must not invent previous actions, memories or facts merely
to create an appearance of continuity.
EOF

echo "[11/14] Updating project validation..."

python - <<'PY'
from pathlib import Path

p = Path("scripts/validate_project.sh")
s = p.read_text()

new_files = [
    "app/src/main/java/com/monu/mobile/ui/screens/KnowledgeCenterScreen.kt",
    "app/src/main/java/com/monu/mobile/ui/screens/ContextIntelligenceScreen.kt",
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

## Level 32
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Knowledge domain models
- Knowledge source separation
- Knowledge status lifecycle
- Knowledge collections
- Knowledge search foundation
- Knowledge Center engine
- Knowledge Center UI

Truth Rule:
Knowledge identifies its real source whenever available.

## Level 33
Status: SOURCE CREATED - AWAITS COMPILATION

Added:
- Context domain models
- Context type separation
- Context priority architecture
- Context snapshot architecture
- Context Intelligence engine
- Context Intelligence UI
- Future multi-source context assembly

Truth Rule:
Missing context remains UNKNOWN rather than fabricated.
EOF

echo "[13/14] Running structural validation..."

./scripts/validate_project.sh

echo "[14/14] Checking Level 32 + 33 files..."

find \
    "$BASE/domain/model" \
    "$BASE/feature/knowledge" \
    "$BASE/feature/context" \
    "$BASE/ui/screens" \
    -type f | sort

echo ""
echo "================================================"
echo " LEVEL 32 + LEVEL 33 SOURCE CREATED"
echo "================================================"

echo ""
echo "NEW CAPABILITIES:"
echo "✓ Knowledge Center Architecture"
echo "✓ Knowledge Source Models"
echo "✓ Knowledge Status Lifecycle"
echo "✓ Knowledge Collections"
echo "✓ Knowledge Search Foundation"
echo "✓ Knowledge Center UI"
echo ""
echo "✓ Context Intelligence Architecture"
echo "✓ Multi-Source Context Models"
echo "✓ Context Prioritization"
echo "✓ Context Snapshot Foundation"
echo "✓ Context Intelligence Engine"
echo "✓ Context Intelligence UI"
echo ""
echo "TRUTH RULE:"
echo "Knowledge and context are never fabricated."
echo ""
echo "IMPORTANT:"
echo "Source creation and structural validation only."
echo "Real Android compilation is still pending."
echo ""
echo "NEXT BUILD LEVEL:"
echo "Level 34 + 35 -> Decision Center + Planning Intelligence Architecture"
