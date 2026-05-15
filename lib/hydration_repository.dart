// ─── HYDRATION REPOSITORY ────────────────────────────────────────────────────
// Single source of truth for all hydration and oxalate data.
// All current-day values (water_*, oxalate_*, oxalate_log_*, goal_*) are
// stored via SecurePrefs (AES-256-CBC) instead of plain SharedPreferences.
//
// Batch 2 additions:
//   Fix 2 — _writeLock mutex serialises all writes so rapid taps never
//            cause a double-write / lost-update race condition.
//   Fix 6 — Input validation guards at the top of every write method.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_storage.dart';
import 'secure_prefs.dart';

/// Holds the current day's hydration snapshot.
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

class HydrationRepository {
  // Singleton — one instance for the whole app lifetime.
  static final HydrationRepository instance = HydrationRepository._();
  HydrationRepository._();

  final HistoryStorage _history = HistoryStorage();
  final SecurePrefs    _secure  = SecurePrefs.instance;

  // ── Write-lock mutex (Fix 2) ───────────────────────────────────────────────
  // All write operations chain onto this Future so they are serialised.
  // Example: if the user taps +8 oz twice very fast, the second call waits
  // for the first to finish before reading the current value — preventing
  // a lost-update where both reads see the same stale number.
  Future<void> _writeLock = Future.value();

  Future<T> _locked<T>(Future<T> Function() action) {
    final result = _writeLock.then((_) => action());
    // Swallow errors on the lock chain so one failure doesn't block all
    // future writes.  The action itself still returns -1 / rethrows.
    _writeLock = result.then((_) {}, onError: (_) {});
    return result;
  }

  // ── Key helpers ────────────────────────────────────────────────────────────
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }

  String get _waterKey   => 'water_${_todayKey()}';
  String get _oxalateKey => 'oxalate_${_todayKey()}';
  String get _oxLogKey   => 'oxalate_log_${_todayKey()}';

  // ── Read ───────────────────────────────────────────────────────────────────
  /// Returns the full hydration snapshot for today.
  /// Reads are not locked — they are always safe to run concurrently.
  Future<HydrationSnapshot> readToday() async {
    try {
      return HydrationSnapshot(
        waterOz:   await _secure.getDouble(_waterKey,   defaultValue: 0.0),
        oxalateMg: await _secure.getDouble(_oxalateKey, defaultValue: 0.0),
        goalOz:    await _secure.getDouble('goal_water',   defaultValue: 80.0),
        goalMg:    await _secure.getDouble('goal_oxalate', defaultValue: 200.0),
      );
    } catch (e, st) {
      debugPrint('[HydrationRepository] readToday error: $e\n$st');
      return const HydrationSnapshot(
          waterOz: 0, oxalateMg: 0, goalOz: 80, goalMg: 200);
    }
  }

  // ── Add water ──────────────────────────────────────────────────────────────
  /// Adds [oz] ounces to today's water total and persists to history.
  /// Returns the new running total, or -1 on failure / invalid input.
  ///
  /// Fix 2: runs inside _locked() so rapid taps are serialised.
  /// Fix 6: rejects oz <= 0.
  Future<double> addWater(double oz) {
    // Validation (Fix 6)
    if (oz <= 0) {
      debugPrint('[HydrationRepository] addWater ignored: oz must be > 0 (got $oz)');
      return Future.value(-1);
    }

    return _locked(() async {
      try {
        final current = await _secure.getDouble(_waterKey, defaultValue: 0.0);
        final newVal  = (current + oz).clamp(0.0, double.infinity);
        await _secure.setDouble(_waterKey, newVal);
        await _persistHistory();
        return newVal;
      } catch (e, st) {
        debugPrint('[HydrationRepository] addWater error: $e\n$st');
        return -1.0;
      }
    });
  }

  // ── Log food ───────────────────────────────────────────────────────────────
  /// Records [mg] oxalate from [foodName] and adds it to today's running
  /// total. Returns the new oxalate total, or -1 on failure / invalid input.
  ///
  /// Fix 2: runs inside _locked() so concurrent food-log taps are serialised.
  /// Fix 6: rejects mg <= 0 or an empty foodName.
  Future<double> logFood(double mg, String foodName) {
    // Validation (Fix 6)
    if (mg <= 0) {
      debugPrint('[HydrationRepository] logFood ignored: mg must be > 0 (got $mg)');
      return Future.value(-1);
    }
    if (foodName.trim().isEmpty) {
      debugPrint('[HydrationRepository] logFood ignored: foodName must not be empty');
      return Future.value(-1);
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
        return newVal;
      } catch (e, st) {
        debugPrint('[HydrationRepository] logFood error: $e\n$st');
        return -1.0;
      }
    });
  }

  // ── Save goals ─────────────────────────────────────────────────────────────
  /// Persists the user's daily water and oxalate goals (encrypted).
  ///
  /// Fix 2: runs inside _locked().
  /// Fix 6: clamps goalOz to 8–300 oz and goalMg to 10–2000 mg so no
  ///        nonsensical goal value can ever reach storage.
  Future<void> saveGoals({required double goalOz, required double goalMg}) {
    // Clamp to sane physiological ranges (Fix 6)
    final safeOz = goalOz.clamp(8.0,   300.0);
    final safeMg = goalMg.clamp(10.0, 2000.0);

    return _locked(() async {
      try {
        await _secure.setDouble('goal_water',   safeOz);
        await _secure.setDouble('goal_oxalate', safeMg);
      } catch (e, st) {
        debugPrint('[HydrationRepository] saveGoals error: $e\n$st');
      }
    });
  }

  // ── Reset today ────────────────────────────────────────────────────────────
  /// Clears all of today's water, oxalate, and food-log data.
  /// Fix 2: runs inside _locked().
  Future<void> resetToday() {
    return _locked(() async {
      try {
        await _secure.setDouble(_waterKey,   0.0);
        await _secure.setDouble(_oxalateKey, 0.0);
        await _secure.setStringList(_oxLogKey, []);
        await _persistHistory();
      } catch (e, st) {
        debugPrint('[HydrationRepository] resetToday error: $e\n$st');
      }
    });
  }

  // ── Private: push today's totals into HistoryStorage ───────────────────────
  // Called inside _locked() so it always sees a consistent, just-written value.
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
      debugPrint('[HydrationRepository] _persistHistory error: $e\n$st');
    }
  }

  // ── Legacy migration helper ─────────────────────────────────────────────────
  /// Call once on app startup to migrate any existing plain-text
  /// SharedPreferences values into SecurePrefs.
  /// Safe to call even if no legacy data exists — it's a no-op in that case.
  Future<void> migrateLegacyPlainTextPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey(_waterKey)) {
        await _secure.setDouble(_waterKey, prefs.getDouble(_waterKey) ?? 0.0);
        await prefs.remove(_waterKey);
      }
      if (prefs.containsKey(_oxalateKey)) {
        await _secure.setDouble(_oxalateKey, prefs.getDouble(_oxalateKey) ?? 0.0);
        await prefs.remove(_oxalateKey);
      }
      if (prefs.containsKey(_oxLogKey)) {
        await _secure.setStringList(_oxLogKey, prefs.getStringList(_oxLogKey) ?? []);
        await prefs.remove(_oxLogKey);
      }
      if (prefs.containsKey('goal_water')) {
        await _secure.setDouble('goal_water', prefs.getDouble('goal_water') ?? 80.0);
        await prefs.remove('goal_water');
      }
      if (prefs.containsKey('goal_oxalate')) {
        await _secure.setDouble('goal_oxalate', prefs.getDouble('goal_oxalate') ?? 200.0);
        await prefs.remove('goal_oxalate');
      }
    } catch (e, st) {
      debugPrint('[HydrationRepository] migrateLegacyPlainTextPrefs error: $e\n$st');
    }
  }
}
