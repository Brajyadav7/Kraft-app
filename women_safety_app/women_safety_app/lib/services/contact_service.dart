import 'package:shared_preferences/shared_preferences.dart';

class ContactService {
  static const _keyPrefix = 'contact_';

  /// Save up to 3 contacts. The list will be truncated/padded to length 3.
  static Future<void> saveContacts(List<String> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 3; i++) {
      final value = (i < contacts.length) ? contacts[i] : '';
      await prefs.setString('$_keyPrefix$i', value);
    }
  }

  /// Load 3 contacts, returns list of length 3 (may contain empty strings)
  static Future<List<String>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> out = [];
    for (int i = 0; i < 3; i++) {
      out.add(prefs.getString('$_keyPrefix$i') ?? '');
    }
    return out;
  }

  /// Get only non-empty contacts
  static Future<List<String>> loadNonEmptyContacts() async {
    final all = await loadContacts();
    return all.where((s) => s.trim().isNotEmpty).toList();
  }
}
