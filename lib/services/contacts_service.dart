import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsService {
  /// Request permission to access contacts
  Future<bool> requestPermission() async {
    return await FlutterContacts.requestPermission(readonly: true);
  }

  /// Pick a contact from device contacts
  /// Returns a map with 'name' and 'phoneNumber' keys
  Future<Map<String, dynamic>?> pickContact() async {
    // Request permission if not granted
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      return null;
    }

    // Pick a contact
    final contact = await FlutterContacts.openExternalPick();
    if (contact == null) {
      return null;
    }

    // Get full contact details
    final fullContact = await FlutterContacts.getContact(contact.id);
    if (fullContact == null) {
      return null;
    }

    // Extract name and phone
    final name = fullContact.displayName;
    final phoneNumber =
        fullContact.phones.isNotEmpty ? fullContact.phones.first.number : null;

    return {
      'name': name,
      'phoneNumber': phoneNumber, // Primary/First
      'phoneNumbers': fullContact.phones.map((p) => p.number).toList(),
      'primaryPhoneNumber': fullContact.phones.isNotEmpty
          ? fullContact.phones.first.number
          : null,
    };
  }

  /// Search contacts by name
  Future<List<Contact>> searchContacts(String query) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      return [];
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    if (query.isEmpty) {
      return contacts;
    }

    return contacts.where((contact) {
      return contact.displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Get all contacts
  Future<List<Contact>> getAllContacts() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      return [];
    }

    return await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );
  }
}
