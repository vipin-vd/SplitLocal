import 'package:flutter_test/flutter_test.dart';
import 'package:splitlocal/shared/utils/math_evaluator.dart';

void main() {
  group('MathEvaluator', () {
    test('evaluates simple addition', () {
      expect(MathEvaluator.evaluate('2+2'), equals(4.0));
      expect(MathEvaluator.evaluate('230+24'), equals(254.0));
    });

    test('ignores trailing operators', () {
      expect(MathEvaluator.evaluate('230+'), equals(230.0));
    });

    test('handles decimals', () {
      expect(MathEvaluator.evaluate('10.5+2.5'), equals(13.0));
    });

    test('rejects invalid characters', () {
      expect(MathEvaluator.evaluate('10+abc'), isNull);
    });

    test('ignores whitespaces', () {
      expect(MathEvaluator.evaluate(' 10 + 20 '), equals(30.0));
    });

    test('handles multiple decimals in one number (returns null)', () {
      expect(MathEvaluator.evaluate('1.2.3+4'), isNull);
    });

    test('handles consecutive operators (returns null)', () {
      expect(MathEvaluator.evaluate('10++20'), isNull);
    });

    test('evaluates single number without operators', () {
      expect(MathEvaluator.evaluate('500'), equals(500.0));
      expect(MathEvaluator.evaluate('500.5'), equals(500.5));
    });

    test('evaluates empty string as null', () {
      expect(MathEvaluator.evaluate(''), isNull);
    });
  });
}
