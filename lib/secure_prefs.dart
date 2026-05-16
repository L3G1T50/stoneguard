// ─── SECURE PREFS ────────────────────────────────────────────────────────────
// AES-256-CBC encrypted wrapper around SharedPreferences.
// Replaces plain-text storage for all sensitive current-day health data:
//   water_*, oxalate_*, oxalate_log_*, goal_water, goal_oxalate,
//   user_name, avatar_path, celebrated_badges, best_streak, and any future PHI keys.
//
// Design mirrors HistoryStorage so only ONE encryption pattern exists in
// this codebase.  The 32-byte AES key is generated once and kept in
// FlutterSecureStorage (Android Keystore / iOS Keychain).
// Every value is stored as  base64( iv_16_bytes || ciphertext ).

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurePrefs {
  // Singleton – one instance for the whole app lifetime.
  static final SecurePrefs instance = SecurePrefs._();
  SecurePrefs._();

  static const _secure    = FlutterSecureStorage();
  static const _keyEncKey = 'secure_prefs_aes_key'; // stored in Keystore/Keychain

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

  // ── Internal encrypt / decrypt ────────────────────────────────────────────
  Future<String> _encrypt(String plainText) async {
    final key       = await _getOrCreateKey();
    final iv        = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final combined = Uint8List(16 + encrypted.bytes.length)
      ..setRange(0,  16,                          iv.bytes)
      ..setRange(16, 16 + encrypted.bytes.length, encrypted.bytes);
    return base64UrlEncode(combined);
  }

  Future<String?> _decrypt(String? encoded) async {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final key         = await _getOrCreateKey();
      final combined    = base64Url.decode(encoded);
      final iv          = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final cipherBytes = Uint8List.fromList(combined.sublist(16));
      final encrypter   = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(enc.Encrypted(cipherBytes), iv: iv);
    } catch (e, st) {
      debugPrint('[SecurePrefs] decrypt error: $e\n$st');
      return null;
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Store an encrypted [double] value.
  Future<void> setDouble(String key, double value) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = await _encrypt(value.toString());
      await prefs.setString('enc_$key', encoded);
    } catch (e, st) {
      debugPrint('[SecurePrefs] setDouble error ($key): $e\n$st');
    }
  }

  /// Read an encrypted [double]. Returns [defaultValue] on any error.
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = prefs.getString('enc_$key');
      final plain   = await _decrypt(encoded);
      if (plain == null) return defaultValue;
      return double.tryParse(plain) ?? defaultValue;
    } catch (e, st) {
      debugPrint('[SecurePrefs] getDouble error ($key): $e\n$st');
      return defaultValue;
    }
  }

  /// Store an encrypted [int] value.
  Future<void> setInt(String key, int value) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = await _encrypt(value.toString());
      await prefs.setString('enc_$key', encoded);
    } catch (e, st) {
      debugPrint('[SecurePrefs] setInt error ($key): $e\n$st');
    }
  }

  /// Read an encrypted [int]. Returns [defaultValue] on any error.
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = prefs.getString('enc_$key');
      final plain   = await _decrypt(encoded);
      if (plain == null) return defaultValue;
      return int.tryParse(plain) ?? defaultValue;
    } catch (e, st) {
      debugPrint('[SecurePrefs] getInt error ($key): $e\n$st');
      return defaultValue;
    }
  }

  /// Store an encrypted [String] value.
  Future<void> setString(String key, String value) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = await _encrypt(value);
      await prefs.setString('enc_$key', encoded);
    } catch (e, st) {
      debugPrint('[SecurePrefs] setString error ($key): $e\n$st');
    }
  }

  /// Read an encrypted [String]. Returns [defaultValue] on any error.
  Future<String> getString(String key, {String defaultValue = ''}) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = prefs.getString('enc_$key');
      final plain   = await _decrypt(encoded);
      return plain ?? defaultValue;
    } catch (e, st) {
      debugPrint('[SecurePrefs] getString error ($key): $e\n$st');
      return defaultValue;
    }
  }

  /// Store an encrypted [List<String>].
  Future<void> setStringList(String key, List<String> value) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = await _encrypt(jsonEncode(value));
      await prefs.setString('enc_$key', encoded);
    } catch (e, st) {
      debugPrint('[SecurePrefs] setStringList error ($key): $e\n$st');
    }
  }

  /// Read an encrypted [List<String>]. Returns [] on any error.
  Future<List<String>> getStringList(String key) async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = prefs.getString('enc_$key');
      final plain   = await _decrypt(encoded);
      if (plain == null) return [];
      return (jsonDecode(plain) as List<dynamic>).cast<String>();
    } catch (e, st) {
      debugPrint('[SecurePrefs] getStringList error ($key): $e\n$st');
      return [];
    }
  }

  /// Remove a single encrypted key.
  Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('enc_$key');
    } catch (e, st) {
      debugPrint('[SecurePrefs] remove error ($key): $e\n$st');
    }
  }
}
