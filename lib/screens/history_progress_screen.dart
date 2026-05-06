// ─── HISTORY & PROGRESS SCREEN ────────────────────────────────────────────────────────────
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

// ─── Badge definitions (must match home_shield_screen.dart) ───────────────────────────
const List<Map<String, dynamic>> _kAllBadges = [
  {'id': 'first_log',     'icon': '🥇', 'label': 'First Log',       'desc': 'Log your first food item.',            'milestone': false},
  {'id': 'streak_3',      'icon': '🔥', 'label': '3-Day Streak',    'desc': 'Stay on track 3 days in a row.',       'milestone': false},
  {'id': 'hydration_hero','icon': '💧', 'label': 'Hydration Hero',  'desc': 'Hit your water goal for the day.',     'milestone': false},
  {'id': 'stone_guardian','icon': '🛡️', 'label': 'Stone Guardian', 'desc': 'Stay under oxalate limit all week.',   'milestone': false},
  {'id': 'champ_7',       'icon': '🏆', 'label': '7-Day Champ',    'desc': 'Complete a full 7-day streak.',        'milestone': true},
  {'id': 'logger_14',     'icon': '📅', 'label': '14-Day Logger',  'desc': 'Log consistently for 14 days.',        'milestone': false},
  {'id': 'habit_21',      'icon': '🌟', 'label': '21-Day Habit',   'desc': 'Build a 21-day stone-free habit.',     'milestone': false},
  {'id': 'warrior_30',    'icon': '🥈', 'label': '30-Day Warrior', 'desc': 'Reach a 30-day streak.',               'milestone': true},
  {'id': 'streak_30',     'icon': '⚡',  'label': '30-Day Power',   'desc': 'Log every day for 30 days.',           'milestone': true},
  {'id': 'guardian_90',   'icon': '🎖️', 'label': '90-Day Guard',  'desc': 'Maintain protection for 90 days.',     'milestone': true},
  {'id': 'defender_180',  'icon': '🥉', 'label': '180-Day Def.', 'desc': 'Half a year stone-free.',              'milestone': true},
  {'id': 'legend_365',    'icon': '👑', 'label': 'Year Legend',    'desc': 'One full year stone-free.',            'milestone': true},
  {'id': 'diamond_730',   'icon': '💎', 'label': 'Diamond 2yr',   'desc': 'Two years of stone prevention.',       'milestone': true},
];

// ─── Parsed day record ───────────────────────────────────────────────────────────────────────────
class _DayRecord {
  final DateTime date;
  final double waterOz;
  final double oxalateMg;
  const _DayRecord(
      {required this.date,
      required this.waterOz,
      required this.oxalateMg});
}

// ─── Screen ─────────────────────────────────────────────────────────────────────────────
class HistoryProgressScreen extends StatefulWidget {
  const HistoryProgressScreen({super.key});

  @override
  State<HistoryProgressScreen> createState() => _HistoryProgressScreenState();
}

class _HistoryProgressScreenState extends State<HistoryProgressScreen> {
  bool _loading = true;
  List<_DayRecord> _history = [];
  Set<String> _unlockedBadges = {};
  double _goalWater = 80;
  double _goalOxalate = 200;
  int _stoneFreeStreak = 0;

  // ── Chart window: 7, 14, or 30 days
  int _chartDays = 14;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Goals
    final gw = prefs.getDouble('goal_water')   ?? 80;
    final go = prefs.getDouble('goal_oxalate') ?? 200;

    // Daily history
    final raw = prefs.getStringList('daily_history') ?? [];
    final records = raw.map((e) {
      final m = Map<String, dynamic>.from(jsonDecode(e));
      final parts = (m['date'] as String).split('-');
      return _DayRecord(
        date:      DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
        waterOz:   (m['water_oz']   as num).toDouble(),
        oxalateMg: (m['oxalate_mg'] as num).toDouble(),
      );
    }).toList();
    records.sort((a, b) => a.date.compareTo(b.date));

    // Stone-free streak = consecutive days under oxalate goal (most recent first)
    final reversed = records.reversed.toList();
    int streak = 0;
    for (final r in reversed) {
      if (r.oxalateMg <= go) {
        streak++;
      } else {
        break;
      }
    }

    // Badges
    final badgeList = prefs.getStringList('celebrated_badges') ?? [];

    if (!mounted) return;
    setState(() {
      _goalWater    = gw;
      _goalOxalate  = go;
      _history      = records;
      _stoneFreeStreak = streak;
      _unlockedBadges = badgeList.toSet();
      _loading      = false;
    });
  }

  // Last N days of records (padded with zeros for missing days)
  List<_DayRecord> _recentDays(int n) {
    final today = DateTime.now();
    return List.generate(n, (i) {
      final d = today.subtract(Duration(days: n - 1 - i));
      final match = _history.where((r) =>
          r.date.year == d.year &&
          r.date.month == d.month &&
          r.date.day == d.day);
      if (match.isNotEmpty) return match.first;
      return _DayRecord(date: d, waterOz: 0, oxalateMg: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final surfaceCol = isDark ? AppColors.darkSurface     : AppColors.surface;
    final borderCol  = isDark ? AppColors.darkBorder      : AppColors.border;
    final bgCol      = isDark ? AppColors.darkBackground  : AppColors.background;
    final textPri    = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMut    = isDark ? AppColors.darkTextSecond  : AppColors.textSecond;
    final textFaint  = isDark ? AppColors.darkTextHint    : AppColors.textHint;

    if (_loading) {
      return GradientScaffold(
        title: 'Progress History',
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final days = _recentDays(_chartDays);
    final totalLogged = _history.length;
    final avgWater = totalLogged > 0
        ? _history.fold(0.0, (s, r) => s + r.waterOz) / totalLogged
        : 0.0;
    final avgOxalate = totalLogged > 0
        ? _history.fold(0.0, (s, r) => s + r.oxalateMg) / totalLogged
        : 0.0;
    final bestStreak = _stoneFreeStreak;
    final daysUnderGoal = _history.where((r) => r.oxalateMg <= _goalOxalate && r.oxalateMg > 0).length;
    final compliance = totalLogged > 0 ? (daysUnderGoal / totalLogged * 100).round() : 0;

    return GradientScaffold(
      title: 'Progress History',
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [

            // ── STREAK HERO CARD ──────────────────────────────────────────
            _card(
              isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
              accentColor: const Color(0xFFFF8C00),
              child: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C00).withValues(alpha: isDark ? 0.20 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '🔥',
                        style: TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stone-Free Streak',
                            style: TextStyle(fontSize: 12, color: textMut,
                                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(
                          '$_stoneFreeStreak',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF8C00),
                            height: 1.0,
                          ),
                        ),
                        Text(
                          _stoneFreeStreak == 1 ? 'day under your oxalate goal' : 'days under your oxalate goal',
                          style: TextStyle(fontSize: 13, color: textMut),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── STATS ROW ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _statTile(
                  isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.primary,
                  value: '$totalLogged',
                  label: 'Days Logged',
                  textPri: textPri, textMut: textMut,
                )),
                const SizedBox(width: 10),
                Expanded(child: _statTile(
                  isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
                  icon: Icons.verified_outlined,
                  iconColor: const Color(0xFF4CAF50),
                  value: '$compliance%',
                  label: 'Oxalate Compliance',
                  textPri: textPri, textMut: textMut,
                )),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _statTile(
                  isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF00BCD4),
                  value: '${avgWater.toStringAsFixed(0)} oz',
                  label: 'Avg Daily Water',
                  textPri: textPri, textMut: textMut,
                )),
                const SizedBox(width: 10),
                Expanded(child: _statTile(
                  isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
                  icon: Icons.science_outlined,
                  iconColor: AppColors.oxalate,
                  value: '${avgOxalate.toStringAsFixed(0)} mg',
                  label: 'Avg Daily Oxalate',
                  textPri: textPri, textMut: textMut,
                )),
              ],
            ),

            const SizedBox(height: 16),

            // ── WATER CHART ──────────────────────────────────────────────────
            _cardWithHeader(
              isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
              icon: Icons.water_drop_outlined,
              iconColor: const Color(0xFF00BCD4),
              title: 'Hydration',
              trailing: _chartWindowSelector(isDark, textMut),
              child: _BarChart(
                days: days,
                getValue: (r) => r.waterOz,
                goal: _goalWater,
                barColor: const Color(0xFF00BCD4),
                goalColor: const Color(0xFF00BCD4),
                maxValue: max(_goalWater, days.fold(0.0, (m, r) => r.waterOz > m ? r.waterOz : m)) * 1.15,
                isDark: isDark,
                borderCol: borderCol,
                textFaint: textFaint,
                unit: 'oz',
              ),
            ),

            const SizedBox(height: 12),

            // ── OXALATE CHART ───────────────────────────────────────────────
            _cardWithHeader(
              isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
              icon: Icons.science_outlined,
              iconColor: AppColors.oxalate,
              title: 'Daily Oxalate',
              child: _BarChart(
                days: days,
                getValue: (r) => r.oxalateMg,
                goal: _goalOxalate,
                barColor: AppColors.oxalate,
                goalColor: AppColors.oxalate,
                maxValue: max(_goalOxalate, days.fold(0.0, (m, r) => r.oxalateMg > m ? r.oxalateMg : m)) * 1.15,
                isDark: isDark,
                borderCol: borderCol,
                textFaint: textFaint,
                unit: 'mg',
              ),
            ),

            const SizedBox(height: 16),

            // ── DAILY LOG TABLE ────────────────────────────────────────────
            _cardWithHeader(
              isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
              icon: Icons.history_outlined,
              iconColor: AppColors.primary,
              title: 'Recent Days',
              child: _history.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No data yet. Start logging on the Home tab!',
                        style: TextStyle(color: textMut, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: _history.reversed.take(30).map((r) {
                        final waterOk = r.waterOz >= _goalWater;
                        final oxOk    = r.oxalateMg <= _goalOxalate && r.oxalateMg > 0;
                        final label   = '${r.date.month}/${r.date.day}/${r.date.year.toString().substring(2)}';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: bgCol,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderCol),
                          ),
                          child: Row(
                            children: [
                              Text(label,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textPri)),
                              const Spacer(),
                              Icon(Icons.water_drop_outlined,
                                  size: 13,
                                  color: waterOk
                                      ? const Color(0xFF00BCD4)
                                      : textFaint),
                              const SizedBox(width: 3),
                              Text(
                                '${r.waterOz.toStringAsFixed(0)} oz',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: waterOk
                                        ? const Color(0xFF00BCD4)
                                        : textMut),
                              ),
                              const SizedBox(width: 14),
                              Icon(Icons.science_outlined,
                                  size: 13,
                                  color: oxOk
                                      ? const Color(0xFF4CAF50)
                                      : (r.oxalateMg > _goalOxalate
                                          ? AppColors.oxalate
                                          : textFaint)),
                              const SizedBox(width: 3),
                              Text(
                                '${r.oxalateMg.toStringAsFixed(0)} mg',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: oxOk
                                        ? const Color(0xFF4CAF50)
                                        : (r.oxalateMg > _goalOxalate
                                            ? AppColors.oxalate
                                            : textMut)),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                oxOk && waterOk
                                    ? Icons.check_circle_outline
                                    : Icons.radio_button_unchecked,
                                size: 16,
                                color: oxOk && waterOk
                                    ? const Color(0xFF4CAF50)
                                    : textFaint,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 16),

            // ── BADGES ───────────────────────────────────────────────────────────────
            _cardWithHeader(
              isDark: isDark, surfaceCol: surfaceCol, borderCol: borderCol,
              icon: Icons.emoji_events_outlined,
              iconColor: const Color(0xFFD4A020),
              title: 'Achievements',
              child: Column(
                children: [
                  // Progress bar
                  Row(
                    children: [
                      Text(
                        '${_unlockedBadges.length} / ${_kAllBadges.length} unlocked',
                        style: TextStyle(fontSize: 12, color: textMut),
                      ),
                      const Spacer(),
                      Text(
                        '${(_unlockedBadges.length / _kAllBadges.length * 100).round()}%',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4A020)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _kAllBadges.isEmpty
                          ? 0
                          : _unlockedBadges.length / _kAllBadges.length,
                      minHeight: 7,
                      backgroundColor: borderCol,
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFD4A020)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Badge grid
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                    children: _kAllBadges.map((b) {
                      final unlocked = _unlockedBadges.contains(b['id']);
                      final isMile   = b['milestone'] as bool;
                      return Column(
                        children: [
                          Container(
                            width: 54, height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: unlocked
                                  ? (isMile
                                      ? const Color(0xFFD4A020).withValues(alpha: isDark ? 0.22 : 0.14)
                                      : AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12))
                                  : (isDark ? Colors.white10 : Colors.grey.shade100),
                              border: Border.all(
                                color: unlocked
                                    ? (isMile
                                        ? const Color(0xFFD4A020).withValues(alpha: 0.5)
                                        : AppColors.primary.withValues(alpha: 0.4))
                                    : (isDark ? Colors.white24 : Colors.grey.shade300),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: unlocked
                                  ? Text(b['icon'] as String,
                                      style: const TextStyle(fontSize: 26))
                                  : Icon(Icons.lock_outline,
                                      size: 20,
                                      color: isDark
                                          ? Colors.white30
                                          : Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b['label'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              color: unlocked ? textPri : textFaint,
                              fontWeight: unlocked
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ── Chart window selector ────────────────────────────────────────────────────
  Widget _chartWindowSelector(bool isDark, Color textMut) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [7, 14, 30].map((n) {
        final active = _chartDays == n;
        return GestureDetector(
          onTap: () => setState(() => _chartDays = n),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Text(
              '${n}d',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : textMut,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Reusable card builders ────────────────────────────────────────────────────────────────
Widget _card({
  required bool isDark,
  required Color surfaceCol,
  required Color borderCol,
  Color? accentColor,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: surfaceCol,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: accentColor?.withValues(alpha: 0.3) ?? borderCol),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

Widget _cardWithHeader({
  required bool isDark,
  required Color surfaceCol,
  required Color borderCol,
  required IconData icon,
  required Color iconColor,
  required String title,
  Widget? trailing,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: surfaceCol,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderCol),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

Widget _statTile({
  required bool isDark,
  required Color surfaceCol,
  required Color borderCol,
  required IconData icon,
  required Color iconColor,
  required String value,
  required String label,
  required Color textPri,
  required Color textMut,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: surfaceCol,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderCol),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPri)),
              Text(label,
                  style: TextStyle(fontSize: 10, color: textMut)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ─── Pure-Flutter bar chart (no external package needed) ─────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<_DayRecord> days;
  final double Function(_DayRecord) getValue;
  final double goal;
  final double maxValue;
  final Color barColor;
  final Color goalColor;
  final bool isDark;
  final Color borderCol;
  final Color textFaint;
  final String unit;

  const _BarChart({
    required this.days,
    required this.getValue,
    required this.goal,
    required this.maxValue,
    required this.barColor,
    required this.goalColor,
    required this.isDark,
    required this.borderCol,
    required this.textFaint,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    const chartHeight = 110.0;
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;
    final goalRatio = (goal / safeMax).clamp(0.0, 1.0);

    return SizedBox(
      height: chartHeight + 24,
      child: Stack(
        children: [
          // Goal line
          Positioned(
            top: chartHeight * (1 - goalRatio),
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  child: DashedLine(
                    color: goalColor.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Goal',
                  style: TextStyle(
                      fontSize: 9,
                      color: goalColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Bars
          Positioned(
            top: 0, left: 0, right: 0,
            height: chartHeight + 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((r) {
                final v = getValue(r);
                final ratio = (v / safeMax).clamp(0.0, 1.0);
                final barH = (ratio * chartHeight).clamp(2.0, chartHeight);
                final hasData = v > 0;
                final meetsGoal = unit == 'oz' ? v >= goal : v <= goal;
                final barCol = hasData
                    ? (meetsGoal
                        ? barColor
                        : barColor.withValues(alpha: 0.45))
                    : (isDark ? Colors.white10 : Colors.grey.shade200);
                final isToday = r.date.year == DateTime.now().year &&
                    r.date.month == DateTime.now().month &&
                    r.date.day == DateTime.now().day;
                final shortDay = _shortDay(r.date);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bar
                        Container(
                          height: barH,
                          decoration: BoxDecoration(
                            color: barCol,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            border: isToday
                                ? Border.all(
                                    color: barColor, width: 1.5)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Day label
                        Text(
                          shortDay,
                          style: TextStyle(
                            fontSize: 8,
                            color: isToday ? barColor : textFaint,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _shortDay(DateTime d) {
    final days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return days[d.weekday % 7];
  }
}

// Simple dashed line painter
class DashedLine extends StatelessWidget {
  final Color color;
  const DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(color: color),
      size: const Size(double.infinity, 1),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
