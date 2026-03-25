import 'package:hive_ce/hive_ce.dart';

part 'transaction_type.g.dart';

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  expense, // Regular expense split among members

  @HiveField(1)
  payment, // Settlement/payment between members (reduces debt)
}
