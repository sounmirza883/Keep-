import 'package:flutter_test/flutter_test.dart';
import 'package:slate/core/fractional_index.dart';

void main() {
  test('first key with no neighbours', () {
    expect(generateKeyBetween(null, null), 'a0');
  });

  test('key after sorts later', () {
    final key = generateKeyBetween('a0', null);
    expect(key.compareTo('a0'), greaterThan(0));
  });

  test('key before sorts earlier', () {
    final key = generateKeyBetween(null, 'a0');
    expect(key.compareTo('a0'), lessThan(0));
  });

  test('key between two keys sorts between them', () {
    final key = generateKeyBetween('a0', 'a5');
    expect(key.compareTo('a0'), greaterThan(0));
    expect(key.compareTo('a5'), lessThan(0));
  });

  test('repeated appends keep sorting', () {
    var prev = generateKeyBetween(null, null);
    for (var i = 0; i < 50; i++) {
      final next = generateKeyBetween(prev, null);
      expect(next.compareTo(prev), greaterThan(0), reason: 'step $i: $prev -> $next');
      prev = next;
    }
  });

  test('repeated midpoint insertions keep sorting', () {
    var low = 'a0';
    var high = generateKeyBetween(low, null);
    for (var i = 0; i < 20; i++) {
      final mid = generateKeyBetween(low, high);
      expect(mid.compareTo(low), greaterThan(0), reason: 'step $i: $low < $mid');
      expect(mid.compareTo(high), lessThan(0), reason: 'step $i: $mid < $high');
      low = mid;
    }
  });
}
