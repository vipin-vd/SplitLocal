// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final typeId = 5;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.general;
      case 1:
        return ExpenseCategory.food;
      case 2:
        return ExpenseCategory.entertainment;
      case 3:
        return ExpenseCategory.transport;
      case 4:
        return ExpenseCategory.utilities;
      case 5:
        return ExpenseCategory.shopping;
      case 6:
        return ExpenseCategory.groceries;
      case 7:
        return ExpenseCategory.rent;
      case 8:
        return ExpenseCategory.healthcare;
      case 9:
        return ExpenseCategory.travel;
      case 10:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.general;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.general:
        writer.writeByte(0);
      case ExpenseCategory.food:
        writer.writeByte(1);
      case ExpenseCategory.entertainment:
        writer.writeByte(2);
      case ExpenseCategory.transport:
        writer.writeByte(3);
      case ExpenseCategory.utilities:
        writer.writeByte(4);
      case ExpenseCategory.shopping:
        writer.writeByte(5);
      case ExpenseCategory.groceries:
        writer.writeByte(6);
      case ExpenseCategory.rent:
        writer.writeByte(7);
      case ExpenseCategory.healthcare:
        writer.writeByte(8);
      case ExpenseCategory.travel:
        writer.writeByte(9);
      case ExpenseCategory.other:
        writer.writeByte(10);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
