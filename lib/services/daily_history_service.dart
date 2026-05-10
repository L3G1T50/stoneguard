import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Utility helpers for loading and saving StoneGuard's per-day
/// hydration + oxalate history from SharedPreferences.
///
/// This keeps the JSON shape and trimming logic in one place so
/// HomeShield, Progress charts, History, and Doctor Export all
/// stay in sync.
class DailyHistoryService {
  DailyHistoryService._();

  /// Load the full history maps for oxalate (mg) and water (oz).
  ///
  /// - [oxalateByDate] and [waterByDate] use the key format
  ///   `YYYY-MM-DD` (e.g. 2026-05-09).
  /// - Today is merged in from the live per-day keys
  ///   `oxalate_YYYY_M_D` and `water_YYYY_M_D`.
  static Future<(Map<String, double>, Map<String, double>)>
      loadDailyHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final rawList = prefs.getStringList('daily_history') ?? <String>[];
    final Map<String, double> oxalateByDate = {};
    final Map<String, double> waterByDate   = {};

    for (final entry in rawList) {
      try {
        final map  = jsonDecode(entry) as Map<String, dynamic>;
        final date = map['date'] as String?;
        if (date == null) continue;
        oxalateByDate[date] = (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0;
        waterByDate[date]   = (map['water_oz']   as num?)?.toDouble() ?? 0.0;
      } catch (_) {
        // Ignore malformed entries
      }
    }

    // Merge in today's live values from the per-day keys so
    // all views stay current even before history is updated.
    final now      = DateTime.now();
    final todayKey = '${now.year}_${now.month}_${now.day}';
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    oxalateByDate[todayStr] =
        prefs.getDouble('oxalate_$todayKey') ?? (oxalateByDate[todayStr] ?? 0.0);
    waterByDate[todayStr]   =
        prefs.getDouble('water_$todayKey')   ?? (waterByDate[todayStr]   ?? 0.0);

    return (oxalateByDate, waterByDate);
  }

  /// Save today's water + oxalate into the `daily_history` list,
  /// keeping at most [maxDays] entries (default 730 ~= 2 years).
  static Future<void> saveToday({
    required double waterOz,
    required double oxalateMg,
    int maxDays = 730,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final newJson = jsonEncode(<String, dynamic>{
      'date': dateStr,
      'water_oz': waterOz,
      'oxalate_mg': oxalateMg,
    });

    final list = prefs.getStringList('daily_history') ?? <String>[];

    // Remove any existing entry for this date so we only keep
    // a single record per day.
    final updated = <String>[];
    for (final e in list) {
      try {
        final map = jsonDecode(e) as Map<String, dynamic>;
        if (map['date'] != dateStr) updated.add(e);
      } catch (_) {
        // If parsing fails, drop the bad entry.
      }
    }

    updated.add(newJson);

    // Trim oldest entries if we go over the desired window.
    if (updated.length > maxDays) {
      updated.removeRange(0, updated.length - maxDays);
    }

    await prefs.setStringList('daily_history', updated);
  }
}
