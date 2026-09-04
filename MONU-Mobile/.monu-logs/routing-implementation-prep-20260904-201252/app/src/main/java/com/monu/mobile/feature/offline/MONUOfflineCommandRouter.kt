package com.monu.mobile.feature.offline
import com.monu.mobile.feature.offline.MONUOfflineCommandIntent
import com.monu.mobile.feature.offline.MONUOfflineCommandIntentParser
import com.monu.mobile.feature.offline.MONULocalDeviceCommandEngine

class MONUOfflineCommandRouter : MONUOfflineCommandContract {

    private val intentParser =
        MONUOfflineCommandIntentParser()

    private val localDeviceCommandEngine =
        MONULocalDeviceCommandEngine()


    override fun canHandle(
        request: MONUOfflineCommandRequest
    ): Boolean {
        return canHandle(request.command)
    }

    fun canHandle(command: String): Boolean {
        val intent = intentParser.parse(command)

        return intent != MONUOfflineCommandIntent.UNKNOWN
    }

    fun handle(command: String): String {
        return when (intentParser.parse(command)) {
            MONUOfflineCommandIntent.EMPTY ->
                "Please say or type a command."

            MONUOfflineCommandIntent.GREETING ->
                "Hello. MONU is running locally in offline mode."

            MONUOfflineCommandIntent.HELP ->
                """
                MONU offline commands:
                • hello
                • help
                • status
                • who are you
                • time
                • date
                • device status
                """.trimIndent()

            MONUOfflineCommandIntent.STATUS ->
                "MONU local runtime is ready. Offline command system is active."

            MONUOfflineCommandIntent.IDENTITY ->
                "I am MONU, your personal AI assistant. I can operate with local offline capabilities."

            MONUOfflineCommandIntent.TIME,
            MONUOfflineCommandIntent.DATE,
            MONUOfflineCommandIntent.LOCAL_STATUS ->
                localDeviceCommandEngine.handle(command)

            MONUOfflineCommandIntent.UNKNOWN ->
                "I received your command, but this offline capability is not available yet."
        }
    }

    override fun execute(
        request: MONUOfflineCommandRequest
    ): MONUOfflineCommandResponse {
        val command = request.command
        val intent = intentParser.parse(command)
        val handled = intent != MONUOfflineCommandIntent.UNKNOWN

        return MONUOfflineCommandResponse(
            handled = handled,
            intent = intent,
            response = handle(command)
        )
    }

}
