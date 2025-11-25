// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 4;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      groupId: fields[1] as String,
      type: fields[2] as TransactionType,
      description: fields[3] as String,
      totalAmount: fields[4] as double,
      payers: (fields[5] as Map).cast<String, double>(),
      splits: (fields[6] as Map).cast<String, double>(),
      splitMode: fields[7] as SplitMode,
      timestamp: fields[8] as DateTime,
      notes: fields[9] as String?,
      createdBy: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.groupId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.totalAmount)
      ..writeByte(5)
      ..write(obj.payers)
      ..writeByte(6)
      ..write(obj.splits)
      ..writeByte(7)
      ..write(obj.splitMode)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      description: json['description'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      payers: (json['payers'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      splits: (json['splits'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      splitMode: $enumDecode(_$SplitModeEnumMap, json['splitMode']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'totalAmount': instance.totalAmount,
      'payers': instance.payers,
      'splits': instance.splits,
      'splitMode': _$SplitModeEnumMap[instance.splitMode]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'notes': instance.notes,
      'createdBy': instance.createdBy,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.payment: 'payment',
};

const _$SplitModeEnumMap = {
  SplitMode.equal: 'equal',
  SplitMode.unequal: 'unequal',
  SplitMode.percent: 'percent',
  SplitMode.shares: 'shares',
};
