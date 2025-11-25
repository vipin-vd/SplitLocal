import 'package:flutter_test/flutter_test.dart';
import 'package:splitlocal/features/groups/models/user.dart';

void main() {
  group('User Model', () {
    test('creates user correctly', () {
      final user = User(
        id: '123',
        name: 'John Doe',
        phoneNumber: '+1234567890',
        isDeviceOwner: true,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(user.id, equals('123'));
      expect(user.name, equals('John Doe'));
      expect(user.phoneNumber, equals('+1234567890'));
      expect(user.isDeviceOwner, isTrue);
    });

    test('toJson and fromJson', () {
      final user = User(
        id: '123',
        name: 'Jane Smith',
        phoneNumber: null,
        isDeviceOwner: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();
      expect(json['id'], equals('123'));
      expect(json['name'], equals('Jane Smith'));
      expect(json['phoneNumber'], isNull);
      expect(json['isDeviceOwner'], isFalse);

      final restored = User.fromJson(json);
      expect(restored.id, equals(user.id));
      expect(restored.name, equals(user.name));
      expect(restored.phoneNumber, equals(user.phoneNumber));
      expect(restored.isDeviceOwner, equals(user.isDeviceOwner));
    });

    test('copyWith', () {
      final user = User(
        id: '123',
        name: 'John Doe',
        phoneNumber: '+1234567890',
        isDeviceOwner: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final updated = user.copyWith(name: 'John Smith');

      expect(updated.id, equals(user.id));
      expect(updated.name, equals('John Smith'));
      expect(updated.phoneNumber, equals(user.phoneNumber));
      expect(updated.isDeviceOwner, equals(user.isDeviceOwner));
    });
  });
}
