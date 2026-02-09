import 'package:flutter/material.dart';

import 'package:splitlocal/shared/utils/currency.dart';

class CurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onChanged;
  final bool isWhite;

  /// Optional list of currency codes to show. If null, all currencies are shown.
  final List<String>? availableCurrencies;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
    this.isWhite = false,
    this.availableCurrencies,
  });

  @override
  Widget build(BuildContext context) {
    // Filter to only available currencies if provided
    final items = availableCurrencies != null
        ? AppCurrency.values
            .where((c) => availableCurrencies!.contains(c.code))
            .toList()
        : AppCurrency.values;

    return PopupMenuButton<String>(
      initialValue: selectedCurrency,
      tooltip: 'Select Currency',
      onSelected: onChanged,
      itemBuilder: (context) {
        return items.map((currency) {
          return PopupMenuItem<String>(
            value: currency.code,
            child: Row(
              children: [
                Text(
                  currency.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text('${currency.name} (${currency.code})'),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isWhite
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyHelper.getSymbol(selectedCurrency),
              style: TextStyle(
                color: isWhite ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              selectedCurrency,
              style: TextStyle(
                color: isWhite ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isWhite ? Colors.white70 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
