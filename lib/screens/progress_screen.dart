import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:convert';
import 'dart:math';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  // ── Data ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _weeklyData = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  double _avgDailyOxalate = 0;
  double _avgDailyWater = 0;
  double _oxalateGoal = 200;
  double _waterGoal = 80;
  bool _isLoading = true;
  int _totalDaysLogged = 0;
  int _longestConsecutiveStreak = 0;
  Set<String> _celebratedBadges = {};

  // ── Animation controllers ─────────────────────────────────────────────────
  late ConfettiController _confettiController;
  final Map<String, AnimationController> _badgeAnimControllers = {};
  final Map<String, Animation<double>> _badgeScaleAnims = {};

  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color cardColor   = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFD0D0D8);
  static const Color textColor   = Color(0xFF2C2C2C);
  static const Color mutedColor  = Color(0xFF888888);
  static const Color accentTeal  = Color(0xFF1A8A9A);
  static const Color accentGold  = Color(0xFFD4A020);
  static const Color accentGreen = Color(0xFF2A9A5A);
  static const Color barOk       = Color(0xFF4AACCC);
  static const Color barOver     = Color(0xFFE07070);
  static const Color barEmpty    = Color(0xFFDDDDDD);
  static const Color goalLine    = Color(0xFF1A8A9A);

  // ── Badge definitions ─────────────────────────────────────────────────────
  // 'milestone' badges get confetti + modal; others get pop + shimmer only.
  List<Map<String, dynamic>> get _achievements => [
    {
      'id': 'first_log',
      'icon': '🥇',
      'title': 'First Log',
      'desc': 'Logged your first food',
      'unlocked': _weeklyData.any((d) => d['oxalate'] > 0),
      'progress': null,
      'milestone': false,
    },
    {
      'id': 'streak_3',
      'icon': '🔥',
      'title': '3-Day Streak',
      'desc': 'Met both goals 3 days in a row',
      'unlocked': _currentStreak >= 3,
      'progress': _currentStreak < 3 ? '${_currentStreak} / 3 days' : null,
      'milestone': false,
    },
    {
      'id': 'hydration_hero',
      'icon': '💧',
      'title': 'Hydration Hero',
      'desc': 'Met water goal 5 of the last 7 days',
      'unlocked': _weeklyData.where((d) => d['waterGoalMet']).length >= 5,
      'progress': _weeklyData.where((d) => d['waterGoalMet']).length < 5
          ? '${_weeklyData.where((d) => d['waterGoalMet']).length} / 5 days'
          : null,
      'milestone': false,
    },
    {
      'id': 'stone_guardian',
      'icon': '🛡️',
      'title': 'Stone Guardian',
      'desc': 'Stayed under oxalate limit all week',
      'unlocked': _weeklyData.where((d) => d['oxalate'] > 0).isNotEmpty &&
          _weeklyData.where((d) => d['oxalate'] > 0).every((d) => d['oxalateGoalMet']),
      'progress': null,
      'milestone': false,
    },
    {
      'id': 'champ_7',
      'icon': '🏆',
      'title': '7-Day Champion',
      'desc': 'Met all goals 7 days in a row',
      'unlocked': _currentStreak >= 7,
      'progress': _currentStreak < 7 ? '${_currentStreak} / 7 days' : null,
      'milestone': true,
    },
    {
      'id': 'logger_14',
      'icon': '📅',
      'title': '14-Day Logger',
      'desc': 'Logged food on 14 different days',
      'unlocked': _totalDaysLogged >= 14,
      'progress': _totalDaysLogged < 14 ? '$_totalDaysLogged / 14 days' : null,
      'milestone': false,
    },
    {
      'id': 'habit_21',
      'icon': '🌟',
      'title': '21-Day Habit',
      'desc': "Logged food on 21 days — it's becoming a habit!",
      'unlocked': _totalDaysLogged >= 21,
      'progress': _totalDaysLogged < 21 ? '$_totalDaysLogged / 21 days' : null,
      'milestone': false,
    },
    {
      'id': 'warrior_30',
      'icon': '🥈',
      'title': '30-Day Warrior',
      'desc': 'Logged food on 30 different days',
      'unlocked': _totalDaysLogged >= 30,
      'progress': _totalDaysLogged < 30 ? '$_totalDaysLogged / 30 days' : null,
      'milestone': true,
    },
    {
      'id': 'streak_30',
      'icon': '⚡',
      'title': '30-Day Streak',
      'desc': 'Met all goals 30 days in a row',
      'unlocked': _longestConsecutiveStreak >= 30,
      'progress': _longestConsecutiveStreak < 30
          ? '$_longestConsecutiveStreak / 30 days'
          : null,
      'milestone': true,
    },
    {
      'id': 'guardian_90',
      'icon': '🎖️',
      'title': '3-Month Guardian',
      'desc': 'Logged food on 90 different days',
      'unlocked': _totalDaysLogged >= 90,
      'progress': _totalDaysLogged < 90 ? '$_totalDaysLogged / 90 days' : null,
      'milestone': true,
    },
    {
      'id': 'defender_180',
      'icon': '🥉',
      'title': '6-Month Defender',
      'desc': 'Logged food on 180 different days',
      'unlocked': _totalDaysLogged >= 180,
      'progress': _totalDaysLogged < 180 ? '$_totalDaysLogged / 180 days' : null,
      'milestone': true,
    },
    {
      'id': 'legend_365',
      'icon': '👑',
      'title': '1-Year Legend',
      'desc': 'Logged food for a full year!',
      'unlocked': _totalDaysLogged >= 365,
      'progress': _totalDaysLogged < 365 ? '$_totalDaysLogged / 365 days' : null,
      'milestone': true,
    },
    {
      'id': 'diamond_730',
      'icon': '💎',
      'title': '2-Year Diamond',
      'desc': "Logged food for 2 years — you're unstoppable!",
      'unlocked': _totalDaysLogged >= 730,
      'progress': _totalDaysLogged < 730 ? '$_totalDaysLogged / 730 days' : null,
      'milestone': true,
    },
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProgressData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    for (final c in _badgeAnimControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();

    _oxalateGoal = prefs.getDouble('goal_oxalate') ?? 200.0;
    _waterGoal   = prefs.getDouble('goal_water')   ?? 80.0;

    // Load celebrated badge IDs so we only show the modal once per badge
    final celebratedList = prefs.getStringList('celebrated_badges') ?? [];
    _celebratedBadges = celebratedList.toSet();

    // ── Build full date→value maps from daily_history ─────────────────────
    final dailyHistoryRaw = prefs.getStringList('daily_history') ?? [];
    final Map<String, double> dailyOxalate = {};
    final Map<String, double> dailyWater   = {};

    for (final entry in dailyHistoryRaw) {
      try {
        final map  = jsonDecode(entry) as Map<String, dynamic>;
        final date = map['date'] as String?;
        if (date == null) continue;
        dailyOxalate[date] = (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0;
        dailyWater[date]   = (map['water_oz']   as num?)?.toDouble() ?? 0.0;
      } catch (_) {}
    }

    // Merge today's live prefs values
    final now      = DateTime.now();
    final todayKey = '${now.year}_${now.month}_${now.day}';
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    dailyOxalate[todayStr] = prefs.getDouble('oxalate_$todayKey') ?? 0.0;
    dailyWater[todayStr]   = prefs.getDouble('water_$todayKey')   ?? 0.0;

    // ── Total days logged (any day with oxalate > 0) ──────────────────────
    final totalDaysLogged =
        dailyOxalate.values.where((v) => v > 0).length;

    // ── Current streak: scan FULL history backwards from today ────────────
    int currentStreak = 0;
    DateTime cursor = now;
    while (true) {
      final key =
          '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
      final ox  = dailyOxalate[key] ?? 0.0;
      final wat = dailyWater[key]   ?? 0.0;
      final oxGoalMet  = ox  > 0 && ox  <= _oxalateGoal;
      final watGoalMet = wat >= _waterGoal;
      if (oxGoalMet && watGoalMet) {
        currentStreak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
      // Safety: don't loop more than 2 years back
      if (cursor.isBefore(now.subtract(const Duration(days: 730)))) break;
    }

    // ── Longest consecutive streak across full history ────────────────────
    int longestStreak = 0;
    int runningStreak = 0;
    // Sort all dates that have data
    final allDates = dailyOxalate.keys
        .where((k) => (dailyOxalate[k] ?? 0) > 0)
        .map((k) => DateTime.tryParse(k))
        .whereType<DateTime>()
        .toList()
      ..sort();

    for (int i = 0; i < allDates.length; i++) {
      final ox  = dailyOxalate[
              '${allDates[i].year}-${allDates[i].month.toString().padLeft(2, '0')}-${allDates[i].day.toString().padLeft(2, '0')}'] ??
          0.0;
      final wat = dailyWater[
              '${allDates[i].year}-${allDates[i].month.toString().padLeft(2, '0')}-${allDates[i].day.toString().padLeft(2, '0')}'] ??
          0.0;
      final oxGoalMet  = ox  > 0 && ox  <= _oxalateGoal;
      final watGoalMet = wat >= _waterGoal;

      if (oxGoalMet && watGoalMet) {
        if (i == 0) {
          runningStreak = 1;
        } else {
          final diff = allDates[i].difference(allDates[i - 1]).inDays;
          runningStreak = diff == 1 ? runningStreak + 1 : 1;
        }
        if (runningStreak > longestStreak) longestStreak = runningStreak;
      } else {
        runningStreak = 0;
      }
    }

    // ── Best streak (persist if beaten) ──────────────────────────────────
    int best = prefs.getInt('best_streak') ?? 0;
    if (currentStreak > best) {
      best = currentStreak;
      await prefs.setInt('best_streak', best);
    }
    if (longestStreak > best) {
      best = longestStreak;
      await prefs.setInt('best_streak', best);
    }

    // ── 7-day window for chart & averages ────────────────────────────────
    final List<String> dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<Map<String, dynamic>> weeklyData = [];
    for (int i = 6; i >= 0; i--) {
      final day     = now.subtract(Duration(days: i));
      final dateKey =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final ox  = dailyOxalate[dateKey] ?? 0.0;
      final wat = dailyWater[dateKey]   ?? 0.0;
      weeklyData.add({
        'label':        dayLabels[day.weekday % 7],
        'date':         dateKey,
        'oxalate':      ox,
        'water':        wat,
        'oxalateGoalMet': ox > 0 && ox <= _oxalateGoal,
        'waterGoalMet':   wat >= _waterGoal,
      });
    }

    final daysWithOx = weeklyData.where((d) => (d['oxalate'] as double) > 0).toList();
    final avgOx = daysWithOx.isEmpty
        ? 0.0
        : daysWithOx.fold(0.0, (s, d) => s + (d['oxalate'] as double)) /
            daysWithOx.length;

    final daysWithWat = weeklyData.where((d) => (d['water'] as double) > 0).toList();
    final avgWat = daysWithWat.isEmpty
        ? 0.0
        : daysWithWat.fold(0.0, (s, d) => s + (d['water'] as double)) /
            daysWithWat.length;

    setState(() {
      _weeklyData              = weeklyData;
      _currentStreak           = currentStreak;
      _bestStreak              = best;
      _longestConsecutiveStreak = longestStreak;
      _avgDailyOxalate         = avgOx;
      _avgDailyWater           = avgWat;
      _totalDaysLogged         = totalDaysLogged;
      _isLoading               = false;
    });

    // Check for newly unlocked badges AFTER setState so _achievements is fresh
    await _checkForNewUnlocks(prefs);
  }

  // ── Badge unlock detection ────────────────────────────────────────────────
  Future<void> _checkForNewUnlocks(SharedPreferences prefs) async {
    for (final badge in _achievements) {
      final id       = badge['id'] as String;
      final unlocked = badge['unlocked'] as bool;
      final isMilestone = badge['milestone'] as bool;

      if (unlocked && !_celebratedBadges.contains(id)) {
        // Mark as celebrated immediately so it only fires once
        _celebratedBadges.add(id);
        await prefs.setStringList(
            'celebrated_badges', _celebratedBadges.toList());

        // Run the badge pop animation
        _triggerBadgePop(id);

        // Short delay so user sees the screen before the modal/confetti
        await Future.delayed(const Duration(milliseconds: 400));

        if (!mounted) return;

        if (isMilestone) {
          _confettiController.play();
          HapticFeedback.heavyImpact();
        }

        _showAchievementModal(badge);

        // Only show one celebration at a time
        break;
      }
    }
  }

  // ── Badge pop animation ───────────────────────────────────────────────────
  void _triggerBadgePop(String id) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));

    _badgeAnimControllers[id] = ctrl;
    _badgeScaleAnims[id]      = anim;

    ctrl.forward();
    setState(() {});
  }

  // ── Achievement modal ─────────────────────────────────────────────────────
  void _showAchievementModal(Map<String, dynamic> badge) {
    final isMilestone = badge['milestone'] as bool;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AchievementModal(
        badge: badge,
        isMilestone: isMilestone,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: accentTeal));
    }

    return Stack(
      children: [
        RefreshIndicator(
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
                    Expanded(
                      child: _buildStreakCard(
                          '🔥 Current Streak', '$_currentStreak days',
                          Colors.deepOrange)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStreakCard(
                          '🏆 Best Streak', '$_bestStreak days', accentGold)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '⚗️ Avg Oxalate',
                        '${_avgDailyOxalate.toStringAsFixed(0)} mg/day',
                        _avgDailyOxalate <= _oxalateGoal
                            ? accentGreen
                            : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '💧 Avg Water',
                        '${_avgDailyWater.toStringAsFixed(0)} oz/day',
                        _avgDailyWater >= _waterGoal
                            ? accentTeal
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('7-Day Oxalate Intake',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildBarChart(),
                const SizedBox(height: 20),
                const Text('Daily Breakdown',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._weeklyData.map((day) => _buildDayRow(day)),
                const SizedBox(height: 20),
                const Text('Achievements',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildAchievements(),
              ],
            ),
          ),
        ),

        // Confetti sits on top of everything, centred at top
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            gravity: 0.3,
            colors: const [
              accentTeal, accentGold, accentGreen,
              Colors.orange, Colors.deepOrange, Colors.purpleAccent,
            ],
          ),
        ),
      ],
    );
  }

  // ── Streak card ───────────────────────────────────────────────────────────
  Widget _buildStreakCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: mutedColor, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Stat card ─────────────────────────────────────────────────────────────
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(color: mutedColor, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Bar chart ─────────────────────────────────────────────────────────────
  Widget _buildBarChart() {
    final maxOxalate = _weeklyData.fold(
        0.0,
        (max, d) =>
            (d['oxalate'] as double) > max ? d['oxalate'] as double : max);
    final chartMax =
        maxOxalate < _oxalateGoal ? _oxalateGoal * 1.2 : maxOxalate * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: barOk,
                      borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              const Text('Under goal',
                  style: TextStyle(color: mutedColor, fontSize: 11)),
              const SizedBox(width: 12),
              Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: barOver,
                      borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              const Text('Over goal',
                  style: TextStyle(color: mutedColor, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyData.map((day) {
                final oxalate = day['oxalate'] as double;
                final barHeight =
                    chartMax > 0 ? (oxalate / chartMax) * 100 : 0.0;
                final isOverGoal = oxalate > _oxalateGoal;
                final Color barColor = oxalate == 0
                    ? barEmpty
                    : isOverGoal
                        ? barOver
                        : barOk;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (oxalate > 0)
                        Text(oxalate.toStringAsFixed(0),
                            style: const TextStyle(
                                color: mutedColor, fontSize: 8)),
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
                            bottom: chartMax > 0
                                ? (_oxalateGoal / chartMax) * 100
                                : 0,
                            child: Container(
                              width: 26,
                              height: 1.5,
                              color: goalLine.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(day['label'],
                          style: const TextStyle(
                              color: mutedColor, fontSize: 10)),
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

  // ── Day row ───────────────────────────────────────────────────────────────
  Widget _buildDayRow(Map<String, dynamic> day) {
    final oxalate    = day['oxalate']      as double;
    final water      = day['water']        as double;
    final oxGoalMet  = day['oxalateGoalMet'] as bool;
    final waterGoalMet = day['waterGoalMet'] as bool;
    final bothMet    = oxGoalMet && waterGoalMet;
    final noData     = oxalate == 0 && water == 0;

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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
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
                      color: bothMet
                          ? accentGreen
                          : noData
                              ? mutedColor
                              : accentTeal,
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
                        Icon(Icons.remove_circle_outline,
                            color: mutedColor.withValues(alpha: 0.5),
                            size: 16),
                        const SizedBox(width: 6),
                        const Text('No data logged',
                            style: TextStyle(
                                color: mutedColor,
                                fontSize: 13,
                                fontStyle: FontStyle.italic)),
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
                                      color: mutedColor,
                                      fontSize: 9,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(
                                '${oxalate.toStringAsFixed(0)} mg',
                                style: TextStyle(
                                    color: oxGoalMet
                                        ? accentGreen
                                        : Colors.redAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (oxalate / _oxalateGoal)
                                      .clamp(0.0, 1.0),
                                  minHeight: 4,
                                  backgroundColor: borderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      oxGoalMet
                                          ? accentGreen
                                          : Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            color: borderColor),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('WATER',
                                  style: TextStyle(
                                      color: mutedColor,
                                      fontSize: 9,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(
                                '${water.toStringAsFixed(0)} oz',
                                style: TextStyle(
                                    color: waterGoalMet
                                        ? accentTeal
                                        : Colors.orange,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value:
                                      (water / _waterGoal).clamp(0.0, 1.0),
                                  minHeight: 4,
                                  backgroundColor: borderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      waterGoalMet
                                          ? accentTeal
                                          : Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            if (!noData) ...[const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bothMet
                      ? accentGreen.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  bothMet
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
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

  // ── Achievements list ─────────────────────────────────────────────────────
  Widget _buildAchievements() {
    return Column(
      children: _achievements.map((a) {
        final id        = a['id']       as String;
        final unlocked  = a['unlocked'] as bool;
        final progress  = a['progress'] as String?;
        final isMilestone = a['milestone'] as bool;

        final scaleAnim = _badgeScaleAnims[id];

        Widget card = Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unlocked
                ? (isMilestone
                    ? const Color(0xFFFFF8E1)   // warm gold tint for milestones
                    : const Color(0xFFF0FAF4))  // green tint for regulars
                : cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: unlocked
                  ? (isMilestone
                      ? accentGold.withValues(alpha: 0.45)
                      : accentGreen.withValues(alpha: 0.35))
                  : borderColor,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1))
            ],
          ),
          child: Row(
            children: [
              // Emoji — greyed out when locked
              Text(
                a['icon'] as String,
                style: TextStyle(
                  fontSize: 28,
                  color: unlocked ? null : Colors.grey.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['title'] as String,
                      style: TextStyle(
                          color: unlocked ? textColor : mutedColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text(a['desc'] as String,
                        style:
                            const TextStyle(color: mutedColor, fontSize: 12)),
                    // Progress hint for locked badges
                    if (!unlocked && progress != null) ...[const SizedBox(height: 4),
                      Text(
                        progress,
                        style: TextStyle(
                          color: accentTeal.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (unlocked)
                Icon(
                  isMilestone ? Icons.star_rounded : Icons.check_circle,
                  color: isMilestone ? accentGold : accentGreen,
                  size: 22,
                )
              else
                const Icon(Icons.lock_outline, color: mutedColor, size: 20),
            ],
          ),
        );

        // Wrap in scale animation if one is active for this badge
        if (scaleAnim != null) {
          card = AnimatedBuilder(
            animation: scaleAnim,
            builder: (_, child) =>
                Transform.scale(scale: scaleAnim.value, child: child),
            child: card,
          );
        }

        return card;
      }).toList(),
    );
  }
}

// ── Achievement Unlock Modal ──────────────────────────────────────────────────
class _AchievementModal extends StatefulWidget {
  final Map<String, dynamic> badge;
  final bool isMilestone;

  const _AchievementModal({
    required this.badge,
    required this.isMilestone,
  });

  @override
  State<_AchievementModal> createState() => _AchievementModalState();
}

class _AchievementModalState extends State<_AchievementModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMilestone = widget.isMilestone;
    final badge       = widget.badge;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Animated emoji
            ScaleTransition(
              scale: _scaleAnim,
              child: Text(
                badge['icon'] as String,
                style: const TextStyle(fontSize: 72),
              ),
            ),
            const SizedBox(height: 12),

            // "Achievement Unlocked!" label
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isMilestone
                    ? const Color(0xFFD4A020).withValues(alpha: 0.12)
                    : const Color(0xFF2A9A5A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isMilestone ? '🎉 Milestone Unlocked!' : '✅ Achievement Unlocked!',
                style: TextStyle(
                  color: isMilestone
                      ? const Color(0xFFD4A020)
                      : const Color(0xFF2A9A5A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 14),

            Text(
              badge['title'] as String,
              style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              badge['desc'] as String,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Dismiss button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMilestone
                      ? const Color(0xFFD4A020)
                      : const Color(0xFF1A8A9A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('Awesome! 🙌',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
