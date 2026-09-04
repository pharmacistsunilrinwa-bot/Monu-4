package com.monu.mobile.feature.conversation

data class MONUConversationUiState(
    val messages: List<MONUConversationMessage> = emptyList(),
    val isProcessing: Boolean = false,
    val errorMessage: String? = null
)

class MONUConversationUiAdapter(
    private val pipeline: MONUConversationPipeline =
        MONUConversationPipeline()
) {

    fun currentState(): MONUConversationUiState {
        val state = pipeline.state()

        return MONUConversationUiState(
            messages = state.messages,
            isProcessing = state.isProcessing,
            errorMessage = state.lastError
        )
    }

    fun submit(
        input: String
    ): MONUConversationExecutionResult {
        return pipeline.submit(input)
    }

    fun clear() {
        pipeline.clear()
    }
}
