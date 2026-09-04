package com.monu.mobile.feature.conversation

class MONUChatScreenIntegration(
    private val coordinator: MONUChatCoordinator =
        MONUChatCoordinator()
) {

    fun messages(): List<MONUConversationMessage> {
        return coordinator.state().messages
    }

    fun isProcessing(): Boolean {
        return coordinator.state().isProcessing
    }

    fun submit(
        command: String
    ): MONUChatSubmission {
        return coordinator.submit(command)
    }

    fun clear() {
        coordinator.clearConversation()
    }
}
