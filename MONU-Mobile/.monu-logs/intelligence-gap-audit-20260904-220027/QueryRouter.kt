package com.monu.mobile.feature.intelligence

import com.monu.mobile.feature.gemini.MONUGeminiIntelligenceEngine
import com.monu.mobile.feature.knowledge.MONUInternetKnowledgeEngine
import com.monu.mobile.feature.knowledge.MONUKnowledgeCenter
import com.monu.mobile.feature.offline.MONUOfflineCommandRouter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

enum class MONUQuerySource {
    OFFLINE,
    INTERNAL_KNOWLEDGE,
    INTELLIGENCE_HUB,
    GEMINI,
    INTERNET,
    FALLBACK
}

data class MONUQueryResponse(
    val source: MONUQuerySource,
    val text: String,
    val success: Boolean
)

class MONUQueryRouter {

    private val offlineRouter =
        MONUOfflineCommandRouter()

    private val knowledgeCenter =
        MONUKnowledgeCenter()

    private val intelligenceHub =
        MONUIntelligenceHub()

    private val gemini =
        MONUGeminiIntelligenceEngine()

    private val internet =
        MONUInternetKnowledgeEngine()

    suspend fun route(
        query: String,
        isOnline: Boolean
    ): MONUQueryResponse = withContext(Dispatchers.IO) {

        val cleanQuery = query.trim()

        if (cleanQuery.isBlank()) {
            return@withContext MONUQueryResponse(
                source = MONUQuerySource.FALLBACK,
                text = "Please enter a valid request.",
                success = false
            )
        }

        if (!isOnline) {
            return@withContext MONUQueryResponse(
                source = MONUQuerySource.OFFLINE,
                text = offlineRouter.handle(cleanQuery),
                success = true
            )
        }

        val lower = cleanQuery.lowercase()

        if (
            lower == "monu health" ||
            lower == "monu intelligence health" ||
            lower == "intelligence status" ||
            lower == "capabilities"
        ) {
            return@withContext MONUQueryResponse(
                source = MONUQuerySource.INTELLIGENCE_HUB,
                text = intelligenceHub.healthReport(),
                success = true
            )
        }

        // Live query routing intentionally does not use demo knowledge.
        // Static/demo knowledge must never masquerade as a real intelligence answer.

        if (gemini.isConfigured()) {
            val geminiResult =
                gemini.ask(cleanQuery)

            if (
                geminiResult.success &&
                geminiResult.text.isNotBlank()
            ) {
                return@withContext MONUQueryResponse(
                    source = MONUQuerySource.GEMINI,
                    text = geminiResult.text,
                    success = true
                )
            }
        }

        val internetResult =
            internet.search(cleanQuery)

        val internetText =
            when (internetResult.state) {
                com.monu.mobile.domain.model.InternetKnowledgeState.SUCCESS -> {
                    buildString {
                        append(internetResult.title)

                        if (internetResult.summary.isNotBlank()) {
                            append("\n\n")
                            append(internetResult.summary)
                        }

                        if (internetResult.source.isNotBlank()) {
                            append("\n\nSource: ")
                            append(internetResult.source)
                        }
                    }
                }

                com.monu.mobile.domain.model.InternetKnowledgeState.NOT_FOUND -> {
                    "I could not find useful internet information."
                }

                com.monu.mobile.domain.model.InternetKnowledgeState.NETWORK_ERROR -> {
                    "Internet search failed: " +
                        (
                            internetResult.errorMessage
                                ?: "Unknown network error."
                        )
                }

                com.monu.mobile.domain.model.InternetKnowledgeState.INVALID_QUERY -> {
                    "Please enter a valid query."
                }
            }

        MONUQueryResponse(
            source = MONUQuerySource.INTERNET,
            text = internetText,
            success =
                internetResult.state ==
                    com.monu.mobile.domain.model.InternetKnowledgeState.SUCCESS
        )
    }
}
