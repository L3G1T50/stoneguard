// ─── HYDRATION REPOSITORY ────────────────────────────────────────────────────
// Single source of truth for all hydration and oxalate data.
// All current-day values (water_*, oxalate_*, oxalate_log_*, goal_*) are
// stored via SecurePrefs (AES-256-CBC) instead of plain SharedPreferences.
// This closes the last plain-text PHI storage gap for current-day data.

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
  /// All values are read from encrypted storage via SecurePrefs.
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
  /// Returns the new running total, or -1 on failure.
  Future<double> addWater(double oz) async {
    try {
      final current = await _secure.getDouble(_waterKey, defaultValue: 0.0);
      final newVal  = (current + oz).clamp(0.0, double.infinity);
      await _secure.setDouble(_waterKey, newVal);
      await _persistHistory();
      return newVal;
    } catch (e, st) {
      debugPrint('[HydrationRepository] addWater error: $e\n$st');
      return -1;
    }
  }

  // ── Log food ───────────────────────────────────────────────────────────────
  /// Records [mg] oxalate from [foodName] and adds it to today's running
  /// total. Returns the new oxalate total, or -1 on failure.
  Future<double> logFood(double mg, String foodName) async {
    try {
      final current = await _secure.getDouble(_oxalateKey, defaultValue: 0.0);
      final newVal  = current + mg;

      final log = await _secure.getStringList(_oxLogKey);
      log.add('$foodName|$mg');

      await _secure.setDouble(_oxalateKey, newVal);
      await _secure.setStringList(_oxLogKey, log);
      await _persistHistory();
      return newVal;
    } catch (e, st) {
      debugPrint('[HydrationRepository] logFood error: $e\n$st');
      return -1;
    }
  }

  // ── Save goals ─────────────────────────────────────────────────────────────
  /// Persists the user's daily water and oxalate goals (encrypted).
  Future<void> saveGoals({required double goalOz, required double goalMg}) async {
    try {
      await _secure.setDouble('goal_water',   goalOz);
      await _secure.setDouble('goal_oxalate', goalMg);
    } catch (e, st) {
      debugPrint('[HydrationRepository] saveGoals error: $e\n$st');
    }
  }

  // ── Reset today ────────────────────────────────────────────────────────────
  /// Clears all of today's water, oxalate, and food-log data.
  Future<void> resetToday() async {
    try {
      await _secure.setDouble(_waterKey,   0.0);
      await _secure.setDouble(_oxalateKey, 0.0);
      await _secure.setStringList(_oxLogKey, []);
      await _persistHistory();
    } catch (e, st) {
      debugPrint('[HydrationRepository] resetToday error: $e\n$st');
    }
  }

  // ── Private: push today's totals into HistoryStorage ───────────────────────
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
  /// Call once on app startup (in main.dart or splash screen) to migrate any
  /// existing plain-text SharedPreferences values into SecurePrefs.
  /// Safe to call even if no legacy data exists — it's a no-op in that case.
  Future<void> migrateLegacyPlainTextPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Migrate current-day water
      final legacyWaterKey = _waterKey;
      if (prefs.containsKey(legacyWaterKey)) {
        final val = prefs.getDouble(legacyWaterKey) ?? 0.0;
        await _secure.setDouble(legacyWaterKey, val);
        await prefs.remove(legacyWaterKey);
      }

      // Migrate current-day oxalate
      final legacyOxKey = _oxalateKey;
      if (prefs.containsKey(legacyOxKey)) {
        final val = prefs.getDouble(legacyOxKey) ?? 0.0;
        await _secure.setDouble(legacyOxKey, val);
        await prefs.remove(legacyOxKey);
      }

      // Migrate current-day food log
      final legacyLogKey = _oxLogKey;
      if (prefs.containsKey(legacyLogKey)) {
        final val = prefs.getStringList(legacyLogKey) ?? [];
        await _secure.setStringList(legacyLogKey, val);
        await prefs.remove(legacyLogKey);
      }

      // Migrate goals
      if (prefs.containsKey('goal_water')) {
        final val = prefs.getDouble('goal_water') ?? 80.0;
        await _secure.setDouble('goal_water', val);
        await prefs.remove('goal_water');
      }
      if (prefs.containsKey('goal_oxalate')) {
        final val = prefs.getDouble('goal_oxalate') ?? 200.0;
        await _secure.setDouble('goal_oxalate', val);
        await prefs.remove('goal_oxalate');
      }
    } catch (e, st) {
      debugPrint('[HydrationRepository] migrateLegacyPlainTextPrefs error: $e\n$st');
    }
  }
}
