package com.slate

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "slate/native_ai"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ai = SlateNativeAI(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAvailable" -> result.success(ai.isAvailable())
                    "summarize" -> {
                        val text = call.argument<String>("text")
                            ?: return@setMethodCallHandler result.error("ARGS", "text required", null)
                        ai.summarize(text, result)
                    }
                    "autoTag" -> {
                        val text = call.argument<String>("text")
                            ?: return@setMethodCallHandler result.error("ARGS", "text required", null)
                        ai.autoTag(text, result)
                    }
                    "smartSearch" -> {
                        val query = call.argument<String>("query")
                        val documents = call.argument<List<String>>("documents")
                        if (query == null || documents == null) {
                            return@setMethodCallHandler result.error(
                                "ARGS", "query and documents required", null
                            )
                        }
                        ai.smartSearch(query, documents, result)
                    }
                    // Apple-only child safety APIs — graceful no-op on Android
                    "getDeclaredAgeRange" -> result.success("unknown")
                    "checkSensitiveContent" -> result.success(false)
                    else -> result.notImplemented()
                }
            }
    }
}
