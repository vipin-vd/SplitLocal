import 'package:flutter/material.dart';
import 'package:splitlocal/shared/utils/formatters.dart';

/// A widget that displays amounts grouped by currency.
///
/// Example output: "₹500 + $50" or "₹716.67" (if single currency)
class MultiCurrencyAmountText extends StatelessWidget {
  const MultiCurrencyAmountText({
    super.key,
    required this.amounts,
    this.style,
    this.positiveColor,
    this.negativeColor,
    this.separator = ' + ',
    this.showSign = false,
  });

  /// Map of currency code to amount (e.g., {'INR': 500.0, 'USD': 50.0})
  final Map<String, double> amounts;

  /// Optional text style
  final TextStyle? style;

  /// Color for positive amounts
  final Color? positiveColor;

  /// Color for negative amounts
  final Color? negativeColor;

  /// Separator between currency amounts (default: ' + ')
  final String separator;

  /// Whether to show +/- sign before amounts
  final bool showSign;

  @override
  Widget build(BuildContext context) {
    if (amounts.isEmpty) {
      return Text(
        CurrencyFormatter.format(0),
        style: style,
      );
    }

    // Filter out zero amounts and sort by currency code
    final nonZeroAmounts = Map.fromEntries(
      amounts.entries.where((e) => e.value.abs() >= 0.01).toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );

    if (nonZeroAmounts.isEmpty) {
      return Text(
        CurrencyFormatter.format(0),
        style: style,
      );
    }

    // If single currency, just show that amount
    if (nonZeroAmounts.length == 1) {
      final entry = nonZeroAmounts.entries.first;
      final amount = entry.value;
      final color = amount > 0 ? positiveColor : negativeColor;
      final prefix = showSign && amount > 0 ? '+' : '';

      return Text(
        '$prefix${CurrencyFormatter.format(amount, currencyCode: entry.key)}',
        style: (style ?? const TextStyle()).copyWith(
          color: color ?? style?.color,
        ),
      );
    }

    // Multiple currencies - build spans
    final spans = <InlineSpan>[];
    var isFirst = true;

    for (final entry in nonZeroAmounts.entries) {
      if (!isFirst) {
        spans.add(
          TextSpan(
            text: separator,
            style: style?.copyWith(color: style?.color?.withValues(alpha: 0.7)),
          ),
        );
      }
      isFirst = false;

      final amount = entry.value;
      final color = amount > 0 ? positiveColor : negativeColor;
      final prefix = showSign && amount > 0 ? '+' : '';

      spans.add(
        TextSpan(
          text:
              '$prefix${CurrencyFormatter.format(amount, currencyCode: entry.key)}',
          style: (style ?? const TextStyle()).copyWith(
            color: color ?? style?.color,
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}

/// Extension to aggregate transaction amounts by currency
extension TransactionCurrencyAggregation on Iterable<Map<String, dynamic>> {
  /// Groups amounts by currency code
  Map<String, double> groupByCurrency({
    required double Function(Map<String, dynamic>) getAmount,
    required String Function(Map<String, dynamic>) getCurrency,
  }) {
    final result = <String, double>{};
    for (final item in this) {
      final currency = getCurrency(item);
      final amount = getAmount(item);
      result[currency] = (result[currency] ?? 0.0) + amount;
    }
    return result;
  }
}
