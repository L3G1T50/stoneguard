// ─── HISTORY STORAGE ─────────────────────────────────────────────────────────
// Persists daily history entries in SharedPreferences, encrypted with
// AES-256-CBC. A fresh random 16-byte IV is generated on every save and
// prepended to the ciphertext (IV || ciphertext) before base64-encoding.
// The 32-byte AES key is stored once in FlutterSecureStorage.
//
// Batch 4 — Fix 4: Decrypt-failure recovery
//   • HistoryStorageError sealed class lets callers pattern-match on the
//     specific failure type (DecryptFailure vs SaveFailure vs LoadFailure).
//   • On DecryptFailure: wipes the corrupted blob AND the orphaned secure key
//     so the next save starts clean. Returns [] so the UI stays alive.
//   • saveHistory now returns SaveResult<void> instead of void so callers
//     know whether the write actually landed.
//   • All debugPrint replaced with AppLogger (release = silent).
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_logger.dart';
import 'hydration_repository.dart'; // re-uses SaveResult / SaveSuccess / SaveFailure

// ─── Error taxonomy ───────────────────────────────────────────────────────────
/// Callers can pattern-match on this to decide whether to show a dialog.
/// Example:
///   final result = await HistoryStorage().loadHistory();
///   if (result is SaveFailure && result.reason.contains('decrypt')) {
///     _showDataResetDialog(context);
///   }
sealed class HistoryStorageError {
  final String message;
  const HistoryStorageError(this.message);
}

/// Key was lost or corrupted — all encrypted history has been wiped and reset.
final class DecryptFailure extends HistoryStorageError {
  const DecryptFailure(super.message);
}

/// A save operation failed (e.g. disk full, serialisation error).
final class HistorySaveFailure extends HistoryStorageError {
  const HistorySaveFailure(super.message);
}

/// A load operation failed for an unexpected reason.
final class HistoryLoadFailure extends HistoryStorageError {
  const HistoryLoadFailure(super.message);
}

// ─── HistoryStorage ────────────────────────────────────────────────────────────
class HistoryStorage {
  static const _keyHistory    = 'daily_history';      // legacy plain list (read-only fallback)
  static const _keyHistoryEnc = 'daily_history_enc';  // AES-encrypted blob
  static const _keyEncKey     = 'daily_history_key';  // 32-byte key in SecureStorage
  static const _secure        = FlutterSecureStorage();

  // Expose the last error so callers can react without exceptions.
  HistoryStorageError? lastError;

  // ── Key management ─────────────────────────────────────────────────────────
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

  // ── Wipe helper (Fix 4) ─────────────────────────────────────────────────────
  /// Called when decryption fails (key was wiped, corrupted, or rotated).
  /// Removes the unreadable cipher blob AND the now-orphaned secure key so
  /// the next [saveHistory] call starts with a clean slate.
  Future<void> _wipeCorruptedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHistoryEnc);
      await _secure.delete(key: _keyEncKey);
      AppLogger.error(
        'HistoryStorage',
        'Decrypt key was lost — history reset. '
        'User will see empty history chart.',
      );
    } catch (e, st) {
      AppLogger.error('HistoryStorage', '_wipeCorruptedData error', e, st);
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  /// Encrypts [entries] with AES-256-CBC and writes to SharedPreferences.
  /// Returns SaveSuccess(null) on success, SaveFailure on any error.
  Future<SaveResult<void>> saveHistory(
      List<Map<String, dynamic>> entries) async {
    try {
      final prefs     = await SharedPreferences.getInstance();
      final key       = await _getOrCreateKey();
      final iv        = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(jsonEncode(entries), iv: iv);

      final combined = Uint8List(16 + encrypted.bytes.length)
        ..setRange(0,  16,                          iv.bytes)
        ..setRange(16, 16 + encrypted.bytes.length, encrypted.bytes);

      await prefs.setString(_keyHistoryEnc, base64UrlEncode(combined));
      await prefs.remove(_keyHistory); // remove legacy plaintext key if present
      lastError = null;
      return const SaveSuccess(null);
    } catch (e, st) {
      AppLogger.error('HistoryStorage', 'saveHistory failed', e, st);
      lastError = HistorySaveFailure(e.toString());
      return SaveFailure(e.toString());
    }
  }

  // ── Load ───────────────────────────────────────────────────────────────────
  /// Decrypts and returns stored history.
  ///
  /// Fix 4 behaviour on decrypt failure:
  ///   1. Calls _wipeCorruptedData() to clear the blob + orphaned key.
  ///   2. Sets lastError = DecryptFailure so the caller can show a dialog.
  ///   3. Returns [] so the rest of the UI keeps running.
  Future<List<Map<String, dynamic>>> loadHistory() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final encStr = prefs.getString(_keyHistoryEnc);

      // ── New AES-encrypted format ──
      if (encStr != null && encStr.isNotEmpty) {
        try {
          final key         = await _getOrCreateKey();
          final combined    = base64Url.decode(encStr);
          final iv          = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
          final cipherBytes = Uint8List.fromList(combined.sublist(16));
          final encrypter   = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
          final plain       = encrypter.decrypt(enc.Encrypted(cipherBytes), iv: iv);
          lastError = null;
          return (jsonDecode(plain) as List<dynamic>)
              .cast<Map<String, dynamic>>();
        } catch (e, st) {
          // ── Fix 4: key-loss / corrupt data recovery ──
          // This branch fires when the key was wiped (app-data clear,
          // OS keystore reset) or the ciphertext is corrupted.
          // We wipe both the blob and the orphaned key so the app
          // does not get stuck in an infinite decrypt-fail loop.
          AppLogger.error(
              'HistoryStorage', 'Decrypt failed — wiping and resetting', e, st);
          await _wipeCorruptedData();
          lastError = const DecryptFailure(
              'History data could not be decrypted and has been reset on this device.');
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
        AppLogger.error('HistoryStorage', 'Legacy decode error', e, st);
        lastError = HistoryLoadFailure(e.toString());
        return [];
      }
    } catch (e, st) {
      AppLogger.error('HistoryStorage', 'loadHistory outer error', e, st);
      lastError = HistoryLoadFailure(e.toString());
      return [];
    }
  }
}
