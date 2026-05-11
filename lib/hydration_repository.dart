// ─── HYDRATION REPOSITORY ────────────────────────────────────────────────────
// Single source of truth for all hydration and oxalate SharedPreferences
// keys. Every read/write to water_*, oxalate_*, and oxalate_log_* must
// go through this class so there is never more than one writer per key.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_storage.dart';

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

  // ── Key helpers ────────────────────────────────────────────────────────────
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }

  String get _waterKey    => 'water_${_todayKey()}';
  String get _oxalateKey  => 'oxalate_${_todayKey()}';
  String get _oxLogKey    => 'oxalate_log_${_todayKey()}';

  // ── Read ───────────────────────────────────────────────────────────────────
  /// Returns the full hydration snapshot for today.
  Future<HydrationSnapshot> readToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return HydrationSnapshot(
        waterOz:   prefs.getDouble(_waterKey)   ?? 0.0,
        oxalateMg: prefs.getDouble(_oxalateKey) ?? 0.0,
        goalOz:    prefs.getDouble('goal_water')   ?? 80.0,
        goalMg:    prefs.getDouble('goal_oxalate') ?? 200.0,
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
      final prefs   = await SharedPreferences.getInstance();
      final current = prefs.getDouble(_waterKey) ?? 0.0;
      final newVal  = (current + oz).clamp(0.0, double.infinity);
      await prefs.setDouble(_waterKey, newVal);
      await _persistHistory(prefs);
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
      final prefs   = await SharedPreferences.getInstance();
      final current = prefs.getDouble(_oxalateKey) ?? 0.0;
      final newVal  = current + mg;

      final log = List<String>.from(prefs.getStringList(_oxLogKey) ?? []);
      log.add('$foodName|$mg');

      await prefs.setDouble(_oxalateKey, newVal);
      await prefs.setStringList(_oxLogKey, log);
      await _persistHistory(prefs);
      return newVal;
    } catch (e, st) {
      debugPrint('[HydrationRepository] logFood error: $e\n$st');
      return -1;
    }
  }

  // ── Reset today ────────────────────────────────────────────────────────────
  /// Clears all of today's water, oxalate, and food-log data.
  Future<void> resetToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_waterKey,  0.0);
      await prefs.setDouble(_oxalateKey, 0.0);
      await prefs.setStringList(_oxLogKey, []);
      await _persistHistory(prefs);
    } catch (e, st) {
      debugPrint('[HydrationRepository] resetToday error: $e\n$st');
    }
  }

  // ── Private: push today's totals into HistoryStorage ───────────────────────
  Future<void> _persistHistory(SharedPreferences prefs) async {
    try {
      final waterOz   = prefs.getDouble(_waterKey)   ?? 0.0;
      final oxalateMg = prefs.getDouble(_oxalateKey) ?? 0.0;
      final today     = DateTime.now();
      final dateStr   =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final existing = await _history.loadHistory();
      final filtered = existing.where((e) => e['date'] != dateStr).toList();
      filtered.add({'date': dateStr, 'water_oz': waterOz, 'oxalate_mg': oxalateMg});
      if (filtered.length > 730) filtered.removeAt(0);
      await _history.saveHistory(filtered);
    } catch (e, st) {
      debugPrint('[HydrationRepository] _persistHistory error: $e\n$st');
    }
  }
}
