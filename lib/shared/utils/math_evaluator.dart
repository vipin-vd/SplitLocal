/// A safe, lightweight math evaluator using the Shunting Yard algorithm.
/// Evaluates expressions containing numbers, decimals, and basic operators (+, -, *, /).
class MathEvaluator {
  /// Evaluates a math expression safely.
  /// Returns a valid double if successful, or null if the expression is invalid.
  static double? evaluate(String expression) {
    if (expression.isEmpty) return null;

    // Remove all whitespace
    String expr = expression.replaceAll(' ', '');

    // Basic sanitization: allow only numbers, decimals, and plus
    if (!RegExp(r'^[0-9+.]+$').hasMatch(expr)) return null;

    // Handle trailing operators gracefully by stripping them just for evaluation
    if (RegExp(r'[+.]$').hasMatch(expr)) {
      expr = expr.substring(0, expr.length - 1);
    }

    if (expr.isEmpty) return null;

    try {
      return _evaluateExpression(expr);
    } catch (e) {
      return null;
    }
  }

  static double _evaluateExpression(String expr) {
    List<String> tokens = _tokenize(expr);
    List<String> postfix = _infixToPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  static List<String> _tokenize(String expr) {
    List<String> tokens = [];
    StringBuffer numberBuffer = StringBuffer();

    for (int i = 0; i < expr.length; i++) {
      String char = expr[i];

      if (RegExp(r'[0-9.]').hasMatch(char)) {
        numberBuffer.write(char);
      } else {
        if (numberBuffer.isNotEmpty) {
          tokens.add(numberBuffer.toString());
          numberBuffer.clear();
        }
        tokens.add(char);
      }
    }

    if (numberBuffer.isNotEmpty) {
      tokens.add(numberBuffer.toString());
    }

    return tokens;
  }

  static int _precedence(String op) {
    if (op == '+') {
      return 1;
    }
    return 0;
  }

  static List<String> _infixToPostfix(List<String> tokens) {
    List<String> postfix = [];
    List<String> stack = [];

    for (String token in tokens) {
      if (RegExp(r'^[0-9.]+$').hasMatch(token)) {
        postfix.add(token);
      } else if (token == '(') {
        stack.add(token);
      } else if (token == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          postfix.add(stack.removeLast());
        }
        if (stack.isNotEmpty && stack.last == '(') {
          stack.removeLast();
        }
      } else {
        while (
            stack.isNotEmpty && _precedence(stack.last) >= _precedence(token)) {
          postfix.add(stack.removeLast());
        }
        stack.add(token);
      }
    }

    while (stack.isNotEmpty) {
      postfix.add(stack.removeLast());
    }

    return postfix;
  }

  static double _evaluatePostfix(List<String> postfix) {
    List<double> stack = [];

    for (String token in postfix) {
      if (RegExp(r'^[0-9.]+$').hasMatch(token)) {
        stack.add(double.parse(token));
      } else {
        if (stack.length < 2) throw Exception('Invalid expression');
        double b = stack.removeLast();
        double a = stack.removeLast();

        if (token == '+') {
          stack.add(a + b);
        } else {
          throw Exception('Invalid operator');
        }
      }
    }

    if (stack.length != 1) throw Exception('Invalid expression');
    return stack.first;
  }
}
