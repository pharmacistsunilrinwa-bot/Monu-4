#!/data/data/com.termux/files/usr/bin/bash
set -e

BASE="app/src/main/java/com/monu/mobile"

echo "================================================"
echo " MONU MOBILE - LEVEL 46"
echo " REAL INTERNET KNOWLEDGE FOUNDATION"
echo "================================================"

echo "[1/7] Creating package..."
mkdir -p "$BASE/feature/knowledge"
mkdir -p "$BASE/core/network"

echo "[2/7] Adding network state permission..."
MANIFEST="app/src/main/AndroidManifest.xml"

if ! grep -q 'android.permission.ACCESS_NETWORK_STATE' "$MANIFEST"; then
    sed -i '/<manifest/a\
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />' "$MANIFEST"
fi

echo "[3/7] Creating network state monitor..."

cat > "$BASE/core/network/MONUNetworkMonitor.kt" <<'EOF'
package com.monu.mobile.core.network

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities

class MONUNetworkMonitor(
    private val context: Context
) {
    fun isOnline(): Boolean {
        val connectivityManager =
            context.getSystemService(Context.CONNECTIVITY_SERVICE)
                    as ConnectivityManager

        val network =
            connectivityManager.activeNetwork ?: return false

        val capabilities =
            connectivityManager.getNetworkCapabilities(network)
                ?: return false

        return capabilities.hasCapability(
            NetworkCapabilities.NET_CAPABILITY_INTERNET
        )
    }
}
EOF

echo "[4/7] Creating internet knowledge models..."

cat > "$BASE/domain/model/InternetKnowledgeModels.kt" <<'EOF'
package com.monu.mobile.domain.model

enum class InternetKnowledgeState {
    SUCCESS,
    NOT_FOUND,
    NETWORK_ERROR,
    INVALID_QUERY
}

data class InternetKnowledgeResult(
    val query: String,
    val title: String,
    val summary: String,
    val source: String,
    val state: InternetKnowledgeState,
    val errorMessage: String? = null
)
EOF

echo "[5/7] Creating real internet knowledge engine..."

cat > "$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt" <<'EOF'
package com.monu.mobile.feature.knowledge

import com.monu.mobile.domain.model.InternetKnowledgeResult
import com.monu.mobile.domain.model.InternetKnowledgeState
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.net.URLEncoder
import java.util.concurrent.TimeUnit

class MONUInternetKnowledgeEngine {

    private val client = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(20, TimeUnit.SECONDS)
        .build()

    fun search(query: String): InternetKnowledgeResult {

        val cleanedQuery = query.trim()

        if (cleanedQuery.isBlank()) {
            return InternetKnowledgeResult(
                query = query,
                title = "",
                summary = "",
                source = "Internet",
                state = InternetKnowledgeState.INVALID_QUERY,
                errorMessage = "Query is empty"
            )
        }

        return try {
            val encoded =
                URLEncoder.encode(cleanedQuery, "UTF-8")

            val url =
                "https://en.wikipedia.org/api/rest_v1/page/summary/$encoded"

            val request = Request.Builder()
                .url(url)
                .header(
                    "User-Agent",
                    "MONU-Mobile/1.0"
                )
                .build()

            client.newCall(request).execute().use { response ->

                if (!response.isSuccessful) {
                    return InternetKnowledgeResult(
                        query = cleanedQuery,
                        title = "",
                        summary = "",
                        source = "Wikipedia",
                        state = InternetKnowledgeState.NOT_FOUND,
                        errorMessage =
                            "Internet source returned HTTP ${response.code}"
                    )
                }

                val body =
                    response.body?.string().orEmpty()

                val json = JSONObject(body)

                val title =
                    json.optString("title", cleanedQuery)

                val extract =
                    json.optString("extract", "")

                if (extract.isBlank()) {
                    InternetKnowledgeResult(
                        query = cleanedQuery,
                        title = title,
                        summary = "",
                        source = "Wikipedia",
                        state = InternetKnowledgeState.NOT_FOUND,
                        errorMessage =
                            "No useful knowledge summary found"
                    )
                } else {
                    InternetKnowledgeResult(
                        query = cleanedQuery,
                        title = title,
                        summary = extract,
                        source = "Wikipedia",
                        state = InternetKnowledgeState.SUCCESS
                    )
                }
            }

        } catch (error: Exception) {

            InternetKnowledgeResult(
                query = cleanedQuery,
                title = "",
                summary = "",
                source = "Internet",
                state = InternetKnowledgeState.NETWORK_ERROR,
                errorMessage =
                    error.message ?: "Unknown network error"
            )
        }
    }
}
EOF

echo "[6/7] Checking JSON dependency..."

if grep -Rqs 'org.json.JSONObject' "$BASE/feature/knowledge"; then
    echo "[INFO] Android built-in org.json used"
fi

echo "[7/7] Validation..."

test -f "$BASE/core/network/MONUNetworkMonitor.kt"
test -f "$BASE/domain/model/InternetKnowledgeModels.kt"
test -f "$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt"

grep -q 'ACCESS_NETWORK_STATE' "$MANIFEST"
grep -q 'OkHttpClient' \
"$BASE/feature/knowledge/MONUInternetKnowledgeEngine.kt"

echo ""
echo "================================================"
echo " LEVEL 46 COMPLETE"
echo "================================================"
echo "✓ Internet permission foundation"
echo "✓ Network state capability"
echo "✓ Real HTTP request engine"
echo "✓ Public internet knowledge source"
echo "✓ Error handling"
echo ""
echo "TRUTH RULE:"
echo "Internet response is external information,"
echo "not automatically verified truth."
