class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class CurrencyHelper {
  static const List<Currency> supportedCurrencies = [
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
    Currency(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'),
    Currency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    Currency(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar'),
  ];

  static const String defaultCurrency = 'INR';

  static Currency getCurrency(String code) {
    return supportedCurrencies.firstWhere(
      (currency) => currency.code == code,
      orElse: () => supportedCurrencies.first, // Default to INR
    );
  }

  static String getSymbol(String code) {
    return getCurrency(code).symbol;
  }

  static String formatAmount(double amount, String currencyCode) {
    final currency = getCurrency(currencyCode);
    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }
}
