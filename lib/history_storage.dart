import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists daily history entries in SharedPreferences, encrypted with
/// AES-256-CBC. A fresh random 16-byte IV is generated on every save and
/// prepended to the ciphertext (IV || ciphertext) before base64-encoding.
/// The 32-byte AES key is stored once in FlutterSecureStorage.
class HistoryStorage {
  static const _keyHistory    = 'daily_history';      // legacy plain list (read-only fallback)
  static const _keyHistoryEnc = 'daily_history_enc';  // AES-encrypted blob
  static const _keyEncKey     = 'daily_history_key';  // 32-byte key in SecureStorage
  static const _secure        = FlutterSecureStorage();

  // ── Key management ────────────────────────────────────────────────────────
  Future<enc.Key> _getOrCreateKey() async {
    final existing = await _secure.read(key: _keyEncKey);
    if (existing != null && existing.isNotEmpty) {
      return enc.Key(base64Url.decode(existing));
    }
    final rng   = Random.secure();
    final bytes = Uint8List.fromList(
        List<int>.generate(32, (_) => rng.nextInt(256)));
    await _secure.write(key: _keyEncKey, value: base64UrlEncode(bytes));
    return enc.Key(bytes);
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  /// Encrypts [entries] with AES-256-CBC and writes to SharedPreferences.
  /// Logs and swallows any error so a failed save never crashes the app.
  Future<void> saveHistory(List<Map<String, dynamic>> entries) async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final key       = await _getOrCreateKey();
      final iv        = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(jsonEncode(entries), iv: iv);

      // Store as base64( iv_bytes || cipher_bytes )
      final combined = Uint8List(16 + encrypted.bytes.length)
        ..setRange(0,  16,                          iv.bytes)
        ..setRange(16, 16 + encrypted.bytes.length, encrypted.bytes);

      await prefs.setString(_keyHistoryEnc, base64UrlEncode(combined));
      await prefs.remove(_keyHistory); // remove legacy plaintext key if present
    } catch (e, st) {
      debugPrint('[HistoryStorage] saveHistory error: $e\n$st');
      // Do not rethrow — a failed save should not crash the app.
    }
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  /// Decrypts and returns stored history.
  /// Returns [] on any error so the UI always gets a valid (empty) list.
  Future<List<Map<String, dynamic>>> loadHistory() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final encStr = prefs.getString(_keyHistoryEnc);

      // ── New AES-encrypted format ──
      if (encStr != null && encStr.isNotEmpty) {
        try {
          final key        = await _getOrCreateKey();
          final combined   = base64Url.decode(encStr);
          final iv         = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
          final cipherBytes = Uint8List.fromList(combined.sublist(16));
          final encrypter  = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
          final plain      = encrypter.decrypt(enc.Encrypted(cipherBytes), iv: iv);
          return (jsonDecode(plain) as List<dynamic>).cast<Map<String, dynamic>>();
        } catch (e, st) {
          debugPrint('[HistoryStorage] loadHistory decrypt error: $e\n$st');
          return [];
        }
      }

      // ── Legacy plaintext fallback ──
      try {
        final legacy = prefs.getStringList(_keyHistory) ?? [];
        return legacy
            .map((e) => jsonDecode(e) as Map<String, dynamic>)
            .toList();
      } catch (e, st) {
        debugPrint('[HistoryStorage] loadHistory legacy decode error: $e\n$st');
        return [];
      }
    } catch (e, st) {
      debugPrint('[HistoryStorage] loadHistory error: $e\n$st');
      return [];
    }
  }
}
