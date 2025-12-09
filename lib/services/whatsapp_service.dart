import 'package:url_launcher/url_launcher.dart';
import '../features/groups/models/user.dart';
import '../services/debt_calculator_service.dart';

class WhatsAppService {
  final DebtCalculatorService debtCalculator;

  WhatsAppService(this.debtCalculator);

  /// Generate WhatsApp URL for sharing
  Future<bool> shareExpenseSummary({
    required String phoneNumber,
    required String groupName,
    required String message,
  }) async {
    final encodedMessage = Uri.encodeComponent(message);

    // Remove any non-digit characters from phone number
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // WhatsApp URL scheme
    final url = 'https://wa.me/$cleanPhone?text=$encodedMessage';

    return await _launchUrl(url);
  }

  /// Share group balance summary with a member
  Future<bool> shareBalanceReminder({
    required User user,
    required String groupName,
    required double amountOwed,
    required String currency,
  }) async {
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
      throw Exception('User does not have a phone number');
    }

    final message = _generateBalanceReminderMessage(
      userName: user.name,
      groupName: groupName,
      amount: amountOwed,
      currency: currency,
    );

    return await shareExpenseSummary(
      phoneNumber: user.phoneNumber!,
      groupName: groupName,
      message: message,
    );
  }

  /// Share detailed group summary
  Future<bool> shareGroupSummary({
    required String phoneNumber,
    required String groupName,
    required Map<String, User> users,
    required Map<String, double> netBalances,
    required double totalSpend,
    required String currency,
  }) async {
    final message = _generateGroupSummaryMessage(
      groupName: groupName,
      users: users,
      netBalances: netBalances,
      totalSpend: totalSpend,
      currency: currency,
    );

    return await shareExpenseSummary(
      phoneNumber: phoneNumber,
      groupName: groupName,
      message: message,
    );
  }

  /// Generate balance reminder message
  String _generateBalanceReminderMessage({
    required String userName,
    required String groupName,
    required double amount,
    required String currency,
  }) {
    if (amount > 0) {
      return '''
Hi $userName! 👋

This is a friendly reminder about the group "$groupName".

You are owed $currency${amount.toStringAsFixed(2)} in total.

Please check the app for details on who owes you.

Thanks!
''';
    } else if (amount < 0) {
      return '''
Hi $userName! 👋

This is a friendly reminder about the group "$groupName".

You owe $currency${amount.abs().toStringAsFixed(2)} in total.

Please settle up when you get a chance. Check the app for details.

Thanks!
''';
    } else {
      return '''
Hi $userName! 👋

Great news! You're all settled up in the group "$groupName".

Your balance is $currency 0.00.

Thanks for staying on top of it! 😊
''';
    }
  }

  /// Generate group summary message
  String _generateGroupSummaryMessage({
    required String groupName,
    required Map<String, User> users,
    required Map<String, double> netBalances,
    required double totalSpend,
    required String currency,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📊 Group Summary: $groupName');
    buffer.writeln('');
    buffer.writeln(
        'Total Group Spend: $currency${totalSpend.toStringAsFixed(2)}');
    buffer.writeln('');
    buffer.writeln('Balances:');
    buffer.writeln('─────────────');

    netBalances.forEach((userId, balance) {
      final user = users[userId];
      if (user != null) {
        if (balance > 0.01) {
          buffer.writeln(
              '${user.name} is owed $currency${balance.toStringAsFixed(2)}');
        } else if (balance < -0.01) {
          buffer.writeln(
              '${user.name} owes $currency${balance.abs().toStringAsFixed(2)}');
        } else {
          buffer.writeln('${user.name} is settled up ✓');
        }
      }
    });

    buffer.writeln('');
    buffer.writeln('Check the SplitLocal app for detailed breakdown!');

    return buffer.toString();
  }

  /// Generate simplified debts message
  String generateSimplifiedDebtsMessage({
    required String groupName,
    required List<DebtDetail> simplifiedDebts,
    required Map<String, User> users,
    required String currency,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('💰 Settlement Plan: $groupName');
    buffer.writeln('');
    buffer.writeln('To settle all debts, make these transfers:');
    buffer.writeln('─────────────');

    for (final debt in simplifiedDebts) {
      final fromUser = users[debt.fromUserId];
      final toUser = users[debt.toUserId];

      if (fromUser != null && toUser != null) {
        buffer.writeln(
          '${fromUser.name} pays ${toUser.name} $currency${debt.amount.toStringAsFixed(2)}',
        );
      }
    }

    buffer.writeln('');
    buffer.writeln(
        'Once these transfers are made, everyone will be settled up! ✨');

    return buffer.toString();
  }

  /// Launch URL helper
  Future<bool> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not launch WhatsApp');
    }
  }
}
