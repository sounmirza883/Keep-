import '../../data/services/native_ai_service.dart';

/// Summarizes note content with on-device AI.
/// Returns null when AI is unavailable or the text is too short to bother.
class SummarizeNoteUseCase {
  SummarizeNoteUseCase(this._ai);

  final NativeAiService _ai;

  static const minLength = 50;

  Future<String?> call(String content) async {
    if (content.trim().length < minLength) return null;
    return _ai.summarize(content);
  }
}
