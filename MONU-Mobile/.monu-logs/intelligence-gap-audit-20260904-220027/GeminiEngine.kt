package com.monu.mobile.feature.gemini

import com.monu.mobile.BuildConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

data class MONUGeminiResult(
    val success: Boolean,
    val text: String,
    val error: String? = null
)

class MONUGeminiIntelligenceEngine {

    private val apiKey: String
        get() = BuildConfig.GEMINI_API_KEY.trim()

    fun isConfigured(): Boolean {
        return apiKey.isNotBlank() &&
            apiKey != "PASTE_YOUR_GEMINI_API_KEY_HERE"
    }

    suspend fun ask(
        prompt: String
    ): MONUGeminiResult = withContext(Dispatchers.IO) {

        val cleanPrompt = prompt.trim()

        if (cleanPrompt.isBlank()) {
            return@withContext MONUGeminiResult(
                success = false,
                text = "",
                error = "Prompt is empty."
            )
        }

        if (!isConfigured()) {
            return@withContext MONUGeminiResult(
                success = false,
                text = "",
                error = "Gemini API key is not configured."
            )
        }

        var connection: HttpURLConnection? = null

        try {
            val url = URL(
                "https://generativelanguage.googleapis.com/" +
                    "v1beta/models/gemini-2.5-flash:generateContent" +
                    "?key=$apiKey"
            )

            connection =
                url.openConnection() as HttpURLConnection

            connection.requestMethod = "POST"
            connection.connectTimeout = 20000
            connection.readTimeout = 30000
            connection.doOutput = true

            connection.setRequestProperty(
                "Content-Type",
                "application/json"
            )

            val body = JSONObject().apply {
                put(
                    "contents",
                    JSONArray().put(
                        JSONObject().apply {
                            put(
                                "parts",
                                JSONArray().put(
                                    JSONObject().apply {
                                        put(
                                            "text",
                                            """
You are MONU, an intelligent assistant.

Give useful, accurate and concise answers.
If you are uncertain, clearly say so.
Do not invent facts.

User request:
$cleanPrompt
                                            """.trimIndent()
                                        )
                                    }
                                )
                            )
                        }
                    )
                )
            }

            connection.outputStream.use {
                it.write(
                    body.toString()
                        .toByteArray(Charsets.UTF_8)
                )
            }

            val code = connection.responseCode

            val stream =
                if (code in 200..299) {
                    connection.inputStream
                } else {
                    connection.errorStream
                }

            val response =
                stream?.bufferedReader()?.use { it.readText() }
                    .orEmpty()

            if (code !in 200..299) {
                return@withContext MONUGeminiResult(
                    success = false,
                    text = "",
                    error =
                        "Gemini HTTP $code: " +
                            response.take(500)
                )
            }

            val json = JSONObject(response)

            val candidates =
                json.optJSONArray("candidates")

            val text =
                candidates
                    ?.optJSONObject(0)
                    ?.optJSONObject("content")
                    ?.optJSONArray("parts")
                    ?.optJSONObject(0)
                    ?.optString("text")
                    .orEmpty()

            if (text.isBlank()) {
                MONUGeminiResult(
                    success = false,
                    text = "",
                    error =
                        "Gemini returned no usable text."
                )
            } else {
                MONUGeminiResult(
                    success = true,
                    text = text
                )
            }

        } catch (error: Exception) {

            MONUGeminiResult(
                success = false,
                text = "",
                error =
                    error.message
                        ?: "Unknown Gemini error."
            )

        } finally {
            connection?.disconnect()
        }
    }
}
