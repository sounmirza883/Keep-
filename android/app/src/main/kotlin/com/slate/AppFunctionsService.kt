package com.slate

import android.content.Context

/**
 * Handles system-level AppFunctions requests (Android 16+): assistants can
 * ask Slate to create a note or task without opening the UI.
 *
 * Writes land in the same PowerSync-backed SQLite database the Flutter
 * layer uses, so they sync like any in-app write. The actual insert is
 * delegated to the Flutter engine via the existing method channel when the
 * app process is alive; a headless engine is spun up otherwise.
 */
class AppFunctionsService(private val context: Context) {

    fun createNote(title: String, content: String?): Boolean {
        return dispatch("createNote", mapOf("title" to title, "content" to (content ?: "")))
    }

    fun createTask(title: String, dueDate: String?, priority: String?): Boolean {
        return dispatch(
            "createTask",
            mapOf("title" to title, "dueDate" to dueDate, "priority" to priority)
        )
    }

    private fun dispatch(method: String, args: Map<String, Any?>): Boolean {
        // Production: obtain a FlutterEngine (cached or headless), then invoke
        // a "slate/app_functions" method channel handled in Dart, which writes
        // through NoteRepository/TaskRepository as usual.
        return false // TODO(native-ai): wire headless engine dispatch
    }
}
