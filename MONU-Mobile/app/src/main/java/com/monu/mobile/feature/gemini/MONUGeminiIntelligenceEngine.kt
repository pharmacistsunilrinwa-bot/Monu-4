package com.monu.mobile.feature.gemini

import com.monu.mobile.BuildConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.nio.charset.StandardCharsets

data class MONUGeminiResult(
    val success: Boolean,
    val text: String = "",
    val model: String = "",
    val error: String = ""
)

class MONUGeminiIntelligenceEngine {

    private val apiKey: String
        get() = BuildConfig.GEMINI_API_KEY.trim()

    /*
     * Fast/lightweight models are intentionally first.
     * Heavier models are fallback options.
     *
     * The engine never stops after one model failure.
     */
    private val models = listOf(
        "gemini-3.1-flash-lite",
        "gemini-3.5-flash",
        "gemini-3-flash-preview",
        "gemini-2.5-flash",
        "gemini-2.5-pro",
        "gemini-3.1-pro-preview",
        "gemma-4-26b-a4b-it",
        "gemma-4-31b-it"
    )

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
                error = "Empty prompt."
            )
        }

        if (!isConfigured()) {
            return@withContext MONUGeminiResult(
                success = false,
                error = "Gemini API key is not configured."
            )
        }

        var lastError = "No Gemini model was available."

        for (model in models) {

            val result = askModel(
                model = model,
                prompt = cleanPrompt
            )

            if (result.success && result.text.isNotBlank()) {
                return@withContext result
            }

            if (result.error.isNotBlank()) {
                lastError = "$model: ${result.error}"
            }
        }

        MONUGeminiResult(
            success = false,
            error = lastError
        )
    }

    private fun askModel(
        model: String,
        prompt: String
    ): MONUGeminiResult {

        var connection: HttpURLConnection? = null

        return try {

            val encodedKey = URLEncoder.encode(
                apiKey,
                StandardCharsets.UTF_8.toString()
            )

            val endpoint =
                "https://generativelanguage.googleapis.com/" +
                    "v1beta/models/$model:generateContent?key=$encodedKey"

            connection =
                (URL(endpoint).openConnection() as HttpURLConnection).apply {
                    requestMethod = "POST"
                    connectTimeout = 15000
                    readTimeout = 30000
                    doOutput = true
                    setRequestProperty(
                        "Content-Type",
                        "application/json; charset=utf-8"
                    )
                }

            val requestJson = JSONObject().apply {
                put(
                    "contents",
                    JSONArray().put(
                        JSONObject().apply {
                            put(
                                "parts",
                                JSONArray().put(
                                    JSONObject().put(
                                        "text",
                                        prompt
                                    )
                                )
                            )
                        }
                    )
                )
            }

            connection.outputStream.use { output ->
                output.write(
                    requestJson
                        .toString()
                        .toByteArray(StandardCharsets.UTF_8)
                )
            }

            val code = connection.responseCode

            val stream =
                if (code in 200..299) {
                    connection.inputStream
                } else {
                    connection.errorStream
                }

            val body =
                stream?.use {
                    BufferedReader(
                        InputStreamReader(
                            it,
                            StandardCharsets.UTF_8
                        )
                    ).readText()
                }.orEmpty()

            if (code !in 200..299) {
                return MONUGeminiResult(
                    success = false,
                    model = model,
                    error = "HTTP $code"
                )
            }

            val json = JSONObject(body)

            val candidates =
                json.optJSONArray("candidates")

            if (candidates == null || candidates.length() == 0) {
                return MONUGeminiResult(
                    success = false,
                    model = model,
                    error = "No candidates returned."
                )
            }

            val content =
                candidates
                    .optJSONObject(0)
                    ?.optJSONObject("content")

            val parts =
                content?.optJSONArray("parts")

            val text =
                buildString {
                    if (parts != null) {
                        for (i in 0 until parts.length()) {
                            val part =
                                parts.optJSONObject(i)

                            val value =
                                part?.optString("text")
                                    ?.trim()
                                    .orEmpty()

                            if (value.isNotBlank()) {
                                if (isNotEmpty()) append("\n")
                                append(value)
                            }
                        }
                    }
                }.trim()

            if (text.isBlank()) {
                MONUGeminiResult(
                    success = false,
                    model = model,
                    error = "Gemini returned no usable text."
                )
            } else {
                MONUGeminiResult(
                    success = true,
                    text = text,
                    model = model
                )
            }

        } catch (error: Exception) {

            MONUGeminiResult(
                success = false,
                model = model,
                error =
                    error.message
                        ?: error.javaClass.simpleName
            )

        } finally {

            connection?.disconnect()

        }
    }
}
