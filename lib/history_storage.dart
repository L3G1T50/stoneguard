import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HistoryStorage {
  static const _keyHistory = 'daily_history';
  static const _keyHistoryEnc = 'daily_history_enc';
  static const _keyEncKey = 'daily_history_key';
  static const _secure = FlutterSecureStorage();

  Future<String> _getOrCreateKey() async {
    final existing = await _secure.read(key: _keyEncKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final bytes = List<int>.generate(32, (i) => DateTime.now().millisecondsSinceEpoch % 256);
    final key = base64UrlEncode(bytes);
    await _secure.write(key: _keyEncKey, value: key);
    return key;
  }

  Future<void> saveHistory(List<Map<String, dynamic>> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getOrCreateKey();
    final plain = jsonEncode(entries);
    // Simple XOR + base64 for illustration; replace with real AES in production
    final cipherBytes = List<int>.generate(plain.length, (i) =>
        plain.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    final cipherText = base64UrlEncode(cipherBytes);
    await prefs.setString(_keyHistoryEnc, cipherText);
    await prefs.remove(_keyHistory);
  }

  Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final enc = prefs.getString(_keyHistoryEnc);
    if (enc == null) {
      final legacy = prefs.getStringList(_keyHistory) ?? [];
      return legacy.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    }
    final key = await _getOrCreateKey();
    final cipherBytes = base64Url.decode(enc);
    final plainChars = List<int>.generate(cipherBytes.length, (i) =>
        cipherBytes[i] ^ key.codeUnitAt(i % key.length));
    final plain = String.fromCharCodes(plainChars);
    final list = jsonDecode(plain) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
