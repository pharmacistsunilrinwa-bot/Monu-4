package level81

enum class Intent {
    EMPTY,
    GREETING,
    HELP,
    STATUS,
    IDENTITY,
    TIME,
    DATE,
    LOCAL_STATUS,
    UNKNOWN
}

class FunctionalParser {

    fun parse(command: String): Intent {
        val normalized = command.trim().lowercase()

        return when {
            normalized.isBlank() ->
                Intent.EMPTY

            normalized.contains("hello") ||
                normalized.contains("hi monu") ->
                Intent.GREETING

            normalized.contains("help") ||
                normalized.contains("what can you do") ->
                Intent.HELP

            normalized.contains("who are you") ->
                Intent.IDENTITY

            normalized.contains("device status") ||
                normalized.contains("local status") ->
                Intent.LOCAL_STATUS

            normalized.contains("status") ->
                Intent.STATUS

            normalized.contains("time") ->
                Intent.TIME

            normalized.contains("date") ||
                normalized.contains("today") ->
                Intent.DATE

            else ->
                Intent.UNKNOWN
        }
    }
}

class FunctionalRouter {

    private val parser = FunctionalParser()

    fun canHandle(command: String): Boolean {
        val intent = parser.parse(command)
        return intent != Intent.UNKNOWN
    }

    fun handle(command: String): String {
        return when (parser.parse(command)) {
            Intent.EMPTY ->
                "Please say or type a command."

            Intent.GREETING ->
                "Hello. MONU is running locally in offline mode."

            Intent.HELP ->
                "MONU offline commands available."

            Intent.STATUS ->
                "MONU local runtime is ready."

            Intent.IDENTITY ->
                "I am MONU, your personal AI assistant."

            Intent.TIME ->
                "Current local time is available."

            Intent.DATE ->
                "Today date information is available."

            Intent.LOCAL_STATUS ->
                "Local device runtime status is available."

            Intent.UNKNOWN ->
                "I received your command, but this offline capability is not available yet."
        }
    }
}

fun assertIntent(
    parser: FunctionalParser,
    input: String,
    expected: Intent
): Boolean {
    return parser.parse(input) == expected
}

fun main() {

    val parser = FunctionalParser()
    val router = FunctionalRouter()

    val cases = listOf(
        Triple("", Intent.EMPTY, true),
        Triple("hello", Intent.GREETING, true),
        Triple("hi monu", Intent.GREETING, true),
        Triple("help", Intent.HELP, true),
        Triple("what can you do", Intent.HELP, true),
        Triple("status", Intent.STATUS, true),
        Triple("who are you", Intent.IDENTITY, true),
        Triple("time", Intent.TIME, true),
        Triple("date", Intent.DATE, true),
        Triple("today", Intent.DATE, true),
        Triple("device status", Intent.LOCAL_STATUS, true),
        Triple("local status", Intent.LOCAL_STATUS, true),
        Triple("random unsupported command", Intent.UNKNOWN, false)
    )

    var passed = 0
    var failed = 0

    println("LEVEL 81 FUNCTIONAL CASES")
    println("================================")

    for ((input, expected, shouldHandle) in cases) {

        val actual = parser.parse(input)
        val actualCanHandle = router.canHandle(input)

        val intentOk = actual == expected
        val handleOk = actualCanHandle == shouldHandle

        if (intentOk && handleOk) {
            println(
                "[PASS] input='$input' intent=$actual canHandle=$actualCanHandle"
            )
            passed++
        } else {
            println(
                "[FAIL] input='$input' expectedIntent=$expected " +
                "actualIntent=$actual expectedCanHandle=$shouldHandle " +
                "actualCanHandle=$actualCanHandle"
            )
            failed++
        }
    }

    val greetingResponse = router.handle("hello")
    if (greetingResponse.contains("MONU")) {
        println("[PASS] Greeting execution response")
        passed++
    } else {
        println("[FAIL] Greeting execution response")
        failed++
    }

    val unknownResponse =
        router.handle("completely unsupported xyz command")

    if (unknownResponse.contains("I received your command")) {
        println("[PASS] Unknown command safe response")
        passed++
    } else {
        println("[FAIL] Unknown command safe response")
        failed++
    }

    println("================================")
    println("PASS : $passed")
    println("FAIL : $failed")
    println("================================")

    if (failed > 0) {
        throw IllegalStateException(
            "LEVEL 81 functional harness failed"
        )
    }

    println("LEVEL 81 FUNCTIONAL HARNESS GOLDEN")
}
