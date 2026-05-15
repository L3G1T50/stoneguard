// ─── HISTORY SCREEN ───────────────────────────────────────────────────────────
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════
// HISTORY SCREEN WIDGET
// Loads daily water + oxalate history from SharedPreferences
// key 'daily_history' (a StringList of JSON objects), NOT
// from DatabaseHelper which only holds pain-journal entries.
// ═══════════════════════════════════════════════════════════

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ── theme helpers ───────────────────────────────────────────
  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _surface(BuildContext context) =>
      _isDark(context) ? AppColors.darkSurface : AppColors.surface;

  Color _background(BuildContext context) =>
      _isDark(context) ? AppColors.darkBackground : AppColors.background;

  Color _border(BuildContext context) =>
      _isDark(context) ? AppColors.darkBorder : AppColors.border;

  Color _textPrimary(BuildContext context) =>
      _isDark(context) ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color _textSecond(BuildContext context) =>
      _isDark(context) ? AppColors.darkTextSecond : AppColors.textSecond;

  // ── state ────────────────────────────────────────────────
  // Each entry: { 'date': 'YYYY-MM-DD', 'oxalate_mg': double, 'water_oz': double }
  List<Map<String, dynamic>> _entries  = [];
  List<Map<String, dynamic>> _filtered = [];
  bool   _loading    = true;
  String _search     = '';
  String _sortBy     = 'date_desc';
  String _filterType = 'all';
  int?   _selectedIndex;

  // ── lifecycle ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── data ───────────────────────────────────────────────────
  // Loads from SharedPreferences 'daily_history' StringList.
  // Each list item is a JSON string with keys: date, oxalate_mg, water_oz.
  // This matches ExportReportScreen and ProgressScreen exactly.
  Future<void> _load() async {
    final prefs      = await SharedPreferences.getInstance();
    final rawList    = prefs.getStringList('daily_history') ?? [];
    final List<Map<String, dynamic>> parsed = [];

    for (final item in rawList) {
      try {
        final map  = jsonDecode(item) as Map<String, dynamic>;
        final date = map['date'] as String?;
        if (date == null) continue;
        parsed.add({
          'date':       date,
          'oxalate_mg': (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0,
          'water_oz':   (map['water_oz']   as num?)?.toDouble() ?? 0.0,
        });
      } catch (_) {
        // skip malformed entries
      }
    }

    setState(() {
      _entries  = parsed;
      _filtered = _applyFilters(parsed);
      _loading  = false;
    });
  }

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> src) {
    var list = src.where((e) {
      final q = _search.toLowerCase();
      if (q.isEmpty) return true;
      return (e['date'] ?? '').toString().contains(q);
    }).toList();

    if (_filterType == 'water') {
      list = list.where((e) => (e['water_oz'] ?? 0) > 0).toList();
    } else if (_filterType == 'oxalate') {
      list = list.where((e) => (e['oxalate_mg'] ?? 0) > 0).toList();
    }

    list.sort((a, b) {
      switch (_sortBy) {
        case 'date_asc':
          return (a['date'] ?? '').compareTo(b['date'] ?? '');
        case 'water_desc':
          return (b['water_oz'] ?? 0).compareTo(a['water_oz'] ?? 0);
        case 'oxalate_desc':
          return (b['oxalate_mg'] ?? 0).compareTo(a['oxalate_mg'] ?? 0);
        default: // date_desc
          return (b['date'] ?? '').compareTo(a['date'] ?? '');
      }
    });
    return list;
  }

  void _onSearch(String q) =>
      setState(() { _search = q; _filtered = _applyFilters(_entries); });

  void _onSort(String? v) {
    if (v == null) return;
    setState(() { _sortBy = v; _filtered = _applyFilters(_entries); });
  }

  void _onFilter(String v) =>
      setState(() { _filterType = v; _filtered = _applyFilters(_entries); });

  // ── build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bg      = _background(context);
    final surface = _surface(context);
    final borderC = _border(context);
    final textPrim = _textPrimary(context);
    final textSec  = _textSecond(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          'History',
          style: TextStyle(
            color: textPrim,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: textPrim),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<String>(
              value: _sortBy,
              dropdownColor: surface,
              underline: const SizedBox(),
              icon: Icon(Icons.sort, color: textSec, size: 20),
              style: TextStyle(color: textSec, fontSize: 13),
              items: const [
                DropdownMenuItem(value: 'date_desc',     child: Text('Newest first')),
                DropdownMenuItem(value: 'date_asc',      child: Text('Oldest first')),
                DropdownMenuItem(value: 'water_desc',    child: Text('Most water')),
                DropdownMenuItem(value: 'oxalate_desc',  child: Text('Most oxalate')),
              ],
              onChanged: _onSort,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(context, surface, textSec, borderC),
                _buildFilterChips(context, textSec),
                _buildCharts(context),
                const Divider(height: 1),
                Expanded(
                  child: _buildList(
                      context, textPrim, textSec, surface, borderC)),
              ],
            ),
    );
  }

  // ── SEARCH BAR ──────────────────────────────────────────────
  Widget _buildSearchBar(
    BuildContext context,
    Color surface,
    Color textSec,
    Color borderC,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderC),
        ),
        child: TextField(
          onChanged: _onSearch,
          style: TextStyle(color: _textPrimary(context)),
          decoration: InputDecoration(
            hintText: 'Search by date…',
            hintStyle: TextStyle(color: textSec),
            prefixIcon: Icon(Icons.search, color: textSec),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          ),
        ),
      ),
    );
  }

  // ── FILTER CHIPS ───────────────────────────────────────────
  Widget _buildFilterChips(BuildContext context, Color textSec) {
    final chips = [
      ('all',     'All'),
      ('water',   '💧 Water'),
      ('oxalate', '🔬 Oxalate'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: chips.map((c) {
          final sel = _filterType == c.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => _onFilter(c.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary
                        : textSec.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  c.$2,
                  style: TextStyle(
                    color: sel ? Colors.white : textSec,
                    fontSize: 12,
                    fontWeight:
                        sel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── CHARTS ───────────────────────────────────────────────────
  Widget _buildCharts(BuildContext context) {
    if (_entries.length < 2) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _oxalateTrendChart(context)),
          const SizedBox(width: 12),
          Expanded(child: _waterBarChart(context)),
        ],
      ),
    );
  }

  Color _oxalateColor(double mg) {
    if (mg <= 100) return Colors.green;
    if (mg <= 200) return Colors.orange;
    return Colors.red;
  }

  Widget _oxalateTrendChart(BuildContext context) {
    final recent = _entries.take(14).toList().reversed.toList();
    final spots  = recent
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              (e.value['oxalate_mg'] as double),
            ))
        .toList();

    return SizedBox(
      height: 100,
      child: LineChart(LineChartData(
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.orange,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, p1, p2, p3) => FlDotCirclePainter(
                radius: 4,
                color: _oxalateColor(spot.y),
                strokeColor: Colors.white,
                strokeWidth: 1.5,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.orange.withValues(alpha: 0.18),
                  Colors.orange.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toStringAsFixed(0)} mg',
                      const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ))
                .toList(),
          ),
        ),
      )),
    );
  }

  Widget _waterBarChart(BuildContext context) {
    final recent = _entries.take(7).toList().reversed.toList();
    final groups = recent.asMap().entries.map((e) {
      final oz = e.value['water_oz'] as double;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: oz,
            color: oz >= 64
                ? Colors.teal
                : Colors.teal.withValues(alpha: 0.5),
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 100,
      child: BarChart(BarChartData(
        maxY: 120,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: groups,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, p1, rod, p2) => BarTooltipItem(
              '${rod.toY.toInt()} oz',
              const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ),
      )),
    );
  }

  // ── LIST ──────────────────────────────────────────────────────
  Widget _buildList(
    BuildContext context,
    Color textPrim,
    Color textSec,
    Color surface,
    Color borderC,
  ) {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 56, color: textSec),
            const SizedBox(height: 12),
            Text(
              _entries.isEmpty
                  ? 'No history logged yet.\nStart tracking today! 🛡️'
                  : 'No entries match your filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSec, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filtered.length,
      itemBuilder: (_, i) =>
          _entryCard(context, _filtered[i], i, textPrim, textSec),
    );
  }

  // ── ENTRY CARD ────────────────────────────────────────────
  Widget _entryCard(
    BuildContext context,
    Map<String, dynamic> entry,
    int index,
    Color textPrim,
    Color textSec,
  ) {
    final rawDate    = entry['date'] as String;
    final oxalateMg  = entry['oxalate_mg'] as double;
    final waterOz    = entry['water_oz']   as double;
    final isExpanded = _selectedIndex == index;
    final oxColor    = _oxalateColor(oxalateMg);

    // Format date nicely: "May 14, 2026"
    String displayDate = rawDate;
    try {
      displayDate =
          DateFormat('MMMM d, yyyy').format(DateTime.parse(rawDate));
    } catch (_) {}

    return AppCard(
      onTap: () => setState(() {
        _selectedIndex = isExpanded ? null : index;
      }),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayDate,
                        style: TextStyle(
                          color: textPrim,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _miniStat('💧',
                              '${waterOz.toStringAsFixed(0)} oz',
                              AppColors.primary),
                          const SizedBox(width: 10),
                          _miniStat('🔬',
                              '${oxalateMg.toStringAsFixed(0)} mg',
                              oxColor),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: textSec,
                  size: 20,
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: _border(context), height: 1),
                  const SizedBox(height: 10),
                  _detailRow('💧 Water Intake',
                      '${waterOz.toStringAsFixed(1)} oz',
                      AppColors.primary),
                  _detailRow('🔬 Oxalate Intake',
                      '${oxalateMg.toStringAsFixed(1)} mg', oxColor),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _miniStat(String emoji, String val, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 3),
        Text(
          val,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: _textSecond(context), fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
