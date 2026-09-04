#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"
VOICE_DIR="$BASE/feature/voice"
ENGINE="$VOICE_DIR/MONUVoiceInputEngine.kt"
MANIFEST="app/src/main/AndroidManifest.xml"
BACKUP=".monu-backups/level56"

echo "================================================"
echo " MONU MOBILE - LEVEL 56"
echo " REAL VOICE INPUT / COMMAND PIPELINE"
echo " NO APK BUILD"
echo "================================================"

mkdir -p "$VOICE_DIR" "$BACKUP"

echo "[1/6] Backing up manifest..."
cp "$MANIFEST" "$BACKUP/AndroidManifest.xml.backup"

echo "[2/6] Adding microphone permission safely..."

if grep -q 'android.permission.RECORD_AUDIO' "$MANIFEST"; then
    echo "[OK] RECORD_AUDIO already present"
else
    sed -i '/<application/i\
    <uses-permission android:name="android.permission.RECORD_AUDIO" />' \
    "$MANIFEST"
    echo "[OK] RECORD_AUDIO permission added"
fi

echo "[3/6] Creating real voice input engine..."

cat > "$ENGINE" <<'EOF'
package com.monu.mobile.feature.voice

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer

class MONUVoiceInputEngine(
    context: Context,
    private val onResult: (String) -> Unit,
    private val onError: (String) -> Unit = {}
) : RecognitionListener {

    private val appContext = context.applicationContext

    private var speechRecognizer: SpeechRecognizer? = null

    private var listening = false

    fun isAvailable(): Boolean {
        return SpeechRecognizer.isRecognitionAvailable(appContext)
    }

    fun startListening() {
        if (listening) return

        if (!isAvailable()) {
            onError("Speech recognition is not available on this device.")
            return
        }

        if (speechRecognizer == null) {
            speechRecognizer =
                SpeechRecognizer.createSpeechRecognizer(appContext)

            speechRecognizer?.setRecognitionListener(this)
        }

        val intent = Intent(
            RecognizerIntent.ACTION_RECOGNIZE_SPEECH
        ).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM
            )

            putExtra(
                RecognizerIntent.EXTRA_PARTIAL_RESULTS,
                true
            )
        }

        listening = true

        speechRecognizer?.startListening(intent)
    }

    fun stopListening() {
        listening = false
        speechRecognizer?.stopListening()
    }

    fun shutdown() {
        listening = false
        speechRecognizer?.cancel()
        speechRecognizer?.destroy()
        speechRecognizer = null
    }

    override fun onReadyForSpeech(params: Bundle?) {
        listening = true
    }

    override fun onBeginningOfSpeech() {
        listening = true
    }

    override fun onRmsChanged(rmsdB: Float) = Unit

    override fun onBufferReceived(buffer: ByteArray?) = Unit

    override fun onEndOfSpeech() {
        listening = false
    }

    override fun onError(error: Int) {
        listening = false

        onError(
            when (error) {
                SpeechRecognizer.ERROR_AUDIO ->
                    "Audio recording error."

                SpeechRecognizer.ERROR_CLIENT ->
                    "Speech recognition client error."

                SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS ->
                    "Microphone permission denied."

                SpeechRecognizer.ERROR_NETWORK ->
                    "Speech recognition network error."

                SpeechRecognizer.ERROR_NETWORK_TIMEOUT ->
                    "Speech recognition network timeout."

                SpeechRecognizer.ERROR_NO_MATCH ->
                    "No speech recognized."

                SpeechRecognizer.ERROR_RECOGNIZER_BUSY ->
                    "Speech recognizer is busy."

                SpeechRecognizer.ERROR_SERVER ->
                    "Speech recognition server error."

                SpeechRecognizer.ERROR_SPEECH_TIMEOUT ->
                    "No speech detected."

                else ->
                    "Unknown speech recognition error."
            }
        )
    }

    override fun onResults(results: Bundle?) {
        listening = false

        val matches =
            results?.getStringArrayList(
                SpeechRecognizer.RESULTS_RECOGNITION
            )

        val command =
            matches
                ?.firstOrNull()
                ?.trim()
                .orEmpty()

        if (command.isNotBlank()) {
            onResult(command)
        } else {
            onError("No voice command recognized.")
        }
    }

    override fun onPartialResults(
        partialResults: Bundle?
    ) = Unit

    override fun onEvent(
        eventType: Int,
        params: Bundle?
    ) = Unit
}
EOF

echo "[4/6] Static architecture verification..."

grep -q 'class MONUVoiceInputEngine' "$ENGINE"
grep -q 'SpeechRecognizer' "$ENGINE"
grep -q 'RecognitionListener' "$ENGINE"
grep -q 'RecognizerIntent' "$ENGINE"
grep -q 'fun startListening' "$ENGINE"
grep -q 'fun stopListening' "$ENGINE"
grep -q 'fun shutdown' "$ENGINE"
grep -q 'onResults' "$ENGINE"
grep -q 'RESULTS_RECOGNITION' "$ENGINE"

echo "[OK] Voice recognition engine structure verified"

echo "[5/6] Verifying error safety..."

for ERROR in \
ERROR_AUDIO \
ERROR_CLIENT \
ERROR_INSUFFICIENT_PERMISSIONS \
ERROR_NETWORK \
ERROR_NETWORK_TIMEOUT \
ERROR_NO_MATCH \
ERROR_RECOGNIZER_BUSY \
ERROR_SERVER \
ERROR_SPEECH_TIMEOUT
do
    grep -q "$ERROR" "$ENGINE"
done

echo "[OK] Speech error states handled"

echo "[6/6] Final pipeline verification..."

grep -q 'android.permission.RECORD_AUDIO' "$MANIFEST"

echo
echo "VOICE INPUT FLOW:"
echo
echo "MICROPHONE"
echo "    ↓"
echo "SpeechRecognizer"
echo "    ↓"
echo "RecognitionListener"
echo "    ↓"
echo "MONUVoiceInputEngine"
echo "    ↓"
echo "Recognized Text Command"
echo "    ↓"
echo "onResult(command)"
echo "    ↓"
echo "READY FOR CHAT COMMAND PIPELINE"

echo
echo "================================================"
echo " LEVEL 56 COMPLETE"
echo "================================================"
echo "✓ Real Android SpeechRecognizer added"
echo "✓ RecognitionListener implemented"
echo "✓ Microphone permission configured"
echo "✓ Voice result callback created"
echo "✓ Speech error handling added"
echo "✓ Start / Stop / Shutdown lifecycle added"
echo "✓ No APK build performed"
echo
echo "NEXT: LEVEL 57 - VOICE INPUT -> CHAT COMMAND WIRING"
echo "================================================"
