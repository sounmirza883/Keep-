/// Minimal fractional indexing over base-36 strings.
///
/// Generates order keys lexicographically between two existing keys so a
/// task can be moved within a Kanban column with a single-row update.
library;

const _digits = '0123456789abcdefghijklmnopqrstuvwxyz';

/// Returns a key strictly between [a] and [b] (lexicographic order).
/// Pass null for [a] to insert at the start, null for [b] for the end.
String generateKeyBetween(String? a, String? b) {
  assert(a == null || b == null || a.compareTo(b) < 0, 'a must sort before b');

  if (a == null && b == null) return 'a0';
  if (a == null) return _before(b!);
  if (b == null) return _after(a);
  return _between(a, b);
}

String _before(String b) {
  // Step the first digit down; prepend a midpoint digit if at the floor.
  final first = _digits.indexOf(b[0]);
  if (first > 0) return _digits[(first / 2).floor()] + (b.length > 1 ? '' : '0');
  return '0${_before(b.substring(1).isEmpty ? '1' : b.substring(1))}';
}

String _after(String a) {
  // Step the last digit up, or extend with a midpoint when at the ceiling.
  final last = _digits.indexOf(a[a.length - 1]);
  if (last < _digits.length - 1) {
    final next = last + ((_digits.length - last) / 2).ceil();
    return a.substring(0, a.length - 1) +
        _digits[next.clamp(last + 1, _digits.length - 1)];
  }
  return '${a}i';
}

String _between(String a, String b) {
  var prefix = '';
  var i = 0;
  while (true) {
    final ca = i < a.length ? _digits.indexOf(a[i]) : 0;
    final cb = i < b.length ? _digits.indexOf(b[i]) : _digits.length;
    if (cb - ca > 1) {
      return prefix + _digits[ca + ((cb - ca) / 2).floor()];
    }
    if (i < a.length) {
      prefix += a[i];
      i++;
    } else {
      // a is a prefix of the gap; descend below b's next digit.
      return prefix + _before(b.substring(i).isEmpty ? '1' : b.substring(i));
    }
  }
}
