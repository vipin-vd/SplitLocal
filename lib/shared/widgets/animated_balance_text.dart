import 'package:flutter/material.dart';
import 'package:splitlocal/shared/utils/formatters.dart';

/// A widget that animates a balance amount from 0 to the target value.
///
/// Uses [TweenAnimationBuilder] for smooth counting animation with
/// an ease-out curve for natural-feeling deceleration.
class AnimatedBalanceText extends StatelessWidget {
  const AnimatedBalanceText({
    super.key,
    required this.amount,
    required this.color,
    this.currencyCode = 'INR',
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  /// The target amount to animate to
  final double amount;

  /// The color of the text
  final Color color;

  /// Currency code for formatting (default: INR)
  final String currencyCode;

  /// Optional text style (will be merged with color)
  final TextStyle? style;

  /// Animation duration
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('balance_$amount'),
      tween: Tween<double>(begin: 0, end: amount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          CurrencyFormatter.format(animatedValue, currencyCode: currencyCode),
          style: (style ?? const TextStyle()).copyWith(color: color),
        );
      },
    );
  }
}
