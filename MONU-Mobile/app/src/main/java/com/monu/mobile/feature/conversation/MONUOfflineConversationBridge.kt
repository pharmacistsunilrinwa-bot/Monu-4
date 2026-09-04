package com.monu.mobile.feature.conversation

import com.monu.mobile.feature.offline.MONUOfflineCommandContract
import com.monu.mobile.feature.offline.MONUOfflineCommandRequest
import com.monu.mobile.feature.offline.MONUOfflineCommandResponse
import com.monu.mobile.feature.offline.MONUOfflineCommandRouter

data class MONUConversationExecutionResult(
    val userMessage: MONUConversationMessage,
    val assistantMessage: MONUConversationMessage,
    val commandResponse: MONUOfflineCommandResponse
)

class MONUOfflineConversationBridge(
    private val commandContract: MONUOfflineCommandContract =
        MONUOfflineCommandRouter(),
    private val stateController: MONUConversationStateController =
        MONUConversationStateController()
) {

    fun conversationState(): MONUConversationState {
        return stateController.state()
    }

    fun execute(
        command: String
    ): MONUConversationExecutionResult {

        stateController.beginProcessing()

        return try {

            val userMessage =
                stateController.addUserMessage(
                    content = command
                )

            val response =
                commandContract.execute(
                    MONUOfflineCommandRequest(
                        command = command
                    )
                )

            val assistantMessage =
                stateController.addAssistantMessage(
                    content = response.response
                )

            stateController.finishProcessing()

            MONUConversationExecutionResult(
                userMessage = userMessage,
                assistantMessage = assistantMessage,
                commandResponse = response
            )

        } catch (error: Exception) {

            val safeMessage =
                error.message
                    ?: "MONU could not process the command locally."

            stateController.setError(safeMessage)

            val userMessage =
                stateController.addUserMessage(
                    content = command
                )

            val assistantMessage =
                stateController.addAssistantMessage(
                    content = safeMessage
                )

            MONUConversationExecutionResult(
                userMessage = userMessage,
                assistantMessage = assistantMessage,
                commandResponse =
                    MONUOfflineCommandResponse(
                        handled = false,
                        intent =
                            com.monu.mobile.feature.offline
                                .MONUOfflineCommandIntent.UNKNOWN,
                        response = safeMessage
                    )
            )
        }
    }

    fun clearConversation() {
        stateController.clearConversation()
    }
}
