// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitModeAdapter extends TypeAdapter<SplitMode> {
  @override
  final typeId = 3;

  @override
  SplitMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SplitMode.equal;
      case 1:
        return SplitMode.unequal;
      case 2:
        return SplitMode.percent;
      case 3:
        return SplitMode.shares;
      default:
        return SplitMode.equal;
    }
  }

  @override
  void write(BinaryWriter writer, SplitMode obj) {
    switch (obj) {
      case SplitMode.equal:
        writer.writeByte(0);
      case SplitMode.unequal:
        writer.writeByte(1);
      case SplitMode.percent:
        writer.writeByte(2);
      case SplitMode.shares:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
