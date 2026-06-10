import 'package:flutter_test/flutter_test.dart';
import 'package:slate/data/services/native_ai_service.dart';
import 'package:slate/domain/use_cases/auto_tag_use_case.dart';
import 'package:slate/domain/use_cases/summarize_note_use_case.dart';

class FakeAiService implements NativeAiService {
  FakeAiService({this.available = true});

  final bool available;
  String? lastSummarized;

  @override
  Future<bool> get isAvailable async => available;

  @override
  Future<String?> summarize(String text) async {
    if (!available) return null;
    lastSummarized = text;
    return 'summary of ${text.length} chars';
  }

  @override
  Future<List<String>> autoTag(String text) async {
    if (!available) return [];
    return ['  Flutter ', 'NOTES', '', 'sync', 'ai', 'extra1', 'extra2'];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  final longText = 'x' * 200;

  group('SummarizeNoteUseCase', () {
    test('returns summary for long content', () async {
      final useCase = SummarizeNoteUseCase(FakeAiService());
      expect(await useCase(longText), 'summary of 200 chars');
    });

    test('skips short content without calling AI', () async {
      final ai = FakeAiService();
      final useCase = SummarizeNoteUseCase(ai);
      expect(await useCase('short'), isNull);
      expect(ai.lastSummarized, isNull);
    });

    test('returns null when AI unavailable', () async {
      final useCase = SummarizeNoteUseCase(FakeAiService(available: false));
      expect(await useCase(longText), isNull);
    });
  });

  group('AutoTagUseCase', () {
    test('normalizes, filters empties, and caps at 5 tags', () async {
      final useCase = AutoTagUseCase(FakeAiService());
      final tags = await useCase(longText);
      expect(tags, ['flutter', 'notes', 'sync', 'ai', 'extra1']);
    });

    test('skips short content', () async {
      final useCase = AutoTagUseCase(FakeAiService());
      expect(await useCase('short'), isEmpty);
    });

    test('returns empty when AI unavailable', () async {
      final useCase = AutoTagUseCase(FakeAiService(available: false));
      expect(await useCase(longText), isEmpty);
    });
  });
}
