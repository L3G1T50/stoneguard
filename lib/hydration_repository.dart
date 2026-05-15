// ─── HYDRATION REPOSITORY ────────────────────────────────────────────────────
// Single source of truth for all hydration and oxalate data.
//
// Batch 2 (already merged):
//   Fix 2 — _writeLock mutex serialises all writes.
//   Fix 6 — Input validation guards at every write method.
//
// Batch 3 additions:
//   Fix 3 — All debugPrint calls replaced with AppLogger.error() so release
//            builds produce zero log output (no stack traces, no PHI).
//   Fix 5 — addWater and logFood now return SaveResult<double> instead of a
//            raw double so UI callers can easily detect and surface failures.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_storage.dart';
import 'secure_prefs.dart';
import 'app_logger.dart';

// ─── SaveResult ───────────────────────────────────────────────────────────────
/// Sealed result type returned by write operations.
/// Pattern-match in the UI to decide whether to show a snackbar.
///
/// Example:
///   final result = await HydrationRepository.instance.addWater(8);
///   if (result is SaveFailure) {
///     ScaffoldMessenger.of(context).showSnackBar(
///       const SnackBar(content: Text('Could not save — please try again.')),
///     );
///   }
sealed class SaveResult<T> {
  const SaveResult();
}

final class SaveSuccess<T> extends SaveResult<T> {
  final T value;
  const SaveSuccess(this.value);
}

final class SaveFailure<T> extends SaveResult<T> {
  final String reason;
  const SaveFailure(this.reason);
}

// ─── HydrationSnapshot ────────────────────────────────────────────────────────
class HydrationSnapshot {
  final double waterOz;
  final double oxalateMg;
  final double goalOz;
  final double goalMg;

  const HydrationSnapshot({
    required this.waterOz,
    required this.oxalateMg,
    required this.goalOz,
    required this.goalMg,
  });
}

// ─── HydrationRepository ─────────────────────────────────────────────────────
class HydrationRepository {
  static final HydrationRepository instance = HydrationRepository._();
  HydrationRepository._();

  final HistoryStorage _history = HistoryStorage();
  final SecurePrefs    _secure  = SecurePrefs.instance;

  // ── Write-lock mutex (Fix 2) ──────────────────────────────────────────────
  Future<void> _writeLock = Future.value();

  Future<T> _locked<T>(Future<T> Function() action) {
    final result = _writeLock.then((_) => action());
    _writeLock = result.then((_) {}, onError: (_) {});
    return result;
  }

  // ── Key helpers ───────────────────────────────────────────────────────────
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }

  String get _waterKey   => 'water_${_todayKey()}';
  String get _oxalateKey => 'oxalate_${_todayKey()}';
  String get _oxLogKey   => 'oxalate_log_${_todayKey()}';

  // ── Read ──────────────────────────────────────────────────────────────────
  Future<HydrationSnapshot> readToday() async {
    try {
      return HydrationSnapshot(
        waterOz:   await _secure.getDouble(_waterKey,   defaultValue: 0.0),
        oxalateMg: await _secure.getDouble(_oxalateKey, defaultValue: 0.0),
        goalOz:    await _secure.getDouble('goal_water',   defaultValue: 80.0),
        goalMg:    await _secure.getDouble('goal_oxalate', defaultValue: 200.0),
      );
    } catch (e, st) {
      AppLogger.error('HydrationRepository', 'readToday failed', e, st);
      return const HydrationSnapshot(
          waterOz: 0, oxalateMg: 0, goalOz: 80, goalMg: 200);
    }
  }

  // ── Add water ─────────────────────────────────────────────────────────────
  /// Returns SaveSuccess(newTotal) or SaveFailure(reason).
  /// Fix 2: serialised via _locked().
  /// Fix 3: logging via AppLogger (release = no-op).
  /// Fix 5: SaveResult return type lets UI show a snackbar on failure.
  /// Fix 6: rejects oz <= 0.
  Future<SaveResult<double>> addWater(double oz) {
    if (oz <= 0) {
      AppLogger.debug('HydrationRepository', 'addWater ignored: oz must be > 0');
      return Future.value(const SaveFailure('Invalid amount'));
    }

    return _locked(() async {
      try {
        final current = await _secure.getDouble(_waterKey, defaultValue: 0.0);
        final newVal  = (current + oz).clamp(0.0, double.infinity);
        await _secure.setDouble(_waterKey, newVal);
        await _persistHistory();
        return SaveSuccess(newVal);
      } catch (e, st) {
        AppLogger.error('HydrationRepository', 'addWater failed', e, st);
        return const SaveFailure('Storage error');
      }
    });
  }

  // ── Log food ──────────────────────────────────────────────────────────────
  /// Returns SaveSuccess(newOxalateTotal) or SaveFailure(reason).
  /// Fix 2: serialised via _locked().
  /// Fix 3: logging via AppLogger.
  /// Fix 5: SaveResult return type.
  /// Fix 6: rejects mg <= 0 or empty foodName.
  Future<SaveResult<double>> logFood(double mg, String foodName) {
    if (mg <= 0) {
      AppLogger.debug('HydrationRepository', 'logFood ignored: mg must be > 0');
      return Future.value(const SaveFailure('Invalid amount'));
    }
    if (foodName.trim().isEmpty) {
      AppLogger.debug('HydrationRepository', 'logFood ignored: empty food name');
      return Future.value(const SaveFailure('Food name required'));
    }

    return _locked(() async {
      try {
        final current = await _secure.getDouble(_oxalateKey, defaultValue: 0.0);
        final newVal  = current + mg;

        final log = await _secure.getStringList(_oxLogKey);
        log.add('${foodName.trim()}|$mg');

        await _secure.setDouble(_oxalateKey, newVal);
        await _secure.setStringList(_oxLogKey, log);
        await _persistHistory();
        return SaveSuccess(newVal);
      } catch (e, st) {
        AppLogger.error('HydrationRepository', 'logFood failed', e, st);
        return const SaveFailure('Storage error');
      }
    });
  }

  // ── Save goals ────────────────────────────────────────────────────────────
  /// Fix 2: serialised. Fix 3: AppLogger. Fix 6: clamps to sane ranges.
  Future<void> saveGoals({required double goalOz, required double goalMg}) {
    final safeOz = goalOz.clamp(8.0,   300.0);
    final safeMg = goalMg.clamp(10.0, 2000.0);

    return _locked(() async {
      try {
        await _secure.setDouble('goal_water',   safeOz);
        await _secure.setDouble('goal_oxalate', safeMg);
      } catch (e, st) {
        AppLogger.error('HydrationRepository', 'saveGoals failed', e, st);
      }
    });
  }

  // ── Reset today ───────────────────────────────────────────────────────────
  /// Fix 2: serialised. Fix 3: AppLogger.
  Future<void> resetToday() {
    return _locked(() async {
      try {
        await _secure.setDouble(_waterKey,   0.0);
        await _secure.setDouble(_oxalateKey, 0.0);
        await _secure.setStringList(_oxLogKey, []);
        await _persistHistory();
      } catch (e, st) {
        AppLogger.error('HydrationRepository', 'resetToday failed', e, st);
      }
    });
  }

  // ── Private: push today into HistoryStorage ───────────────────────────────
  Future<void> _persistHistory() async {
    try {
      final waterOz   = await _secure.getDouble(_waterKey,   defaultValue: 0.0);
      final oxalateMg = await _secure.getDouble(_oxalateKey, defaultValue: 0.0);
      final today     = DateTime.now();
      final dateStr   =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      final existing = await _history.loadHistory();
      final filtered = existing.where((e) => e['date'] != dateStr).toList();
      filtered.add({'date': dateStr, 'water_oz': waterOz, 'oxalate_mg': oxalateMg});
      if (filtered.length > 730) filtered.removeAt(0);
      await _history.saveHistory(filtered);
    } catch (e, st) {
      AppLogger.error('HydrationRepository', '_persistHistory failed', e, st);
    }
  }

  // ── Legacy migration helper ───────────────────────────────────────────────
  /// Migrates existing plain-text SharedPreferences into SecurePrefs.
  /// Safe to call on every startup — no-op if nothing to migrate.
  Future<void> migrateLegacyPlainTextPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      Future<void> move(String key, double fallback) async {
        if (prefs.containsKey(key)) {
          await _secure.setDouble(key, prefs.getDouble(key) ?? fallback);
          await prefs.remove(key);
        }
      }

      Future<void> moveList(String key) async {
        if (prefs.containsKey(key)) {
          await _secure.setStringList(key, prefs.getStringList(key) ?? []);
          await prefs.remove(key);
        }
      }

      await move(_waterKey,     0.0);
      await move(_oxalateKey,   0.0);
      await moveList(_oxLogKey);
      await move('goal_water',   80.0);
      await move('goal_oxalate', 200.0);
    } catch (e, st) {
      AppLogger.error('HydrationRepository', 'migration failed', e, st);
    }
  }
}
