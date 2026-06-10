import 'package:freezed_annotation/freezed_annotation.dart';

import 'attachment.dart';
import 'tag.dart';

part 'note.freezed.dart';

@freezed
class Note with _$Note {
  const factory Note({
    required String id,
    required String userId,
    required String title,
    required String content,
    required String contentType,
    required bool isPinned,
    required bool isDeleted,
    DateTime? deletedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<Tag> tags,
    @Default([]) List<Attachment> attachments,
    // AI-populated fields (computed at runtime, never persisted)
    String? aiSummary,
    @Default([]) List<String> aiSuggestedTags,
  }) = _Note;

  const Note._();

  factory Note.fromRow(Map<String, Object?> row) => Note(
        id: row['id'] as String,
        userId: row['user_id'] as String? ?? '',
        title: row['title'] as String? ?? '',
        content: row['content'] as String? ?? '',
        contentType: row['content_type'] as String? ?? 'markdown',
        isPinned: (row['is_pinned'] as int? ?? 0) != 0,
        isDeleted: (row['is_deleted'] as int? ?? 0) != 0,
        deletedAt: _parseDate(row['deleted_at']),
        createdAt: _parseDate(row['created_at']) ?? DateTime.now(),
        updatedAt: _parseDate(row['updated_at']) ?? DateTime.now(),
      );
}

DateTime? _parseDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.tryParse(value) : null;
