import 'package:flutter_test/flutter_test.dart';
import 'package:logic_lab/number_page.dart';

void main() {
  group('Number Reversal Logic Tests', () {
    test('computes reverse difference correctly for 21', () {
      final result = computeReverseDifference(21);
      expect(result.reversed, 12);
      expect(result.difference, 9);
    });

    test('computes reverse difference correctly for 30', () {
      final result = computeReverseDifference(30);
      expect(result.reversed, 3);
      expect(result.difference, 27);
    });

    test('returns 0 difference for palindrome 121', () {
      final result = computeReverseDifference(121);
      expect(result.reversed, 121);
      expect(result.difference, 0);
    });
  });
}

