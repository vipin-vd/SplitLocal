import 'package:hive/hive.dart';

part 'split_mode.g.dart';

@HiveType(typeId: 3)
enum SplitMode {
  @HiveField(0)
  equal, // Split equally among all participants

  @HiveField(1)
  unequal, // Exact amounts for each person

  @HiveField(2)
  percent, // Percentage-based split

  @HiveField(3)
  shares, // Share-based split (e.g., 1:2:3)
}
