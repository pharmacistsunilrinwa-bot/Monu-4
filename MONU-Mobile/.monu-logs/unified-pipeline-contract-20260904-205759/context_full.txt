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
