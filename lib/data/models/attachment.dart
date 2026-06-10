import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment.freezed.dart';

@freezed
class Attachment with _$Attachment {
  const factory Attachment({
    required String id,
    required String noteId,
    required String userId,
    required String name,
    required String storagePath,
    required String mimeType,
    required int sizeBytes,
    String? localPath,
    required bool isSynced,
    required DateTime createdAt,
  }) = _Attachment;

  const Attachment._();

  factory Attachment.fromRow(Map<String, Object?> row) => Attachment(
        id: row['id'] as String,
        noteId: row['note_id'] as String? ?? '',
        userId: row['user_id'] as String? ?? '',
        name: row['name'] as String? ?? '',
        storagePath: row['storage_path'] as String? ?? '',
        mimeType: row['mime_type'] as String? ?? '',
        sizeBytes: row['size_bytes'] as int? ?? 0,
        localPath: row['local_path'] as String?,
        isSynced: (row['sync_status'] as int? ?? 0) == 1,
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
