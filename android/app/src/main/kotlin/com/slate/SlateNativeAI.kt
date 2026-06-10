package com.slate

import android.content.Context
import io.flutter.plugin.common.MethodChannel

/**
 * On-device AI bridge for Android via ML Kit GenAI (Gemini Nano through AICore).
 * No network calls allowed here — inference is local only.
 *
 * The ML Kit GenAI dependency (com.google.mlkit:genai) is wired in
 * android/app/build.gradle. On devices without AICore the reflection-based
 * availability check fails closed and every method degrades gracefully.
 */
class SlateNativeAI(private val context: Context) {

    private var inference: Any? = null

    fun isAvailable(): Boolean {
        return try {
            // Resolve ML Kit GenAI via reflection so the app still builds and
            // runs on devices/configs where the optional dependency is absent.
            val optionsClass = Class.forName(
                "com.google.mlkit.genai.inference.LanguageInferenceOptions"
            )
            val builder = optionsClass.getMethod("builder").invoke(null)
            val options = builder.javaClass.getMethod("build").invoke(builder)
            val inferenceClass = Class.forName(
                "com.google.mlkit.genai.inference.LanguageInference"
            )
            val instance = inferenceClass
                .getMethod("create", Context::class.java, optionsClass)
                .invoke(null, context, options)
            instance.javaClass.getMethod("isAvailable").invoke(instance) as? Boolean ?: false
        } catch (e: Throwable) {
            false
        }
    }

    fun summarize(text: String, result: MethodChannel.Result) {
        runPrompt("Summarize in 2-3 sentences: $text", result) { it }
    }

    fun autoTag(text: String, result: MethodChannel.Result) {
        val prompt = """
            Extract 1-5 topic tags from this text.
            Return only a comma-separated list of lowercase tags, no other text.
            Text: $text
        """.trimIndent()
        runPrompt(prompt, result) { raw ->
            raw.split(",").map { it.trim() }.filter { it.isNotEmpty() }
        }
    }

    fun smartSearch(query: String, documents: List<String>, result: MethodChannel.Result) {
        val joined = documents.mapIndexed { i, d -> "[$i]: $d" }.joinToString("\n")
        val prompt = "Given this search query, return the index of the most relevant " +
            "document. Reply with only the number.\nQuery: $query\n\nDocuments:\n$joined"
        runPrompt(prompt, result) { it.trim() }
    }

    private fun runPrompt(
        prompt: String,
        result: MethodChannel.Result,
        transform: (String) -> Any,
    ) {
        if (!isAvailable()) {
            result.error("UNAVAILABLE", "On-device AI is not available", null)
            return
        }
        try {
            // Production path uses LanguageInference.runInference(prompt, callback).
            // Reflection keeps the bridge compilable without the GenAI artifact.
            val inferenceClass = Class.forName(
                "com.google.mlkit.genai.inference.LanguageInference"
            )
            val optionsClass = Class.forName(
                "com.google.mlkit.genai.inference.LanguageInferenceOptions"
            )
            val builder = optionsClass.getMethod("builder").invoke(null)
            val options = builder.javaClass.getMethod("build").invoke(builder)
            val instance = inference ?: inferenceClass
                .getMethod("create", Context::class.java, optionsClass)
                .invoke(null, context, options)
                .also { inference = it }

            val callbackClass = Class.forName(
                "com.google.mlkit.genai.inference.InferenceCallback"
            )
            val proxy = java.lang.reflect.Proxy.newProxyInstance(
                callbackClass.classLoader,
                arrayOf(callbackClass)
            ) { _, method, args ->
                when (method.name) {
                    "onResult" -> result.success(transform(args?.get(0) as? String ?: ""))
                    "onError" -> result.error(
                        "AI_ERROR",
                        (args?.get(0) as? Exception)?.message,
                        null
                    )
                }
                null
            }
            instance.javaClass
                .getMethod("runInference", String::class.java, callbackClass)
                .invoke(instance, prompt, proxy)
        } catch (e: Throwable) {
            result.error("AI_ERROR", e.message, null)
        }
    }
}
