import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  int _waterGoal = 80;
  int? _selectedIndex;
  int _selectedDays = 7;

  final List<Map<String, dynamic>> _timeframes = [
    {'label': '7D', 'days': 7},
    {'label': '30D', 'days': 30},
    {'label': '6M', 'days': 180},
    {'label': '1Y', 'days': 365},
    {'label': '2Y', 'days': 730},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getInt('water_goal') ?? 80;
    final now = DateTime.now();
    final List<Map<String, dynamic>> days = [];

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final y = date.year;
      final m = date.month;
      final d = date.day;

      final waterKey = 'water_${y}_${m}_$d';
      final oxKey = 'oxalate_${y}_${m}_$d';
      final logKey = 'oxalate_log_${y}_${m}_$d';

      final water = prefs.getDouble(waterKey) ?? 0;
      final oxalate = prefs.getDouble(oxKey) ?? 0;
      final rawLog = prefs.getStringList(logKey) ?? [];

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
        '${m.toString().padLeft(2, '0')}/${d.toString().padLeft(2, '0')}\n${y.toString().substring(2)}';
      }

      days.add({
        'date': dateLabel,
        'fullDate':
        '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}',
        'water_oz': water,
        'oxalate_mg': oxalate,
        'food_log': foodLog,
      });
    }

    setState(() {
      _history = days;
      _waterGoal = goal;
      _selectedIndex = null;
    });
  }

  Color _oxColor(double mg) {
    if (mg >= 100) return const Color(0xFFE53935);
    if (mg >= 50) return const Color(0xFFFFA726);
    if (mg >= 25) return const Color(0xFFFFEE58);
    return const Color(0xFF69F0AE);
  }

  List<Map<String, dynamic>> get _chartData {
    if (_selectedDays <= 30) return _history;

    final groupSize = _selectedDays <= 180 ? 7 : 30;
    final List<Map<String, dynamic>> grouped = [];

    for (int i = 0; i < _history.length; i += groupSize) {
      final chunk = _history.skip(i).take(groupSize).toList();
      final avgWater =
          chunk.fold(0.0, (s, d) => s + (d['water_oz'] as num)) /
              chunk.length;
      final avgOx =
          chunk.fold(0.0, (s, d) => s + (d['oxalate_mg'] as num)) /
              chunk.length;
      final label = chunk.first['date'].toString().split('\n').first;
      grouped.add({
        'date': label,
        'water_oz': avgWater,
        'oxalate_mg': avgOx,
        'food_log': <Map<String, dynamic>>[],
        'isGrouped': true,
        'groupLabel': groupSize == 7 ? 'Week of $label' : 'Month of $label',
      });
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _chartData;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: Text(
          _selectedDays <= 7
              ? '7-Day History'
              : _selectedDays <= 30
              ? '30-Day History'
              : _selectedDays <= 180
              ? '6-Month History'
              : _selectedDays <= 365
              ? '1-Year History'
              : '2-Year History',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TIMEFRAME SELECTOR ────────────────────────────
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00BCD4)
                            : const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00BCD4)
                              : const Color(0xFF1E2A3A),
                        ),
                      ),
                      child: Text(
                        tf['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : const Color(0xFF607D8B),
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

            // ── CHART TITLE ───────────────────────────────────
            Text(
              _selectedDays <= 30
                  ? 'DAILY WATER INTAKE (oz)'
                  : _selectedDays <= 180
                  ? 'WEEKLY AVG WATER INTAKE (oz)'
                  : 'MONTHLY AVG WATER INTAKE (oz)',
              style: const TextStyle(
                color: Color(0xFF607D8B),
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // ── CHART ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (_waterGoal * 1.3).toDouble(),
                    barTouchData: BarTouchData(
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent &&
                            response?.spot != null) {
                          final idx =
                              response!.spot!.touchedBarGroupIndex;
                          setState(() {
                            _selectedIndex =
                            _selectedIndex == idx ? null : idx;
                          });
                        }
                      },
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => const Color(0xFF1E2A3A),
                        getTooltipItem: (group, _, rod, _) =>
                            BarTooltipItem(
                              '${rod.toY.toInt()} oz',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      // ── BOTTOM TITLES ──────────────────────
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: _selectedDays == 30 ? 40 : 28,
                          getTitlesWidget: (value, _) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= chartData.length) {
                              return const SizedBox();
                            }

                            int step;
                            if (_selectedDays <= 7) {
                              step = 1;
                            } else if (_selectedDays <= 30) {
                              step = 5;
                            } else if (_selectedDays <= 180) {
                              step = 4;
                            } else if (_selectedDays <= 365) {
                              step = 2;
                            } else {
                              step = 3;
                            }

                            if (idx % step != 0) return const SizedBox();

                            String label;
                            if (_selectedDays <= 30) {
                              final parts = chartData[idx]['date']
                                  .toString()
                                  .split('/');
                              label = parts.length >= 2
                                  ? '/${parts[1]}'
                                  : chartData[idx]['date'].toString();
                            } else {
                              label = chartData[idx]['date']
                                  .toString()
                                  .split('\n')
                                  .first;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Transform.rotate(
                                angle: _selectedDays == 30 ? -0.5 : 0,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: _selectedIndex == idx
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF607D8B),
                                    fontSize:
                                    _selectedDays <= 7 ? 9 : 8,
                                    fontWeight: _selectedIndex == idx
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // ── LEFT TITLES ────────────────────────
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                                color: Color(0xFF37474F), fontSize: 10),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: Color(0xFF1E2A3A),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(chartData.length, (i) {
                      final oz =
                      (chartData[i]['water_oz'] as num).toDouble();
                      final isSelected = _selectedIndex == i;
                      final hitGoal = oz >= _waterGoal;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: oz,
                            width: _selectedDays <= 7
                                ? (isSelected ? 26 : 20)
                                : _selectedDays <= 30
                                ? (isSelected ? 14 : 10)
                                : (isSelected ? 8 : 5),
                            borderRadius: BorderRadius.circular(4),
                            color: isSelected
                                ? const Color(0xFF00E5FF)
                                : hitGoal
                                ? const Color(0xFF00BCD4)
                                : const Color(0xFF37474F),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: _waterGoal.toDouble(),
                              color: const Color(0xFF1A2332),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── LEGEND ────────────────────────────────────────
            Row(
              children: [
                _dot(const Color(0xFF00BCD4), 'Goal met'),
                const SizedBox(width: 16),
                _dot(const Color(0xFF37474F), 'Goal missed'),
                const SizedBox(width: 16),
                _dot(const Color(0xFF00E5FF), 'Selected'),
              ],
            ),

            const SizedBox(height: 24),

            // ── SUMMARY STATS ─────────────────────────────────
            if (_selectedDays > 7) _buildSummaryStats(),

            // ── TAP HINT ──────────────────────────────────────
            if (_selectedIndex == null && _selectedDays <= 30)
              const Center(
                child: Text(
                  '👆 Tap a bar to see that day\'s food log',
                  style:
                  TextStyle(color: Color(0xFF607D8B), fontSize: 13),
                ),
              ),

            // ── EXPANDED DAY DETAIL ───────────────────────────
            if (_selectedIndex != null && _selectedDays <= 30)
              _buildDayDetail(_selectedIndex!),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final daysWithData =
    _history.where((d) => (d['oxalate_mg'] as num) > 0).toList();
    final daysGoalMet = _history
        .where((d) => (d['water_oz'] as num) >= _waterGoal)
        .length;
    final avgOx = daysWithData.isEmpty
        ? 0.0
        : daysWithData.fold(
        0.0, (s, d) => s + (d['oxalate_mg'] as num)) /
        daysWithData.length;
    final avgWater = _history.isEmpty
        ? 0.0
        : _history.fold(0.0, (s, d) => s + (d['water_oz'] as num)) /
        _history.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERIOD SUMMARY',
          style: TextStyle(
            color: Color(0xFF607D8B),
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _summaryCard('📅 Days Logged',
                    '${daysWithData.length}', const Color(0xFF00BCD4))),
            const SizedBox(width: 10),
            Expanded(
                child: _summaryCard('💧 Water Goal Met',
                    '$daysGoalMet days', const Color(0xFF00E5FF))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _summaryCard('⚗️ Avg Oxalate',
                    '${avgOx.toStringAsFixed(0)} mg', _oxColor(avgOx))),
            const SizedBox(width: 10),
            Expanded(
                child: _summaryCard('💧 Avg Water',
                    '${avgWater.toStringAsFixed(0)} oz',
                    const Color(0xFF00BCD4))),
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
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2A3A)),
      ),
      child: Column(
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF607D8B), fontSize: 11)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDayDetail(int idx) {
    final day = _history[idx];
    final date = day['date'] as String;
    final waterOz = (day['water_oz'] as num).toDouble();
    final oxalateMg = (day['oxalate_mg'] as num).toDouble();
    final foodLog = day['food_log'] as List<Map<String, dynamic>>;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF0D1F2D),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📅  $date',
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIndex = null),
                    child: const Icon(Icons.close,
                        color: Color(0xFF607D8B), size: 18),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  _statChip(
                      '💧',
                      '${waterOz.toInt()} oz',
                      waterOz >= _waterGoal
                          ? const Color(0xFF00BCD4)
                          : const Color(0xFF607D8B)),
                  const SizedBox(width: 10),
                  _statChip('🧪',
                      '${oxalateMg.toStringAsFixed(0)} mg',
                      _oxColor(oxalateMg)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'FOODS LOGGED',
                style: TextStyle(
                  color: Color(0xFF607D8B),
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (foodLog.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Text('No foods logged this day',
                    style: TextStyle(
                        color: Color(0xFF455A64), fontSize: 13)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: foodLog.length,
                separatorBuilder: (_, _) => const Divider(
                  color: Color(0xFF1E2A3A),
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (_, i) {
                  final food = foodLog[i];
                  final name = food['name'] as String;
                  final mg = (food['mg'] as num).toDouble();
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: _oxColor(mg),
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13),
                                    overflow:
                                    TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        Text('${mg.toStringAsFixed(1)} mg',
                            style: TextStyle(
                                color: _oxColor(mg),
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF607D8B), fontSize: 11)),
      ],
    );
  }

  Widget _statChip(String emoji, String value, Color color) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
