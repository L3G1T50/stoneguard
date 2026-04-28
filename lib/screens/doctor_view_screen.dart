import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorViewScreen extends StatefulWidget {
  const DoctorViewScreen({super.key});

  @override
  State<DoctorViewScreen> createState() => _DoctorViewScreenState();
}

class _DoctorViewScreenState extends State<DoctorViewScreen> {
  bool _isLoading = true;
  double _waterGoal = 80;
  double _oxGoal = 200;
  int _daysBack = 30;

  final List<Map<String, dynamic>> _timeframes = [
    {'label': '30D', 'days': 30},
    {'label': '6M', 'days': 180},
    {'label': '12M', 'days': 365},
  ];

  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load goals (same keys used elsewhere in the app)
    _waterGoal = prefs.getDouble('goal_water') ?? 80.0;
    _oxGoal = prefs.getDouble('goal_oxalate') ?? 200.0;

    final dailyHistoryRaw = prefs.getStringList('daily_history') ?? [];
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: _daysBack));

    final List<Map<String, dynamic>> entries = [];

    for (final entry in dailyHistoryRaw) {
      try {
        final map = jsonDecode(entry) as Map<String, dynamic>;
        final dateStr = map['date'] as String?;
        if (dateStr == null) continue;

        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;

        if (date.isBefore(cutoff)) continue;

        final water = (map['water_oz'] as num?)?.toDouble() ?? 0.0;
        final oxalate = (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0;

        entries.add({
          'date': date,
          'water_oz': water,
          'oxalate_mg': oxalate,
        });
      } catch (_) {
        // Ignore malformed entries
      }
    }

    // Oldest → newest
    entries.sort((a, b) {
      final da = a['date'] as DateTime;
      final db = b['date'] as DateTime;
      return da.compareTo(db);
    });

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8E8EC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        title: const Text(
          'Doctor View',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No history to show yet.\nLog water and foods for a few days, then come back to this view.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      )
          : Column(
        children: [
          // Timeframe selector
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _timeframes.map((tf) {
                final isSelected = _daysBack == tf['days'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _daysBack = tf['days'] as int;
                      _isLoading = true;
                    });
                    _loadData();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1A8A9A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1A8A9A)
                            : const Color(0xFFD0D0D8),
                      ),
                    ),
                    child: Text(
                      tf['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2C2C2C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For your healthcare provider',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'These charts show my daily water intake and oxalate load over time.\n'
                        'Please review them together with my labs, imaging, and clinical history.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Water chart
                  _buildLineCard(
                    title:
                    'Daily Water Intake (oz) – goal ${_waterGoal.toStringAsFixed(0)} oz',
                    color: const Color(0xFF1A8A9A),
                    goal: _waterGoal,
                    valueSelector: (e) =>
                        (e['water_oz'] as num).toDouble(),
                    entries: _entries,
                  ),
                  const SizedBox(height: 16),

                  // Oxalate chart
                  _buildLineCard(
                    title:
                    'Daily Oxalate Load (mg) – limit ${_oxGoal.toStringAsFixed(0)} mg',
                    color: const Color(0xFFD36B6B),
                    goal: _oxGoal,
                    valueSelector: (e) =>
                        (e['oxalate_mg'] as num).toDouble(),
                    entries: _entries,
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Tip: Use these trends with your doctor to fine‑tune your hydration, low‑oxalate diet, and any medication plan to help prevent future stones.',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineCard({
    required String title,
    required Color color,
    required double goal,
    required double Function(Map<String, dynamic>) valueSelector,
    required List<Map<String, dynamic>> entries,
  }) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD0D0D8)),
        ),
        child: const Text('No data to display yet.'),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      final val = valueSelector(entries[i]);
      spots.add(FlSpot(i.toDouble(), val));
    }

    double maxY = 0;
    for (final s in spots) {
      if (s.y > maxY) maxY = s.y;
    }
    // Make sure goal is visible
    if (goal > maxY) maxY = goal;
    if (maxY == 0) maxY = 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0D0D8)),
      ),
      child: SizedBox(
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2C2C2C),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
                  minY: 0,
                  maxY: maxY * 1.2,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: Color(0xFFE0E0E0),
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Color(0xFFB0B0B0)),
                      bottom: BorderSide(color: Color(0xFFB0B0B0)),
                      right: BorderSide(color: Colors.transparent),
                      top: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= entries.length) {
                            return const SizedBox.shrink();
                          }

                          // Show only a few labels to avoid clutter
                          final step = entries.length <= 7
                              ? 1
                              : entries.length <= 30
                              ? 5
                              : entries.length <= 90
                              ? 10
                              : 30;

                          if (idx % step != 0 && idx != entries.length - 1) {
                            return const SizedBox.shrink();
                          }

                          final date = entries[idx]['date'] as DateTime;
                          final label =
                              '${date.month}/${date.day}'; // M/D for simplicity

                          return Text(
                            label,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  // Goal line
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                      y: goal,
                      color: color.withValues(alpha: 0.5),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    ),
                  ]),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 2,
                      color: color,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}