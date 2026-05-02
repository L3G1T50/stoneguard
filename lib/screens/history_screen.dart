import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'doctor_view_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _history = [];
  double _waterGoal = 80;
  int? _selectedIndex;
  int _selectedDays = 7;

  // ── Light theme palette ───────────────────────────────────────────────────
  static const Color _bg         = Color(0xFFF8F8F8);
  static const Color _surface    = Color(0xFFFFFFFF);
  static const Color _surface2   = Color(0xFFF1F4F8);
  static const Color _border     = Color(0xFFE0E4EA);
  static const Color _textPri    = Color(0xFF1A1A2E);
  static const Color _textMuted  = Color(0xFF6B7280);
  static const Color _textFaint  = Color(0xFFB0B7C3);
  static const Color _accent     = Color(0xFF00BCD4);
  static const Color _accentDark = Color(0xFF0097A7);
  static const Color _accentSel  = Color(0xFF00E5FF);
  static const Color _gridLine   = Color(0xFFE8ECF0);
  static const Color _barMissed  = Color(0xFFCFD8DC);

  @override
  bool get wantKeepAlive => true;

  final List<Map<String, dynamic>> _timeframes = [
    {'label': '7D',  'days': 7},
    {'label': '30D', 'days': 30},
    {'label': '6M',  'days': 180},
    {'label': '1Y',  'days': 365},
    {'label': '2Y',  'days': 730},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final goal  = prefs.getDouble('goal_water') ?? 80;
    final now   = DateTime.now();
    final List<Map<String, dynamic>> days = [];

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final y = date.year;
      final m = date.month;
      final d = date.day;

      final water   = prefs.getDouble('water_${y}_${m}_$d') ?? 0;
      final oxalate = prefs.getDouble('oxalate_${y}_${m}_$d') ?? 0;
      final rawLog  = prefs.getStringList('oxalate_log_${y}_${m}_$d') ?? [];

      final foodLog = rawLog.map((entry) {
        final parts = entry.split('|');
        return {
          'name': parts.isNotEmpty ? parts[0] : 'Unknown',
          'mg': parts.length > 1 ? double.tryParse(parts[1]) ?? 0.0 : 0.0,
        };
      }).toList();

      String dateLabel;
      if (_selectedDays <= 30) {
        dateLabel =
            '${m.toString().padLeft(2, '0')}/${d.toString().padLeft(2, '0')}';
      } else {
        dateLabel =
            '${m.toString().padLeft(2, '0')}/${d.toString().padLeft(2, '0')}'
            '\n${y.toString().substring(2)}';
      }

      days.add({
        'date': dateLabel,
        'fullDate':
            '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}',
        'water_oz':    water,
        'oxalate_mg':  oxalate,
        'food_log':    foodLog,
      });
    }

    setState(() {
      _history       = days;
      _waterGoal     = goal;
      _selectedIndex = null;
    });
  }

  Color _oxColor(double mg) {
    if (mg >= 100) return const Color(0xFFE53935);
    if (mg >= 50)  return const Color(0xFFFFA726);
    if (mg >= 25)  return const Color(0xFFFFB300);
    return const Color(0xFF43A047);
  }

  List<Map<String, dynamic>> get _chartData {
    if (_selectedDays <= 30) return _history;

    final groupSize = _selectedDays <= 180 ? 7 : 30;
    final List<Map<String, dynamic>> grouped = [];

    for (int i = 0; i < _history.length; i += groupSize) {
      final chunk    = _history.skip(i).take(groupSize).toList();
      final avgWater = chunk.fold(0.0, (s, d) => s + (d['water_oz']   as num)) / chunk.length;
      final avgOx    = chunk.fold(0.0, (s, d) => s + (d['oxalate_mg'] as num)) / chunk.length;
      final label    = chunk.first['date'].toString().split('\n').first;
      grouped.add({
        'date':       label,
        'water_oz':   avgWater,
        'oxalate_mg': avgOx,
        'food_log':   <Map<String, dynamic>>[],
        'isGrouped':  true,
        'groupLabel': groupSize == 7 ? 'Week of $label' : 'Month of $label',
      });
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final chartData = _chartData;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _selectedDays <= 7   ? '7-Day History'   :
          _selectedDays <= 30  ? '30-Day History'  :
          _selectedDays <= 180 ? '6-Month History' :
          _selectedDays <= 365 ? '1-Year History'  : '2-Year History',
          style: const TextStyle(
            color: _textPri,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: _textPri),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_information, color: _accentDark),
            tooltip: 'Doctor view',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DoctorViewScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share, color: _accentDark),
            tooltip: 'Export for doctor',
            onPressed: _showExportSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── DOCTOR TOOLS HINT ──────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accent.withValues(alpha: 0.18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.local_hospital, color: _accentDark, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use the icons in the top right to view charts for your doctor and export a summary of your last 30 days up to 2 years.',
                      style: TextStyle(
                        color: _accentDark,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── TIMEFRAME SELECTOR ─────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _timeframes.map((tf) {
                  final isSelected = _selectedDays == tf['days'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDays = tf['days'] as int);
                      _loadHistory();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _accent : _surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _accent : _border,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: _accent.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Text(
                        tf['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // ── CHART TITLE ────────────────────────────────────────────────
            Text(
              _selectedDays <= 30  ? 'DAILY WATER INTAKE (oz)'       :
              _selectedDays <= 180 ? 'WEEKLY AVG WATER INTAKE (oz)'  :
                                     'MONTHLY AVG WATER INTAKE (oz)',
              style: const TextStyle(
                color: _textMuted,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // ── CHART ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (_waterGoal * 1.3).toDouble(),
                    barTouchData: BarTouchData(
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent && response?.spot != null) {
                          final idx = response!.spot!.touchedBarGroupIndex;
                          setState(() {
                            _selectedIndex = _selectedIndex == idx ? null : idx;
                          });
                        }
                      },
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => _textPri,
                        getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                          '${rod.toY.toInt()} oz',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: _selectedDays == 30 ? 40 : 28,
                          getTitlesWidget: (value, _) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= chartData.length) return const SizedBox();

                            int step;
                            if      (_selectedDays <= 7) {
                              step = 1;
                            } else if (_selectedDays <= 30)  step = 5;
                            else if (_selectedDays <= 180) step = 4;
                            else if (_selectedDays <= 365) step = 2;
                            else                           step = 3;

                            if (idx % step != 0) return const SizedBox();

                            final String label;
                            if (_selectedDays <= 30) {
                              final parts = chartData[idx]['date'].toString().split('/');
                              label = parts.length >= 2 ? '/${parts[1]}' : chartData[idx]['date'].toString();
                            } else {
                              label = chartData[idx]['date'].toString().split('\n').first;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Transform.rotate(
                                angle: _selectedDays == 30 ? -0.5 : 0,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: _selectedIndex == idx ? _accent : _textFaint,
                                    fontSize: _selectedDays <= 7 ? 9 : 8,
                                    fontWeight: _selectedIndex == idx ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(color: _textFaint, fontSize: 10),
                          ),
                        ),
                      ),
                      topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (_) => const FlLine(color: _gridLine, strokeWidth: 1),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(chartData.length, (i) {
                      final oz       = (chartData[i]['water_oz'] as num).toDouble();
                      final isSel    = _selectedIndex == i;
                      final hitGoal  = oz >= _waterGoal;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: oz,
                            width: _selectedDays <= 7  ? (isSel ? 26 : 20)
                                 : _selectedDays <= 30 ? (isSel ? 14 : 10)
                                 :                       (isSel ? 8  : 5),
                            borderRadius: BorderRadius.circular(4),
                            color: isSel ? _accentSel : hitGoal ? _accent : _barMissed,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: _waterGoal.toDouble(),
                              color: _surface2,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── LEGEND ─────────────────────────────────────────────────────
            Row(
              children: [
                _dot(_accent,     'Goal met'),
                const SizedBox(width: 16),
                _dot(_barMissed,  'Goal missed'),
                const SizedBox(width: 16),
                _dot(_accentSel,  'Selected'),
              ],
            ),

            const SizedBox(height: 24),

            // ── SUMMARY STATS ──────────────────────────────────────────────
            if (_selectedDays > 7) _buildSummaryStats(),

            // ── TAP HINT ───────────────────────────────────────────────────
            if (_selectedIndex == null && _selectedDays <= 30)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    '👆 Tap a bar to see that day\'s food log',
                    style: const TextStyle(color: _textMuted, fontSize: 13),
                  ),
                ),
              ),

            // ── EXPANDED DAY DETAIL ────────────────────────────────────────
            if (_selectedIndex != null && _selectedDays <= 30)
              _buildDayDetail(_selectedIndex!),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final daysWithData = _history.where((d) => (d['oxalate_mg'] as num) > 0).toList();
    final daysGoalMet  = _history.where((d) => (d['water_oz'] as num) >= _waterGoal).length;
    final avgOx = daysWithData.isEmpty
        ? 0.0
        : daysWithData.fold(0.0, (s, d) => s + (d['oxalate_mg'] as num)) / daysWithData.length;
    final avgWater = _history.isEmpty
        ? 0.0
        : _history.fold(0.0, (s, d) => s + (d['water_oz'] as num)) / _history.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERIOD SUMMARY',
          style: TextStyle(
            color: _textMuted, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _summaryCard('📅 Days Logged',    '${daysWithData.length}',              _accent)),
            const SizedBox(width: 10),
            Expanded(child: _summaryCard('💧 Water Goal Met', '$daysGoalMet days',                   _accentDark)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _summaryCard('⚗️ Avg Oxalate',   '${avgOx.toStringAsFixed(0)} mg',       _oxColor(avgOx))),
            const SizedBox(width: 10),
            Expanded(child: _summaryCard('💧 Avg Water',     '${avgWater.toStringAsFixed(0)} oz',   _accent)),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _summaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: _textMuted, fontSize: 11)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDayDetail(int idx) {
    final day       = _history[idx];
    final date      = day['date'] as String;
    final waterOz   = (day['water_oz']   as num).toDouble();
    final oxalateMg = (day['oxalate_mg'] as num).toDouble();
    final foodLog   = day['food_log'] as List<Map<String, dynamic>>;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📅  $date',
                    style: const TextStyle(color: _accentDark, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = null),
                    child: const Icon(Icons.close, color: _textMuted, size: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  _statChip('💧', '${waterOz.toInt()} oz',
                      waterOz >= _waterGoal ? _accent : _textMuted),
                  const SizedBox(width: 10),
                  _statChip('🧪', '${oxalateMg.toStringAsFixed(0)} mg', _oxColor(oxalateMg)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'FOODS LOGGED',
                style: TextStyle(color: _textMuted, fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            if (foodLog.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('No foods logged this day',
                    style: TextStyle(color: _textFaint, fontSize: 13)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: foodLog.length,
                separatorBuilder: (_, _) => const Divider(color: _border, height: 1, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final food = foodLog[i];
                  final name = food['name'] as String;
                  final mg   = (food['mg'] as num).toDouble();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(color: _oxColor(mg), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(color: _textPri, fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        Text('${mg.toStringAsFixed(1)} mg',
                            style: TextStyle(color: _oxColor(mg), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _statChip(String emoji, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Export History for Your Doctor',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textPri),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_month, color: _accentDark),
              title: const Text('Last 30 days', style: TextStyle(color: _textPri)),
              onTap: () { Navigator.pop(ctx); _exportHistory(daysBack: 30); },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_month_outlined, color: _accentDark),
              title: const Text('Last 6 months', style: TextStyle(color: _textPri)),
              onTap: () { Navigator.pop(ctx); _exportHistory(daysBack: 180); },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined, color: _accentDark),
              title: const Text('Last 12 months', style: TextStyle(color: _textPri)),
              onTap: () { Navigator.pop(ctx); _exportHistory(daysBack: 365); },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: _accentDark),
              title: const Text('Last 2 years', style: TextStyle(color: _textPri)),
              onTap: () { Navigator.pop(ctx); _exportHistory(daysBack: 730); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _exportHistory({required int daysBack}) async {
    final prefs           = await SharedPreferences.getInstance();
    final dailyHistoryRaw = prefs.getStringList('daily_history') ?? [];

    if (dailyHistoryRaw.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No history available to export yet.')),
      );
      return;
    }

    final waterGoal = prefs.getDouble('goal_water')   ?? 80.0;
    final oxGoal    = prefs.getDouble('goal_oxalate') ?? 200.0;
    final now       = DateTime.now();
    final cutoff    = now.subtract(Duration(days: daysBack));
    final List<Map<String, dynamic>> entries = [];

    for (final entry in dailyHistoryRaw) {
      try {
        final map     = jsonDecode(entry) as Map<String, dynamic>;
        final dateStr = map['date'] as String?;
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null || date.isBefore(cutoff)) continue;

        final water   = (map['water_oz']   as num?)?.toDouble() ?? 0.0;
        final oxalate = (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0;

        entries.add({
          'date':         dateStr,
          'water_oz':     water,
          'oxalate_mg':   oxalate,
          'waterGoalMet': water >= waterGoal,
          'oxGoalMet':    oxalate > 0 && oxalate <= oxGoal,
        });
      } catch (_) {}
    }

    if (entries.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No entries in the last $daysBack days to export.')),
      );
      return;
    }

    entries.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

    final buffer = StringBuffer()
      ..writeln('StoneGuard History Export')
      ..writeln('Timeframe: Last $daysBack days')
      ..writeln('Water goal: ${waterGoal.toStringAsFixed(0)} oz/day')
      ..writeln('Oxalate limit: ${oxGoal.toStringAsFixed(0)} mg/day')
      ..writeln('')
      ..writeln('Note: This report is based on values you logged in StoneGuard and is for discussion with your healthcare provider only.')
      ..writeln('It does not replace medical advice. Always follow your doctor or urologist\'s recommendations.')
      ..writeln('')
      ..writeln('Date,Water (oz),Oxalate (mg),Water goal met?,Oxalate goal met?');

    for (final e in entries) {
      buffer.writeln(
        '${e['date']},'
        '${(e['water_oz']   as double).toStringAsFixed(0)},'
        '${(e['oxalate_mg'] as double).toStringAsFixed(1)},'
        '${(e['waterGoalMet'] as bool) ? 'Yes' : 'No'},'
        '${(e['oxGoalMet']   as bool) ? 'Yes' : 'No'}',
      );
    }

    await Share.share(buffer.toString(), subject: 'StoneGuard Kidney Stone History');
  }
}
