import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> _weeklyData = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  double _avgDailyOxalate = 0;
  double _avgDailyWater = 0;
  double _oxalateGoal = 200;
  double _waterGoal = 80;
  bool _isLoading = true;
  int _totalDaysLogged = 0;

  static const Color bgColor = Color(0xFFF8F8F8);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFD0D0D8);
  static const Color textColor = Color(0xFF2C2C2C);
  static const Color mutedColor = Color(0xFF888888);
  static const Color accentTeal = Color(0xFF1A8A9A);
  static const Color accentGold = Color(0xFFD4A020);
  static const Color accentGreen = Color(0xFF2A9A5A);
  static const Color barOk = Color(0xFF4AACCC);
  static const Color barOver = Color(0xFFE07070);
  static const Color barEmpty = Color(0xFFDDDDDD);
  static const Color goalLine = Color(0xFF1A8A9A);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();

    _oxalateGoal = prefs.getDouble('goal_oxalate') ?? 200.0;
    _waterGoal = prefs.getDouble('goal_water') ?? 80.0;

    final dailyHistoryRaw = prefs.getStringList('daily_history') ?? [];
    final Map<String, double> dailyOxalate = {};
    final Map<String, double> dailyWater = {};

    for (final entry in dailyHistoryRaw) {
      try {
        final map = jsonDecode(entry) as Map<String, dynamic>;
        final date = map['date'] as String?;
        if (date == null) continue;
        dailyOxalate[date] = (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0;
        dailyWater[date] = (map['water_oz'] as num?)?.toDouble() ?? 0.0;
      } catch (_) {}
    }

    final now = DateTime.now();
    final todayKey = '${now.year}_${now.month}_${now.day}';
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    dailyOxalate[todayStr] = prefs.getDouble('oxalate_$todayKey') ?? 0.0;
    dailyWater[todayStr] = prefs.getDouble('water_$todayKey') ?? 0.0;

    _totalDaysLogged = dailyOxalate.values.where((v) => v > 0).length;

    final List<String> dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<Map<String, dynamic>> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateKey =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final ox = dailyOxalate[dateKey] ?? 0.0;
      final wat = dailyWater[dateKey] ?? 0.0;

      weeklyData.add({
        'label': dayLabels[day.weekday % 7],
        'date': dateKey,
        'oxalate': ox,
        'water': wat,
        'oxalateGoalMet': ox > 0 && ox <= _oxalateGoal,
        'waterGoalMet': wat >= _waterGoal,
      });
    }

    int streak = 0;
    int best = prefs.getInt('best_streak') ?? 0;
    for (int i = weeklyData.length - 1; i >= 0; i--) {
      if (weeklyData[i]['oxalateGoalMet'] && weeklyData[i]['waterGoalMet']) {
        streak++;
      } else {
        break;
      }
    }
    if (streak > best) {
      best = streak;
      await prefs.setInt('best_streak', best);
    }

    final daysWithOx = weeklyData.where((d) => (d['oxalate'] as double) > 0).toList();
    final avgOx = daysWithOx.isEmpty
        ? 0.0
        : daysWithOx.fold(0.0, (s, d) => s + (d['oxalate'] as double)) / daysWithOx.length;

    final daysWithWater = weeklyData.where((d) => (d['water'] as double) > 0).toList();
    final avgWater = daysWithWater.isEmpty
        ? 0.0
        : daysWithWater.fold(0.0, (s, d) => s + (d['water'] as double)) / daysWithWater.length;

    setState(() {
      _weeklyData = weeklyData;
      _currentStreak = streak;
      _bestStreak = best;
      _avgDailyOxalate = avgOx;
      _avgDailyWater = avgWater;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: accentTeal));
    }

    return RefreshIndicator(
      color: accentTeal,
      onRefresh: _loadProgressData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildStreakCard('🔥 Current Streak', '$_currentStreak days', Colors.deepOrange)),
                const SizedBox(width: 12),
                Expanded(child: _buildStreakCard('🏆 Best Streak', '$_bestStreak days', accentGold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '⚗️ Avg Oxalate',
                    '${_avgDailyOxalate.toStringAsFixed(0)} mg/day',
                    _avgDailyOxalate <= _oxalateGoal ? accentGreen : Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '💧 Avg Water',
                    '${_avgDailyWater.toStringAsFixed(0)} oz/day',
                    _avgDailyWater >= _waterGoal ? accentTeal : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('7-Day Oxalate Intake',
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildBarChart(),
            const SizedBox(height: 20),
            const Text('Daily Breakdown',
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._weeklyData.map((day) => _buildDayRow(day)),
            const SizedBox(height: 20),
            const Text('Achievements',
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: mutedColor, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: mutedColor, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final maxOxalate = _weeklyData.fold(
        0.0, (max, d) => d['oxalate'] > max ? d['oxalate'] as double : max);
    final chartMax = maxOxalate < _oxalateGoal ? _oxalateGoal * 1.2 : maxOxalate * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: barOk, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              const Text('Under goal', style: TextStyle(color: mutedColor, fontSize: 11)),
              const SizedBox(width: 12),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: barOver, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              const Text('Over goal', style: TextStyle(color: mutedColor, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyData.map((day) {
                final oxalate = day['oxalate'] as double;
                final barHeight = chartMax > 0 ? (oxalate / chartMax) * 100 : 0.0;
                final isOverGoal = oxalate > _oxalateGoal;
                final Color barColor = oxalate == 0 ? barEmpty : isOverGoal ? barOver : barOk;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (oxalate > 0)
                        Text(oxalate.toStringAsFixed(0),
                            style: const TextStyle(color: mutedColor, fontSize: 8)),
                      const SizedBox(height: 2),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SizedBox(
                            height: 80,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 22,
                                height: barHeight.clamp(2.0, 80.0),
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: chartMax > 0 ? (_oxalateGoal / chartMax) * 100 : 0,
                            child: Container(
                              width: 26,
                              height: 1.5,
                              color: goalLine.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(day['label'], style: const TextStyle(color: mutedColor, fontSize: 10)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(Map<String, dynamic> day) {
    final oxalate = day['oxalate'] as double;
    final water = day['water'] as double;
    final oxGoalMet = day['oxalateGoalMet'] as bool;
    final waterGoalMet = day['waterGoalMet'] as bool;
    final bothMet = oxGoalMet && waterGoalMet;
    final noData = oxalate == 0 && water == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: bothMet
              ? accentGreen.withValues(alpha: 0.35)
              : noData
                  ? borderColor.withValues(alpha: 0.5)
                  : borderColor,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bothMet
                    ? accentGreen.withValues(alpha: 0.1)
                    : noData
                        ? borderColor.withValues(alpha: 0.3)
                        : accentTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day['label'].toString().substring(0, 3),
                    style: TextStyle(
                      color: bothMet ? accentGreen : noData ? mutedColor : accentTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: noData
                  ? Row(
                      children: [
                        Icon(Icons.remove_circle_outline, color: mutedColor.withValues(alpha: 0.5), size: 16),
                        const SizedBox(width: 6),
                        const Text('No data logged',
                            style: TextStyle(color: mutedColor, fontSize: 13, fontStyle: FontStyle.italic)),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('OXALATE',
                                  style: TextStyle(
                                      color: mutedColor, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(
                                '${oxalate.toStringAsFixed(0)} mg',
                                style: TextStyle(
                                    color: oxGoalMet ? accentGreen : Colors.redAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (oxalate / _oxalateGoal).clamp(0.0, 1.0),
                                  minHeight: 4,
                                  backgroundColor: borderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      oxGoalMet ? accentGreen : Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 1, height: 40, margin: const EdgeInsets.symmetric(horizontal: 12), color: borderColor),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('WATER',
                                  style: TextStyle(
                                      color: mutedColor, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(
                                '${water.toStringAsFixed(0)} oz',
                                style: TextStyle(
                                    color: waterGoalMet ? accentTeal : Colors.orange,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (water / _waterGoal).clamp(0.0, 1.0),
                                  minHeight: 4,
                                  backgroundColor: borderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      waterGoalMet ? accentTeal : Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            if (!noData) ...[
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bothMet ? accentGreen.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  bothMet ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: bothMet ? accentGreen : Colors.orange,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'icon': '🥇', 'title': 'First Log', 'desc': 'Logged your first food', 'unlocked': _weeklyData.any((d) => d['oxalate'] > 0)},
      {'icon': '🔥', 'title': '3-Day Streak', 'desc': 'Met both goals 3 days in a row', 'unlocked': _currentStreak >= 3},
      {'icon': '💧', 'title': 'Hydration Hero', 'desc': 'Met water goal 5 of 7 days', 'unlocked': _weeklyData.where((d) => d['waterGoalMet']).length >= 5},
      {'icon': '🛡️', 'title': 'Stone Guardian', 'desc': 'Stayed under oxalate limit all week', 'unlocked': _weeklyData.where((d) => d['oxalate'] > 0).every((d) => d['oxalateGoalMet'])},
      {'icon': '🏆', 'title': '7-Day Champion', 'desc': 'Perfect week — all goals met!', 'unlocked': _currentStreak >= 7},
      {'icon': '📅', 'title': '14-Day Logger', 'desc': 'Logged food for 14 days', 'unlocked': _totalDaysLogged >= 14},
      {'icon': '🌟', 'title': '21-Day Habit', 'desc': "Logged food for 21 days — it's a habit!", 'unlocked': _totalDaysLogged >= 21},
      {'icon': '🥈', 'title': '30-Day Warrior', 'desc': 'Logged food for 30 days straight', 'unlocked': _totalDaysLogged >= 30},
      {'icon': '🎖️', 'title': '3-Month Guardian', 'desc': 'Logged food for 90 days', 'unlocked': _totalDaysLogged >= 90},
      {'icon': '🥉', 'title': '6-Month Defender', 'desc': 'Logged food for 180 days', 'unlocked': _totalDaysLogged >= 180},
      {'icon': '👑', 'title': '1-Year Legend', 'desc': 'Logged food for a full year!', 'unlocked': _totalDaysLogged >= 365},
      {'icon': '💎', 'title': '2-Year Diamond', 'desc': "Logged food for 2 years — you're unstoppable!", 'unlocked': _totalDaysLogged >= 730},
    ];

    return Column(
      children: achievements.map((a) {
        final unlocked = a['unlocked'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unlocked ? const Color(0xFFF0FAF4) : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: unlocked ? accentGreen.withValues(alpha: 0.35) : borderColor),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 1)),
            ],
          ),
          child: Row(
            children: [
              Text(a['icon'] as String,
                  style: TextStyle(fontSize: 28, color: unlocked ? null : Colors.grey.withValues(alpha: 0.4))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['title'] as String,
                        style: TextStyle(
                            color: unlocked ? textColor : mutedColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(a['desc'] as String, style: const TextStyle(color: mutedColor, fontSize: 12)),
                  ],
                ),
              ),
              if (unlocked)
                const Icon(Icons.check_circle, color: accentGreen, size: 22)
              else
                const Icon(Icons.lock_outline, color: mutedColor, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }
}
