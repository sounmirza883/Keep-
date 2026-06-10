import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attachment.dart';

/// Attachment metadata syncs through PowerSync like everything else;
/// the file bytes go straight to Supabase Storage (and a local cache)
/// since binary blobs don't belong in the sync stream.
class AttachmentRepository {
  AttachmentRepository({
    required PowerSyncDatabase db,
    required SupabaseClient supabase,
  })  : _db = db,
        _supabase = supabase;

  final PowerSyncDatabase _db;
  final SupabaseClient _supabase;

  static const _bucket = 'attachments';

  Stream<List<Attachment>> watchForNote(String noteId) {
    return _db
        .watch(
          'SELECT * FROM attachments WHERE note_id = ? ORDER BY created_at ASC',
          parameters: [noteId],
        )
        .map((rows) => rows.map((r) => Attachment.fromRow(r)).toList());
  }

  Future<Attachment> uploadAttachment({
    required String userId,
    required String noteId,
    required String name,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final id = uuid.v4();
    final storagePath = '$userId/$noteId/$id-$name';

    // Cache locally first so the attachment is usable offline immediately.
    final localPath = await _cachePath(storagePath);
    await File(localPath).create(recursive: true);
    await File(localPath).writeAsBytes(bytes);

    var synced = 0;
    try {
      await _supabase.storage.from(_bucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(contentType: mimeType),
          );
      synced = 1;
    } catch (_) {
      // Offline — metadata still syncs via PowerSync; re-upload on demand.
    }

    await _db.execute(
      'INSERT INTO attachments (id, note_id, user_id, name, storage_path, '
      'mime_type, size_bytes, local_path, sync_status, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        id,
        noteId,
        userId,
        name,
        storagePath,
        mimeType,
        bytes.length,
        localPath,
        synced,
        DateTime.now().toUtc().toIso8601String(),
      ],
    );

    final rows = await _db.getAll('SELECT * FROM attachments WHERE id = ?', [id]);
    return Attachment.fromRow(rows.first);
  }

  /// Returns a local file path for the attachment, downloading and caching
  /// it from Supabase Storage when not already cached.
  Future<String?> downloadAttachment(Attachment attachment) async {
    if (attachment.localPath != null && File(attachment.localPath!).existsSync()) {
      return attachment.localPath;
    }
    try {
      final bytes =
          await _supabase.storage.from(_bucket).download(attachment.storagePath);
      final localPath = await _cachePath(attachment.storagePath);
      await File(localPath).create(recursive: true);
      await File(localPath).writeAsBytes(bytes);
      await _db.execute(
        'UPDATE attachments SET local_path = ?, sync_status = 1 WHERE id = ?',
        [localPath, attachment.id],
      );
      return localPath;
    } catch (_) {
      return null; // offline and not cached
    }
  }

  Future<void> deleteAttachment(Attachment attachment) async {
    try {
      await _supabase.storage.from(_bucket).remove([attachment.storagePath]);
    } catch (_) {
      // Offline — storage object becomes orphaned until a cleanup job runs.
    }
    if (attachment.localPath != null) {
      final file = File(attachment.localPath!);
      if (file.existsSync()) await file.delete();
    }
    await _db.execute('DELETE FROM attachments WHERE id = ?', [attachment.id]);
  }

  Future<String> _cachePath(String storagePath) async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, 'attachments', storagePath);
  }
}
