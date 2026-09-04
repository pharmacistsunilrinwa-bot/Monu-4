package com.monu.mobile.feature.conversation

class MONUConversationPipeline(
    private val bridge: MONUOfflineConversationBridge =
        MONUOfflineConversationBridge()
) {

    fun state(): MONUConversationState {
        return bridge.conversationState()
    }

    fun submit(
        input: String
    ): MONUConversationExecutionResult {

        val cleanInput = input.trim()

        return bridge.execute(cleanInput)
    }

    fun clear() {
        bridge.clearConversation()
    }
}
