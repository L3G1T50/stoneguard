import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
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
  // Returns the base64url-encoded 32-byte AES key, creating it on first run.
  // Random.secure() uses the platform CSPRNG (/dev/urandom on Android).
  Future<enc.Key> _getOrCreateKey() async {
    final existing = await _secure.read(key: _keyEncKey);
    if (existing != null && existing.isNotEmpty) {
      return enc.Key(base64Url.decode(existing));
    }

    final rng   = Random.secure();
    final bytes = Uint8List.fromList(List<int>.generate(32, (_) => rng.nextInt(256)));
    await _secure.write(key: _keyEncKey, value: base64UrlEncode(bytes));
    return enc.Key(bytes);
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> saveHistory(List<Map<String, dynamic>> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final key   = await _getOrCreateKey();

    // Fresh random IV on every save so identical data never yields the
    // same ciphertext (semantic security).
    final iv        = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(jsonEncode(entries), iv: iv);

    // Store as base64( iv_bytes || cipher_bytes )
    final combined = Uint8List(16 + encrypted.bytes.length)
      ..setRange(0,  16,                    iv.bytes)
      ..setRange(16, 16 + encrypted.bytes.length, encrypted.bytes);

    await prefs.setString(_keyHistoryEnc, base64UrlEncode(combined));
    await prefs.remove(_keyHistory); // remove legacy plaintext key if present
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    // ── New encrypted format ──
    final encStr = prefs.getString(_keyHistoryEnc);
    if (encStr != null && encStr.isNotEmpty) {
      final key      = await _getOrCreateKey();
      final combined = base64Url.decode(encStr);

      // Split IV (first 16 bytes) from ciphertext (rest)
      final iv         = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final cipherBytes = Uint8List.fromList(combined.sublist(16));

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final plain     = encrypter.decrypt(
        enc.Encrypted(cipherBytes),
        iv: iv,
      );

      final list = jsonDecode(plain) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }

    // ── Legacy plaintext fallback (users upgrading from older builds) ──
    final legacy = prefs.getStringList(_keyHistory) ?? [];
    return legacy
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }
}
