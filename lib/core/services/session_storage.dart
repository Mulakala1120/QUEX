import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight local session for auth and check-in state.
/// Swap for secure storage / token service when backend is live.
class SessionStorage {
  static const _authKey = 'quex_authenticated';
  static const _phoneKey = 'quex_phone';
  static const _checkInBusinessKey = 'quex_checkin_business';
  static const _checkInEntryKey = 'quex_checkin_entry';
  static const _favoritesKey = 'quex_favorites';

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_authKey) ?? false;
  }

  Future<void> setAuthenticated(bool value, {String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, value);
    if (phone != null) await prefs.setString(_phoneKey, phone);
    if (!value) await prefs.remove(_phoneKey);
  }

  Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  Future<void> saveCheckIn({
    required String businessId,
    required String entryId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkInBusinessKey, businessId);
    await prefs.setString(_checkInEntryKey, entryId);
  }

  Future<({String businessId, String entryId})?> getCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final businessId = prefs.getString(_checkInBusinessKey);
    final entryId = prefs.getString(_checkInEntryKey);
    if (businessId == null || entryId == null) return null;
    return (businessId: businessId, entryId: entryId);
  }

  Future<void> clearCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkInBusinessKey);
    await prefs.remove(_checkInEntryKey);
  }

  Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey)?.toSet() ?? {};
  }

  Future<void> setFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, ids.toList());
  }
}
