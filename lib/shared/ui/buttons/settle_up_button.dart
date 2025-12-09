import 'package:flutter/material.dart';
import 'package:splitlocal/features/expenses/screens/settle_up_screen.dart';

/// A reusable FloatingActionButton for settling up debts in a group.
/// Navigates to the SettleUpScreen with the specified groupId.
class SettleUpButton extends StatelessWidget {
  final String groupId;
  final String? heroTag;
  final Color? backgroundColor;
  final IconData icon;
  final String tooltip;
  final String? prePopulatePayer;
  final String? prePopulateRecipient;
  final double? prePopulateAmount;

  const SettleUpButton({
    super.key,
    required this.groupId,
    this.heroTag,
    this.backgroundColor,
    this.icon = Icons.payments,
    this.tooltip = 'Settle Up',
    this.prePopulatePayer,
    this.prePopulateRecipient,
    this.prePopulateAmount,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SettleUpScreen(
            groupId: groupId,
            prePopulatePayer: prePopulatePayer,
            prePopulateRecipient: prePopulateRecipient,
            prePopulateAmount: prePopulateAmount,
          ),
        ),
      ),
      backgroundColor: backgroundColor ?? Colors.green,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}

/// A compact IconButton variant for inline use (e.g., in list tiles).
class SettleUpIconButton extends StatelessWidget {
  final String groupId;
  final Color? color;
  final double? iconSize;
  final String? prePopulatePayer;
  final String? prePopulateRecipient;
  final double? prePopulateAmount;

  const SettleUpIconButton({
    super.key,
    required this.groupId,
    this.color,
    this.iconSize,
    this.prePopulatePayer,
    this.prePopulateRecipient,
    this.prePopulateAmount,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.payments,
        color: color ?? Colors.green,
        size: iconSize,
      ),
      tooltip: 'Settle Up',
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SettleUpScreen(
            groupId: groupId,
            prePopulatePayer: prePopulatePayer,
            prePopulateRecipient: prePopulateRecipient,
            prePopulateAmount: prePopulateAmount,
          ),
        ),
      ),
    );
  }
}
