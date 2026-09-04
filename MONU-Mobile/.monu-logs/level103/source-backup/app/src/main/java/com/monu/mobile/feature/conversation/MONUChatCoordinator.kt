package com.monu.mobile.feature.conversation

data class MONUChatSubmission(
    val accepted: Boolean,
    val result: MONUConversationExecutionResult?,
    val state: MONUConversationUiState
)

class MONUChatCoordinator(
    private val adapter: MONUConversationUiAdapter =
        MONUConversationUiAdapter()
) {

    fun state(): MONUConversationUiState {
        return adapter.currentState()
    }

    fun submit(
        input: String
    ): MONUChatSubmission {

        val cleanInput = input.trim()

        if (cleanInput.isBlank()) {
            return MONUChatSubmission(
                accepted = false,
                result = null,
                state = adapter.currentState()
            )
        }

        val result = adapter.submit(cleanInput)

        return MONUChatSubmission(
            accepted = true,
            result = result,
            state = adapter.currentState()
        )
    }

    fun clearConversation() {
        adapter.clear()
    }
}
