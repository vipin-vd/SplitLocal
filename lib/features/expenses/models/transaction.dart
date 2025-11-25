import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'transaction_type.dart';
import 'split_mode.dart';
import 'expense_category.dart';

part 'transaction.g.dart';

@HiveType(typeId: 4)
@JsonSerializable()
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String groupId;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final double totalAmount;

  /// Map of userId -> amount they paid
  /// For expenses: multiple payers possible (e.g., A paid 100, B paid 50)
  /// For payments: single payer (the one giving money)
  @HiveField(5)
  final Map<String, double> payers;

  /// Map of userId -> amount they owe
  /// For expenses: split among participants based on splitMode
  /// For payments: single recipient (the one receiving money)
  @HiveField(6)
  final Map<String, double> splits;

  @HiveField(7)
  final SplitMode splitMode;

  @HiveField(8)
  final DateTime timestamp;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final String createdBy; // User ID

  @HiveField(11)
  final ExpenseCategory category;

  @HiveField(12)
  final String? receiptPath; // Path to receipt image

  @HiveField(13)
  final bool isRecurring;

  @HiveField(14)
  final String? recurringFrequency; // 'daily', 'weekly', 'monthly', 'yearly'

  Transaction({
    required this.id,
    required this.groupId,
    required this.type,
    required this.description,
    required this.totalAmount,
    required this.payers,
    required this.splits,
    required this.splitMode,
    required this.timestamp,
    this.notes,
    required this.createdBy,
    this.category = ExpenseCategory.general,
    this.receiptPath,
    this.isRecurring = false,
    this.recurringFrequency,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction copyWith({
    String? id,
    String? groupId,
    TransactionType? type,
    String? description,
    double? totalAmount,
    Map<String, double>? payers,
    Map<String, double>? splits,
    SplitMode? splitMode,
    DateTime? timestamp,
    String? notes,
    String? createdBy,
    ExpenseCategory? category,
    String? receiptPath,
    bool? isRecurring,
    String? recurringFrequency,
  }) {
    return Transaction(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      payers: payers ?? this.payers,
      splits: splits ?? this.splits,
      splitMode: splitMode ?? this.splitMode,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      category: category ?? this.category,
      receiptPath: receiptPath ?? this.receiptPath,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, type: $type, amount: $totalAmount, desc: $description)';
}
