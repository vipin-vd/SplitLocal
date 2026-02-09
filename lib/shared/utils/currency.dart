// ignore_for_file: constant_identifier_names

enum AppCurrency {
  INR('INR', '₹', 'Indian Rupee'),
  USD('USD', '\$', 'US Dollar'),
  EUR('EUR', '€', 'Euro'),
  GBP('GBP', '£', 'British Pound'),
  JPY('JPY', '¥', 'Japanese Yen'),
  AUD('AUD', 'A\$', 'Australian Dollar'),
  CAD('CAD', 'C\$', 'Canadian Dollar'),
  CHF('CHF', 'Fr', 'Swiss Franc'),
  CNY('CNY', '¥', 'Chinese Yuan'),
  SGD('SGD', 'S\$', 'Singapore Dollar');

  final String code;
  final String symbol;
  final String name;

  const AppCurrency(this.code, this.symbol, this.name);

  static AppCurrency fromCode(String code) {
    return AppCurrency.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppCurrency.INR,
    );
  }
}

class CurrencyHelper {
  static const String defaultCurrency = 'INR';

  static AppCurrency getCurrency(String code) {
    return AppCurrency.fromCode(code);
  }

  static String getSymbol(String code) {
    return getCurrency(code).symbol;
  }

  static String formatAmount(double amount, String currencyCode) {
    final currency = getCurrency(currencyCode);
    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }
}
