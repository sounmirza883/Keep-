import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slate/data/services/native_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('slate/native_ai');
  final service = NativeAiService();

  void mockChannel(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('graceful fallback when unavailable', () {
    setUp(() {
      mockChannel((call) async {
        if (call.method == 'isAvailable') return false;
        throw PlatformException(code: 'UNAVAILABLE');
      });
    });

    test('summarize returns null', () async {
      expect(await service.summarize('long text'), isNull);
    });

    test('autoTag returns empty list', () async {
      expect(await service.autoTag('long text'), isEmpty);
    });

    test('smartSearch returns null', () async {
      expect(await service.smartSearch('q', ['a', 'b']), isNull);
    });
  });

  group('channel errors never throw', () {
    setUp(() {
      mockChannel((call) async => throw PlatformException(code: 'BOOM'));
    });

    test('isAvailable returns false', () async {
      expect(await service.isAvailable, false);
    });

    test('getDeclaredAgeRange returns null', () async {
      expect(await service.getDeclaredAgeRange(), isNull);
    });

    test('checkSensitiveContent returns false', () async {
      expect(await service.checkSensitiveContent('text'), false);
    });
  });

  group('when AI is available', () {
    setUp(() {
      mockChannel((call) async {
        switch (call.method) {
          case 'isAvailable':
            return true;
          case 'summarize':
            return 'A summary.';
          case 'autoTag':
            return ['flutter', 'notes'];
          case 'smartSearch':
            return '1';
          case 'getDeclaredAgeRange':
            return 'teen';
          case 'checkSensitiveContent':
            return true;
        }
        return null;
      });
    });

    test('summarize returns the model output', () async {
      expect(await service.summarize('text'), 'A summary.');
    });

    test('autoTag casts result to List<String>', () async {
      expect(await service.autoTag('text'), ['flutter', 'notes']);
    });

    test('getDeclaredAgeRange parses the range', () async {
      expect(await service.getDeclaredAgeRange(), AgeRange.teen);
    });

    test('checkSensitiveContent passes through', () async {
      expect(await service.checkSensitiveContent('text'), true);
    });
  });
}
