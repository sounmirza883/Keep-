import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

@freezed
class Tag with _$Tag {
  const factory Tag({
    required String id,
    required String userId,
    required String name,
    required String colorHex,
    required DateTime createdAt,
  }) = _Tag;

  const Tag._();

  factory Tag.fromRow(Map<String, Object?> row) => Tag(
        id: row['id'] as String,
        userId: row['user_id'] as String? ?? '',
        name: row['name'] as String? ?? '',
        colorHex: row['color_hex'] as String? ?? '#6366f1',
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
