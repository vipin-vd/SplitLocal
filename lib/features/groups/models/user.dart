import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? phoneNumber;

  @HiveField(3)
  final bool isDeviceOwner;

  @HiveField(4)
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.isDeviceOwner = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    bool? isDeviceOwner,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDeviceOwner: isDeviceOwner ?? this.isDeviceOwner,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, phone: $phoneNumber)';
}
