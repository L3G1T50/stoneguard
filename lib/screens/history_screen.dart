// ─── HISTORY SCREEN ───────────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_card.dart';

// ═══════════════════════════════════════════════════════════
// HISTORY SCREEN WIDGET
// ═══════════════════════════════════════════════════════════

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ── theme helpers ───────────────────────────────────────────
  //    in lock-step with AppDynamic and AppCard. ──────────────────────
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
  List<Map<String, dynamic>> _entries  = [];
  List<Map<String, dynamic>> _filtered = [];
  bool   _loading  = true;
  String _search   = '';
  String _sortBy   = 'date_desc';
  String _filterType = 'all';
  int?   _selectedEntryId;

  // ── lifecycle ────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── data ───────────────────────────────────────────────────
  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final entries = await db.getAllEntries();
    setState(() {
      _entries  = entries;
      _filtered = _applyFilters(entries);
      _loading  = false;
    });
  }

  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> src) {
    var list = src.where((e) {
      final q = _search.toLowerCase();
      if (q.isEmpty) return true;
      return (e['notes'] ?? '').toString().toLowerCase().contains(q) ||
             (e['date']  ?? '').toString().contains(q);
    }).toList();

    if (_filterType == 'water') {
      list = list.where((e) => (e['water_oz'] ?? 0) > 0).toList();
    } else if (_filterType == 'pain') {
      list = list.where((e) => (e['pain_level'] ?? 0) > 0).toList();
    } else if (_filterType == 'oxalate') {
      list = list.where((e) => (e['oxalate_mg'] ?? 0) > 0).toList();
    }

    list.sort((a, b) {
      switch (_sortBy) {
        case 'date_asc':
          return (a['date'] ?? '').compareTo(b['date'] ?? '');
        case 'pain_desc':
          return (b['pain_level'] ?? 0).compareTo(a['pain_level'] ?? 0);
        case 'water_desc':
          return (b['water_oz'] ?? 0).compareTo(a['water_oz'] ?? 0);
        default:
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
    final bg       = _background(context);
    final surface  = _surface(context);
    final borderC  = _border(context);
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
          // Sort picker
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<String>(
              value: _sortBy,
              dropdownColor: surface,
              underline: const SizedBox(),
              icon: Icon(Icons.sort, color: textSec, size: 20),
              style: TextStyle(color: textSec, fontSize: 13),
              items: const [
                DropdownMenuItem(value: 'date_desc',  child: Text('Newest first')),
                DropdownMenuItem(value: 'date_asc',   child: Text('Oldest first')),
                DropdownMenuItem(value: 'pain_desc',  child: Text('Highest pain')),
                DropdownMenuItem(value: 'water_desc', child: Text('Most water')),
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
                Expanded(child: _buildList(context, textPrim, textSec, surface, borderC)),
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
            hintText: 'Search by notes or date…',
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
      ('pain',    '🟡 Pain'),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? AppColors.primary : textSec.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  c.$2,
                  style: TextStyle(
                    color: sel ? Colors.white : textSec,
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
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
          Expanded(child: _painTrendChart(context)),
          const SizedBox(width: 12),
          Expanded(child: _waterBarChart(context)),
        ],
      ),
    );
  }

  Color _painColor(int level) {
    if (level <= 2) return Colors.green;
    if (level <= 5) return Colors.orange;
    return Colors.red;
  }

  Widget _painTrendChart(BuildContext context) {
    final spots = _entries
        .asMap()
        .entries
        .take(14)
        .map((e) => FlSpot(
              e.key.toDouble(),
              (e.value['pain_level'] ?? 0).toDouble(),
            ))
        .toList();

    return SizedBox(
      height: 100,
      child: LineChart(LineChartData(
        minY: 0, maxY: 10,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [LineChartBarData(
          spots: spots, isCurved: true, curveSmoothness: 0.3,
          color: AppColors.primary, barWidth: 2.5, isStrokeCapRound: true,
          dotData: FlDotData(show: true, getDotPainter: (spot, _, _2, _3) =>
              FlDotCirclePainter(
                radius: 4, color: _painColor(spot.y.toInt()),
                strokeColor: Colors.white, strokeWidth: 1.5)),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.18),
                AppColors.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        )],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) =>
              LineTooltipItem(
                'Pain: ${s.y.toInt()}',
                const TextStyle(color: Colors.white, fontSize: 11),
              )
            ).toList(),
          ),
        ),
      )),
    );
  }

  Widget _waterBarChart(BuildContext context) {
    final recent = _entries.take(7).toList().reversed.toList();
    final groups = recent.asMap().entries.map((e) {
      final oz = (e.value['water_oz'] ?? 0).toDouble();
      return BarChartGroupData(
        x: e.key,
        barRods: [BarChartRodData(
          toY: oz,
          color: oz >= 64 ? Colors.teal : Colors.teal.withValues(alpha: 0.5),
          width: 10,
          borderRadius: BorderRadius.circular(4),
        )],
      );
    }).toList();

    return SizedBox(
      height: 100,
      child: BarChart(BarChartData(
        maxY: 120,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: groups,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, _2) => BarTooltipItem(
              '${rod.toY.toInt()} entries',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
            Text('No entries found',
                style: TextStyle(color: textSec, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _entryCard(context, _filtered[i], textPrim, textSec),
    );
  }

  // ── ENTRY CARD ────────────────────────────────────────────
  Widget _entryCard(
    BuildContext context,
    Map<String, dynamic> entry,
    Color textPrim,
    Color textSec,
  ) {
    final id         = entry['id'] as int?;
    final date       = entry['date']       ?? '—';
    final painLevel  = (entry['pain_level'] ?? 0) as int;
    final waterOz    = (entry['water_oz']   ?? 0.0) as double;
    final oxalateMg  = (entry['oxalate_mg'] ?? 0.0) as double;
    final notes      = (entry['notes']      ?? '') as String;
    final isExpanded = _selectedEntryId == id;
    final painColor  = _painColor(painLevel);

    return AppCard(
      context: context,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // — summary row —
          InkWell(
            onTap: () => setState(() {
              _selectedEntryId = isExpanded ? null : id;
            }),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            color: textPrim,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _miniStat('🔥', '${painLevel}/10', painColor),
                            const SizedBox(width: 10),
                            _miniStat('💧', '${waterOz.toStringAsFixed(0)} oz',
                                AppColors.primary),
                            const SizedBox(width: 10),
                            _miniStat('🔬', '${oxalateMg.toStringAsFixed(0)} mg',
                                Colors.orange),
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
          ),
          // — expanded details —
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: _border(context), height: 1),
                  const SizedBox(height: 10),
                  _detailRow('🔥 Pain Level',
                      '$painLevel / 10', painColor),
                  _detailRow('💧 Water Intake',
                      '${waterOz.toStringAsFixed(1)} oz', AppColors.primary),
                  _detailRow('🔬 Oxalate Intake',
                      '${oxalateMg.toStringAsFixed(1)} mg', Colors.orange),
                  if (notes.isNotEmpty) ...
                    [
                      const SizedBox(height: 8),
                      Text(
                        '📝 Notes',
                        style: TextStyle(
                            color: textSec,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        style: TextStyle(color: textSec, fontSize: 13),
                      ),
                    ],
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
              color: color, fontSize: 11, fontWeight: FontWeight.w600),
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
                  color: _textSecond(context),
                  fontSize: 13)),
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
