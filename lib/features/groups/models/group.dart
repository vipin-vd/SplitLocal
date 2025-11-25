import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Group {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final List<String> memberIds; // User IDs

  @HiveField(4)
  final String createdBy; // User ID of device owner

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? updatedAt;

  @HiveField(7)
  @JsonKey(defaultValue: 'INR')
  final String currency; // Currency code (e.g., 'INR', 'USD', 'EUR')

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.currency = 'INR', // Default to Indian Rupee
  });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);

  Group copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? memberIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? currency,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currency: currency ?? this.currency,
    );
  }

  @override
  String toString() => 'Group(id: $id, name: $name, members: ${memberIds.length})';
}
