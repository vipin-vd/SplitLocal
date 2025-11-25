// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 5;

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
        break;
      case ExpenseCategory.food:
        writer.writeByte(1);
        break;
      case ExpenseCategory.entertainment:
        writer.writeByte(2);
        break;
      case ExpenseCategory.transport:
        writer.writeByte(3);
        break;
      case ExpenseCategory.utilities:
        writer.writeByte(4);
        break;
      case ExpenseCategory.shopping:
        writer.writeByte(5);
        break;
      case ExpenseCategory.groceries:
        writer.writeByte(6);
        break;
      case ExpenseCategory.rent:
        writer.writeByte(7);
        break;
      case ExpenseCategory.healthcare:
        writer.writeByte(8);
        break;
      case ExpenseCategory.travel:
        writer.writeByte(9);
        break;
      case ExpenseCategory.other:
        writer.writeByte(10);
        break;
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
