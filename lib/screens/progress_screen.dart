import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:convert';

// ── Timeframe enum ────────────────────────────────────────────────────────────
enum ChartTimeframe { d7, d30, m6, y1, y2 }

extension ChartTimeframeLabel on ChartTimeframe {
  String get label {
    switch (this) {
      case ChartTimeframe.d7:  return '7D';
      case ChartTimeframe.d30: return '30D';
      case ChartTimeframe.m6:  return '6M';
      case ChartTimeframe.y1:  return '1Y';
      case ChartTimeframe.y2:  return '2Y';
    }
  }

  int get days {
    switch (this) {
      case ChartTimeframe.d7:  return 7;
      case ChartTimeframe.d30: return 30;
      case ChartTimeframe.m6:  return 183;
      case ChartTimeframe.y1:  return 365;
      case ChartTimeframe.y2:  return 730;
    }
  }
}

// ── Chart metric enum ─────────────────────────────────────────────────────────
enum ChartMetric { oxalate, water }

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  // ── Raw data maps (full history) ──────────────────────────────────────────
  Map<String, double> _allOxalate = {};
  Map<String, double> _allWater   = {};

  // ── Chart / display state ─────────────────────────────────────────────────
  ChartTimeframe _selectedTimeframe = ChartTimeframe.d7;
  ChartMetric    _selectedMetric    = ChartMetric.oxalate;
  List<_ChartBar> _chartBars = [];

  // ── Stats ─────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _weeklyData = [];
  int    _currentStreak            = 0;
  int    _bestStreak               = 0;
  double _avgDailyOxalate          = 0;
  double _avgDailyWater            = 0;
  double _oxalateGoal              = 200;
  double _waterGoal                = 80;
  bool   _isLoading                = true;
  int    _totalDaysLogged          = 0;
  int    _longestConsecutiveStreak = 0;
  int    _daysLoggedInRange        = 0;
  Set<String> _celebratedBadges   = {};

  // ── Animation controllers ─────────────────────────────────────────────────
  late ConfettiController _confettiController;
  final Map<String, AnimationController> _badgeAnimControllers = {};
  final Map<String, Animation<double>>   _badgeScaleAnims      = {};

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
  static const Color barWater    = Color(0xFF5BB8D4);
  static const Color barWaterLow = Color(0xFFFFB347);
  static const Color goalLine    = Color(0xFF1A8A9A);

  // ── Badge definitions ─────────────────────────────────────────────────────
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
      'progress': _currentStreak < 3 ? '$_currentStreak / 3 days' : null,
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
          _weeklyData
              .where((d) => d['oxalate'] > 0)
              .every((d) => d['oxalateGoalMet']),
      'progress': null,
      'milestone': false,
    },
    {
      'id': 'champ_7',
      'icon': '🏆',
      'title': '7-Day Champion',
      'desc': 'Met all goals 7 days in a row',
      'unlocked': _currentStreak >= 7,
      'progress': _currentStreak < 7 ? '$_currentStreak / 7 days' : null,
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
      'progress':
          _totalDaysLogged < 180 ? '$_totalDaysLogged / 180 days' : null,
      'milestone': true,
    },
    {
      'id': 'legend_365',
      'icon': '👑',
      'title': '1-Year Legend',
      'desc': 'Logged food for a full year!',
      'unlocked': _totalDaysLogged >= 365,
      'progress':
          _totalDaysLogged < 365 ? '$_totalDaysLogged / 365 days' : null,
      'milestone': true,
    },
    {
      'id': 'diamond_730',
      'icon': '💎',
      'title': '2-Year Diamond',
      'desc': "Logged food for 2 years — you're unstoppable!",
      'unlocked': _totalDaysLogged >= 730,
      'progress':
          _totalDaysLogged < 730 ? '$_totalDaysLogged / 730 days' : null,
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

    final celebratedList = prefs.getStringList('celebrated_badges') ?? [];
    _celebratedBadges = celebratedList.toSet();

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

    final now      = DateTime.now();
    final todayKey = '${now.year}_${now.month}_${now.day}';
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    dailyOxalate[todayStr] = prefs.getDouble('oxalate_$todayKey') ?? 0.0;
    dailyWater[todayStr]   = prefs.getDouble('water_$todayKey')   ?? 0.0;

    final totalDaysLogged = dailyOxalate.values.where((v) => v > 0).length;

    int currentStreak = 0;
    DateTime cursor = now;
    while (true) {
      final key =
          '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
      final ox  = dailyOxalate[key] ?? 0.0;
      final wat = dailyWater[key]   ?? 0.0;
      if (ox > 0 && ox <= _oxalateGoal && wat >= _waterGoal) {
        currentStreak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
      if (cursor.isBefore(now.subtract(const Duration(days: 730)))) break;
    }

    int longestStreak  = 0;
    int runningStreak  = 0;
    final allDates = dailyOxalate.keys
        .where((k) => (dailyOxalate[k] ?? 0) > 0)
        .map((k) => DateTime.tryParse(k))
        .whereType<DateTime>()
        .toList()
      ..sort();

    for (int i = 0; i < allDates.length; i++) {
      final key =
          '${allDates[i].year}-${allDates[i].month.toString().padLeft(2, '0')}-${allDates[i].day.toString().padLeft(2, '0')}';
      final ox  = dailyOxalate[key] ?? 0.0;
      final wat = dailyWater[key]   ?? 0.0;
      if (ox > 0 && ox <= _oxalateGoal && wat >= _waterGoal) {
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

    int best = prefs.getInt('best_streak') ?? 0;
    if (currentStreak > best) {
      best = currentStreak;
      await prefs.setInt('best_streak', best);
    }
    if (longestStreak > best) {
      best = longestStreak;
      await prefs.setInt('best_streak', best);
    }

    const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<Map<String, dynamic>> weeklyData = [];
    for (int i = 6; i >= 0; i--) {
      final day     = now.subtract(Duration(days: i));
      final dateKey =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final ox  = dailyOxalate[dateKey] ?? 0.0;
      final wat = dailyWater[dateKey]   ?? 0.0;
      weeklyData.add({
        'label':          dayLabels[day.weekday % 7],
        'date':           dateKey,
        'oxalate':        ox,
        'water':          wat,
        'oxalateGoalMet': ox > 0 && ox <= _oxalateGoal,
        'waterGoalMet':   wat >= _waterGoal,
      });
    }

    final daysWithOx  = weeklyData.where((d) => (d['oxalate'] as double) > 0).toList();
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
      _allOxalate              = dailyOxalate;
      _allWater                = dailyWater;
      _weeklyData              = weeklyData;
      _currentStreak           = currentStreak;
      _bestStreak              = best;
      _longestConsecutiveStreak = longestStreak;
      _avgDailyOxalate         = avgOx;
      _avgDailyWater           = avgWat;
      _totalDaysLogged         = totalDaysLogged;
      _isLoading               = false;
    });

    _rebuildChartBars();
    await _checkForNewUnlocks(prefs);
  }

  // ── Chart bar builder ─────────────────────────────────────────────────────
  void _rebuildChartBars() {
    final now        = DateTime.now();
    final totalDays  = _selectedTimeframe.days;
    final isOxalate  = _selectedMetric == ChartMetric.oxalate;
    final dataMap    = isOxalate ? _allOxalate : _allWater;
    final goal       = isOxalate ? _oxalateGoal : _waterGoal;

    List<_ChartBar> bars = [];

    if (_selectedTimeframe == ChartTimeframe.d7 ||
        _selectedTimeframe == ChartTimeframe.d30) {
      const dayAbbr = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
      for (int i = totalDays - 1; i >= 0; i--) {
        final day    = now.subtract(Duration(days: i));
        final key    =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final value  = dataMap[key] ?? 0.0;
        final String label = _selectedTimeframe == ChartTimeframe.d7
            ? dayAbbr[day.weekday % 7]
            : '${day.month}/${day.day}';
        bars.add(_ChartBar(label: label, value: value, goal: goal));
      }
    } else if (_selectedTimeframe == ChartTimeframe.m6) {
      for (int w = 25; w >= 0; w--) {
        final weekStart = now.subtract(Duration(days: (w + 1) * 7 - 1));
        double total = 0;
        int    count = 0;
        for (int d = 0; d < 7; d++) {
          final day = weekStart.add(Duration(days: d));
          final key =
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          final v = dataMap[key] ?? 0.0;
          if (v > 0) {
            total += v;
            count++;
          }
        }
        final avg   = count > 0 ? total / count : 0.0;
        final label = 'W${26 - w}';
        bars.add(_ChartBar(label: label, value: avg, goal: goal));
      }
    } else {
      final months = _selectedTimeframe == ChartTimeframe.y1 ? 12 : 24;
      for (int m = months - 1; m >= 0; m--) {
        final targetMonth = DateTime(now.year, now.month - m, 1);
        final yr  = targetMonth.year;
        final mo  = targetMonth.month;
        final daysInMonth = DateUtils.getDaysInMonth(yr, mo);
        double total = 0;
        int    count = 0;
        for (int d = 1; d <= daysInMonth; d++) {
          final key =
              '$yr-${mo.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
          final v = dataMap[key] ?? 0.0;
          if (v > 0) {
            total += v;
            count++;
          }
        }
        final avg = count > 0 ? total / count : 0.0;
        const monthAbbr = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final label = monthAbbr[mo];
        bars.add(_ChartBar(label: label, value: avg, goal: goal));
      }
    }

    final logged = bars.where((b) => b.value > 0).toList();
    final avgInRange = logged.isEmpty
        ? 0.0
        : logged.fold(0.0, (s, b) => s + b.value) / logged.length;

    setState(() {
      _chartBars          = bars;
      _daysLoggedInRange  = logged.length;
      if (_selectedMetric == ChartMetric.oxalate) {
        _avgDailyOxalate = avgInRange;
      } else {
        _avgDailyWater = avgInRange;
      }
    });
  }

  void _onTimeframeChanged(ChartTimeframe tf) {
    setState(() => _selectedTimeframe = tf);
    _rebuildChartBars();
  }

  void _onMetricChanged(ChartMetric m) {
    setState(() => _selectedMetric = m);
    _rebuildChartBars();
  }

  Future<void> _checkForNewUnlocks(SharedPreferences prefs) async {
    for (final badge in _achievements) {
      final id          = badge['id']       as String;
      final unlocked    = badge['unlocked'] as bool;
      final isMilestone = badge['milestone'] as bool;

      if (unlocked && !_celebratedBadges.contains(id)) {
        _celebratedBadges.add(id);
        await prefs.setStringList(
            'celebrated_badges', _celebratedBadges.toList());
        _triggerBadgePop(id);
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        if (isMilestone) {
          _confettiController.play();
          HapticFeedback.heavyImpact();
        }
        _showAchievementModal(badge);
        break;
      }
    }
  }

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

  void _showAchievementModal(Map<String, dynamic> badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AchievementModal(
        badge: badge,
        isMilestone: badge['milestone'] as bool,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: accentTeal));
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
                Row(children: [
                  Expanded(
                      child: _buildStreakCard('🔥 Current Streak',
                          '$_currentStreak days', Colors.deepOrange)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStreakCard(
                          '🏆 Best Streak', '$_bestStreak days', accentGold)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: _buildStatCard(
                      '⚗️ Avg Oxalate',
                      '${_avgDailyOxalate.toStringAsFixed(0)} mg/day',
                      _avgDailyOxalate <= _oxalateGoal
                          ? accentGreen
                          : Colors.redAccent,
                      subtitle: _selectedTimeframe.label,
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
                      subtitle: _selectedTimeframe.label,
                    ),
                  ),
                ]),

                const SizedBox(height: 20),
                _buildChartHeader(),
                const SizedBox(height: 10),
                _buildTimeframeSelector(),
                const SizedBox(height: 10),
                _buildMetricToggle(),
                const SizedBox(height: 10),
                _buildBarChart(),
                const SizedBox(height: 8),
                _buildDaysLoggedBadge(),
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

  Widget _buildChartHeader() {
    final isOxalate = _selectedMetric == ChartMetric.oxalate;
    final String title = isOxalate
        ? '${_selectedTimeframe.label} Oxalate Intake'
        : '${_selectedTimeframe.label} Water Intake';
    final String subtitle = _getTimeframeSubtitle();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: const TextStyle(color: mutedColor, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  String _getTimeframeSubtitle() {
    switch (_selectedTimeframe) {
      case ChartTimeframe.d7:  return 'Daily values — last 7 days';
      case ChartTimeframe.d30: return 'Daily values — last 30 days';
      case ChartTimeframe.m6:  return 'Weekly averages — last 6 months';
      case ChartTimeframe.y1:  return 'Monthly averages — last 12 months';
      case ChartTimeframe.y2:  return 'Monthly averages — last 2 years';
    }
  }

  Widget _buildTimeframeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ChartTimeframe.values.map((tf) {
          final selected = tf == _selectedTimeframe;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onTimeframeChanged(tf),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? accentTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: accentTeal.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ]
                      : [],
                ),
                child: Text(
                  tf.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : mutedColor,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricToggle() {
    return Row(
      children: [
        _metricChip(
          label: '⚗️ Oxalate',
          selected: _selectedMetric == ChartMetric.oxalate,
          onTap: () => _onMetricChanged(ChartMetric.oxalate),
          activeColor: accentTeal,
        ),
        const SizedBox(width: 8),
        _metricChip(
          label: '💧 Water',
          selected: _selectedMetric == ChartMetric.water,
          onTap: () => _onMetricChanged(ChartMetric.water),
          activeColor: barWater,
        ),
      ],
    );
  }

  Widget _metricChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? activeColor : mutedColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Bar chart ─────────────────────────────────────────────────────────────
  // FIX: Each bar column is a fully-constrained SizedBox(height: _kTotalH).
  // The three layers (value label / bar area / x-axis label) are all fixed
  // SizedBoxes so Flutter never needs to measure unbounded children, which
  // was what caused the black-and-yellow overflow stripes.
  static const double _kBarAreaH    = 110.0; // usable drawing area for bars
  static const double _kValueLabelH =  14.0; // top slot for the value text
  static const double _kXLabelH     =  14.0; // bottom slot for the x-axis text
  static const double _kTotalH =
      _kValueLabelH + _kBarAreaH + _kXLabelH;      // 138 px total, never exceeded

  Widget _buildBarChart() {
    if (_chartBars.isEmpty) return _buildEmptyChart();

    final isOxalate = _selectedMetric == ChartMetric.oxalate;
    final goal      = isOxalate ? _oxalateGoal : _waterGoal;
    final maxValue  = _chartBars.fold(0.0, (m, b) => b.value > m ? b.value : m);
    final chartMax  = maxValue < goal ? goal * 1.2 : maxValue * 1.2;

    final showEveryN = _selectedTimeframe == ChartTimeframe.d30
        ? 5
        : _selectedTimeframe == ChartTimeframe.m6
            ? 4
            : _selectedTimeframe == ChartTimeframe.y2
                ? 2
                : 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Legend row
          Row(children: [
            _legendDot(
                isOxalate ? barOk : barWater,
                isOxalate ? 'Under goal' : 'Met goal'),
            const SizedBox(width: 12),
            _legendDot(
                isOxalate ? barOver : barWaterLow,
                isOxalate ? 'Over goal' : 'Under goal'),
          ]),
          const SizedBox(height: 10),

          // ── Fixed-height chart area ───────────────────────────────────────
          // ClipRect prevents any child from painting outside _kTotalH.
          ClipRect(
            child: SizedBox(
              height: _kTotalH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_chartBars.length, (idx) {
                  final bar   = _chartBars[idx];
                  // Clamp bar height strictly inside [2, _kBarAreaH]
                  final barH  = chartMax > 0
                      ? (bar.value / chartMax * _kBarAreaH)
                          .clamp(2.0, _kBarAreaH)
                      : 2.0;
                  // Goal-line position from bottom of bar area
                  final goalH = chartMax > 0
                      ? (goal / chartMax * _kBarAreaH)
                          .clamp(0.0, _kBarAreaH)
                      : 0.0;

                  Color barColor;
                  if (bar.value == 0) {
                    barColor = barEmpty;
                  } else if (isOxalate) {
                    barColor = bar.value > goal ? barOver : barOk;
                  } else {
                    barColor = bar.value >= goal ? barWater : barWaterLow;
                  }

                  final showLabel = idx % showEveryN == 0;
                  final showValue = bar.value > 0 &&
                      (_selectedTimeframe == ChartTimeframe.d7 ||
                          _selectedTimeframe == ChartTimeframe.d30);

                  final barWidth = _selectedTimeframe == ChartTimeframe.d7
                      ? 22.0
                      : _selectedTimeframe == ChartTimeframe.d30
                          ? 8.0
                          : _selectedTimeframe == ChartTimeframe.m6
                              ? 8.0
                              : 12.0;

                  return Expanded(
                    child: SizedBox(
                      height: _kTotalH,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ① Value label — fixed height slot
                          SizedBox(
                            height: _kValueLabelH,
                            child: showValue
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      bar.value >= 1000
                                          ? '${(bar.value / 1000).toStringAsFixed(1)}k'
                                          : bar.value.toStringAsFixed(0),
                                      style: const TextStyle(
                                          color: mutedColor, fontSize: 7),
                                      overflow: TextOverflow.visible,
                                      softWrap: false,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // ② Bar + goal line — fixed height slot
                          SizedBox(
                            height: _kBarAreaH,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                // Bar
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 350),
                                    curve: Curves.easeOut,
                                    width: barWidth,
                                    height: barH,
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                // Goal dashed line
                                Positioned(
                                  bottom: goalH,
                                  child: Container(
                                    width: _selectedTimeframe ==
                                            ChartTimeframe.d7
                                        ? 26.0
                                        : barWidth + 2,
                                    height: 1.5,
                                    color: goalLine.withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ③ X-axis label — fixed height slot
                          SizedBox(
                            height: _kXLabelH,
                            child: showLabel
                                ? Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(top: 3),
                                      child: Text(
                                        bar.label,
                                        style: const TextStyle(
                                            color: mutedColor,
                                            fontSize: 9),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Goal line key
          const SizedBox(height: 6),
          Row(children: [
            Container(
                width: 18,
                height: 2,
                color: goalLine.withValues(alpha: 0.45)),
            const SizedBox(width: 4),
            Text(
              isOxalate
                  ? 'Goal: ${_oxalateGoal.toStringAsFixed(0)} mg'
                  : 'Goal: ${_waterGoal.toStringAsFixed(0)} oz',
              style: const TextStyle(color: mutedColor, fontSize: 10),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: mutedColor, fontSize: 11)),
    ]);
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, color: mutedColor, size: 36),
            SizedBox(height: 8),
            Text('No data for this period',
                style: TextStyle(color: mutedColor, fontSize: 13)),
            SizedBox(height: 4),
            Text('Start logging to see your trends',
                style: TextStyle(color: mutedColor, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysLoggedBadge() {
    final totalBars = _chartBars.length;
    if (totalBars == 0) return const SizedBox.shrink();

    final percent = totalBars > 0
        ? (_daysLoggedInRange / totalBars * 100).clamp(0, 100).toInt()
        : 0;

    final unitLabel = (_selectedTimeframe == ChartTimeframe.m6)
        ? 'weeks'
        : (_selectedTimeframe == ChartTimeframe.y1 ||
                _selectedTimeframe == ChartTimeframe.y2)
            ? 'months'
            : 'days';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accentTeal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: accentTeal, size: 16),
          const SizedBox(width: 8),
          Text(
            '$_daysLoggedInRange of $totalBars $unitLabel logged  •  $percent%',
            style: const TextStyle(
                color: accentTeal, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Text(title, style: const TextStyle(color: mutedColor, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildStatCard(String title, String value, Color color,
      {String? subtitle}) {
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
      child: Column(children: [
        Text(title, style: const TextStyle(color: mutedColor, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(color: mutedColor, fontSize: 10)),
        ],
      ]),
    );
  }

  Widget _buildDayRow(Map<String, dynamic> day) {
    final oxalate      = day['oxalate']        as double;
    final water        = day['water']          as double;
    final oxGoalMet    = day['oxalateGoalMet'] as bool;
    final waterGoalMet = day['waterGoalMet']   as bool;
    final bothMet      = oxGoalMet && waterGoalMet;
    final noData       = oxalate == 0 && water == 0;

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
                  ? Row(children: [
                      Icon(Icons.remove_circle_outline,
                          color: mutedColor.withValues(alpha: 0.5), size: 16),
                      const SizedBox(width: 6),
                      const Text('No data logged',
                          style: TextStyle(
                              color: mutedColor,
                              fontSize: 13,
                              fontStyle: FontStyle.italic)),
                    ])
                  : Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('OXALATE',
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
                                value:
                                    (oxalate / _oxalateGoal).clamp(0.0, 1.0),
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
                          margin:
                              const EdgeInsets.symmetric(horizontal: 12),
                          color: borderColor),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('WATER',
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
                    ]),
            ),
            if (!noData) ...[
              const SizedBox(width: 10),
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
    return Column(
      children: _achievements.map((a) {
        final id          = a['id']       as String;
        final unlocked    = a['unlocked'] as bool;
        final progress    = a['progress'] as String?;
        final isMilestone = a['milestone'] as bool;
        final scaleAnim   = _badgeScaleAnims[id];

        Widget card = Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unlocked
                ? (isMilestone
                    ? const Color(0xFFFFF8E1)
                    : const Color(0xFFF0FAF4))
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
              Text(
                a['icon'] as String,
                style: TextStyle(
                  fontSize: 28,
                  color: unlocked
                      ? null
                      : Colors.grey.withValues(alpha: 0.35),
                ),
              ),
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
                    Text(a['desc'] as String,
                        style: const TextStyle(
                            color: mutedColor, fontSize: 12)),
                    if (!unlocked && progress != null) ...[
                      const SizedBox(height: 4),
                      Text(progress,
                          style: TextStyle(
                            color: accentTeal.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          )),
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

// ── Chart bar data model ──────────────────────────────────────────────────────
class _ChartBar {
  final String label;
  final double value;
  final double goal;
  const _ChartBar({required this.label, required this.value, required this.goal});
}

// ── Achievement Unlock Modal ──────────────────────────────────────────────────
class _AchievementModal extends StatefulWidget {
  final Map<String, dynamic> badge;
  final bool isMilestone;
  const _AchievementModal({required this.badge, required this.isMilestone});

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
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ScaleTransition(
              scale: _scaleAnim,
              child: Text(badge['icon'] as String,
                  style: const TextStyle(fontSize: 72)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            Text(badge['title'] as String,
                style: const TextStyle(
                    color: Color(0xFF2C2C2C),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(badge['desc'] as String,
                style:
                    const TextStyle(color: Color(0xFF888888), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
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
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Awesome! 🙌',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
