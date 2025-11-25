import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'expense_category.g.dart';

@HiveType(typeId: 5)
enum ExpenseCategory {
  @HiveField(0)
  general,

  @HiveField(1)
  food,

  @HiveField(2)
  entertainment,

  @HiveField(3)
  transport,

  @HiveField(4)
  utilities,

  @HiveField(5)
  shopping,

  @HiveField(6)
  groceries,

  @HiveField(7)
  rent,

  @HiveField(8)
  healthcare,

  @HiveField(9)
  travel,

  @HiveField(10)
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.general:
        return 'General';
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.general:
        return Icons.receipt;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.utilities:
        return Icons.lightbulb;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.groceries:
        return Icons.shopping_cart;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.healthcare:
        return Icons.medical_services;
      case ExpenseCategory.travel:
        return Icons.flight;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.general:
        return Colors.grey;
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.utilities:
        return Colors.yellow;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.groceries:
        return Colors.green;
      case ExpenseCategory.rent:
        return Colors.brown;
      case ExpenseCategory.healthcare:
        return Colors.red;
      case ExpenseCategory.travel:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.blueGrey;
    }
  }
}
