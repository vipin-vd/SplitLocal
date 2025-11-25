import 'package:intl/intl.dart';
import 'currency.dart';

class CurrencyFormatter {
  // Format with currency symbol
  static String format(double amount, {String currencyCode = 'INR'}) {
    return CurrencyHelper.formatAmount(amount, currencyCode);
  }

  // Format without symbol
  static String formatWithoutSymbol(double amount) {
    return amount.toStringAsFixed(2);
  }

  // Format compact
  static String formatCompact(double amount, {String currencyCode = 'INR'}) {
    final symbol = CurrencyHelper.getSymbol(currencyCode);
    if (amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currencyCode: currencyCode);
  }

  static double parse(String value) {
    // Remove currency symbols and parse
    final cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}

class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}
