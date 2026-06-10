import '../../data/services/native_ai_service.dart';

/// Suggests 1-5 topic tags for note content with on-device AI.
/// Returns an empty list when AI is unavailable or the text is too short.
class AutoTagUseCase {
  AutoTagUseCase(this._ai);

  final NativeAiService _ai;

  static const minLength = 100;
  static const maxTags = 5;

  Future<List<String>> call(String content) async {
    if (content.trim().length < minLength) return [];
    final tags = await _ai.autoTag(content);
    return tags
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .take(maxTags)
        .toList();
  }
}
