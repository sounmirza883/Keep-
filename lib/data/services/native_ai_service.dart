import 'package:flutter/services.dart';

enum AgeRange { child, teen, adult, unknown }

extension AgeRangeParsing on AgeRange {
  static AgeRange fromString(String? value) {
    switch (value) {
      case 'child':
        return AgeRange.child;
      case 'teen':
        return AgeRange.teen;
      case 'adult':
        return AgeRange.adult;
      default:
        return AgeRange.unknown;
    }
  }
}

/// Wraps the "slate/native_ai" platform channel.
///
/// All AI inference happens on-device. Every method checks availability
/// first and degrades to a no-op result on unsupported hardware.
class NativeAiService {
  static const _channel = MethodChannel('slate/native_ai');

  Future<bool> get isAvailable async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> summarize(String text) async {
    if (!await isAvailable) return null;
    return _channel.invokeMethod<String>('summarize', {'text': text});
  }

  Future<List<String>> autoTag(String text) async {
    if (!await isAvailable) return [];
    final result = await _channel.invokeMethod<List>('autoTag', {'text': text});
    return result?.cast<String>() ?? [];
  }

  Future<String?> smartSearch(String query, List<String> documents) async {
    if (!await isAvailable) return null;
    return _channel.invokeMethod<String>('smartSearch', {
      'query': query,
      'documents': documents,
    });
  }

  /// Child safety (Apple only — no-op on other platforms)
  Future<AgeRange?> getDeclaredAgeRange() async {
    try {
      final result = await _channel.invokeMethod<String>('getDeclaredAgeRange');
      return AgeRangeParsing.fromString(result);
    } catch (_) {
      return null;
    }
  }

  Future<bool> checkSensitiveContent(String text) async {
    try {
      return await _channel.invokeMethod<bool>('checkSensitiveContent', {'text': text}) ?? false;
    } catch (_) {
      return false;
    }
  }
}
