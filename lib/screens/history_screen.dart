import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../app_theme.dart';
import 'dart:math' as math;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
  String _filterSeverity = 'All';
  String _sortOrder = 'Newest';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseHelper.instance.getAllEntries();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Color _painColor(int level) {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.danger;
  }

  String _painLabel(int level) {
    if (level <= 2) return 'No Pain';
    if (level <= 4) return 'Mild';
    if (level <= 6) return 'Moderate';
    if (level <= 8) return 'Severe';
    return 'Extreme';
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day} · $hour:$min $ampm';
  }

  String _monthKey(String isoDate) {
    final date = DateTime.parse(isoDate);
    final months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<Map<String, dynamic>> get _filteredEntries {
    List<Map<String, dynamic>> result = _entries;
    if (_filterSeverity != 'All') {
      result = result.where((e) {
        final p = e['pain'] as int;
        switch (_filterSeverity) {
          case 'Mild':     return p <= 4;
          case 'Moderate': return p >= 5 && p <= 7;
          case 'Severe':   return p >= 8;
          case 'Stone':    return (e['stonePassed'] as bool?) ?? false;
          default:         return true;
        }
      }).toList();
    }
    if (_sortOrder == 'Oldest') result = result.reversed.toList();
    return result;
  }

  Map<String, dynamic> get _stats {
    if (_entries.isEmpty) return {'total': 0, 'avgPain': 0.0, 'stonesPassed': 0, 'highestPain': 0, 'streak': 0};
    final pains = _entries.map((e) => e['pain'] as int).toList();
    final avg = pains.reduce((a, b) => a + b) / pains.length;
    final stones = _entries.where((e) => (e['stonePassed'] as bool?) ?? false).length;
    final highest = pains.reduce(math.max);
    final days = _entries.map((e) {
      final d = DateTime.parse(e['date'] as String);
      return DateTime(d.year, d.month, d.day);
    }).toSet().length;
    return {'total': _entries.length, 'avgPain': avg, 'stonesPassed': stones, 'highestPain': highest, 'streak': days};
  }

  Map<String, List<Map<String, dynamic>>> get _groupedEntries {
    final filtered = _filteredEntries;
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final entry in filtered) {
      final key = _monthKey(entry['date'] as String);
      groups.putIfAbsent(key, () => []).add(entry);
    }
    return groups;
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final s = _stats;
    if (s['total'] == 0) return const SizedBox.shrink();
    final avg = (s['avgPain'] as double).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OVERVIEW',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Row(children: [
            _buildStatCard('Entries', '${s['total']}', Icons.edit_note_rounded, AppColors.primary),
            const SizedBox(width: 8),
            _buildStatCard('Avg Pain', avg, Icons.show_chart_rounded, AppColors.warning),
            const SizedBox(width: 8),
            _buildStatCard('Stones\nPassed', '${s['stonesPassed']}', Icons.diamond_outlined, AppColors.success),
            const SizedBox(width: 8),
            _buildStatCard('Days\nTracked', '${s['streak']}', Icons.calendar_today_outlined, AppColors.primary),
          ]),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Mild', 'Moderate', 'Severe', 'Stone'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _sortOrder = _sortOrder == 'Newest' ? 'Oldest' : 'Newest'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_sortOrder == 'Newest' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(_sortOrder,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ),
          ),
          ...filters.map((f) {
            final active = _filterSeverity == f;
            Color chipColor;
            switch (f) {
              case 'Mild':     chipColor = AppColors.success; break;
              case 'Moderate': chipColor = AppColors.warning; break;
              case 'Severe':   chipColor = AppColors.danger; break;
              case 'Stone':    chipColor = AppColors.success; break;
              default:         chipColor = AppColors.primary;
            }
            return GestureDetector(
              onTap: () => setState(() => _filterSeverity = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? chipColor.withValues(alpha: 0.12) : AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? chipColor : AppColors.border, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f == 'Stone') ...[
                      const Text('💎', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                    ],
                    Text(f,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: active ? chipColor : AppColors.textMuted)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> e) {
    final pain = e['pain'] as int;
    final note = e['note'] as String;
    final dateStr = _formatDate(e['date'] as String);
    final stonePassed = (e['stonePassed'] as bool?) ?? false;
    final symptoms = List<String>.from((e['symptoms'] as List<dynamic>?) ?? []);
    final side = (e['side'] as String?) ?? 'None';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showEntryDetail(e),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _painColor(pain).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('$pain',
                        style: TextStyle(color: _painColor(pain), fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _painColor(pain).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_painLabel(pain),
                              style: TextStyle(color: _painColor(pain), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        if (stonePassed) ...[
                          const SizedBox(width: 6),
                          const Text('💎', style: TextStyle(fontSize: 13)),
                        ],
                        if (side != 'None') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(side,
                                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                        if (symptoms.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('+${symptoms.length}',
                                style: const TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 5),
                      Text(note, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 3),
                      Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textFaint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(String month, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(children: [
        Text(month.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.1)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
        ),
      ]),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _filterSeverity != 'All';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 84, width: 84,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.10)),
                child: const Icon(Icons.history_rounded, size: 42, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              Text(isFiltered ? 'No matching entries' : 'No history yet',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Text(
                isFiltered
                    ? 'Try a different filter to see more entries.'
                    : 'Your journal entries will appear here.\nStart logging from the Journal tab.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textMuted),
              ),
              if (isFiltered) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _filterSeverity = 'All'),
                    icon: const Icon(Icons.filter_alt_off_rounded),
                    label: const Text('Clear filter', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEntryDetail(Map<String, dynamic> entry) {
    final pain = entry['pain'] as int;
    final note = entry['note'] as String;
    final dateStr = _formatDate(entry['date'] as String);
    final side = (entry['side'] as String?) ?? 'None';
    final stonePassed = (entry['stonePassed'] as bool?) ?? false;
    final symptoms = List<String>.from((entry['symptoms'] as List<dynamic>?) ?? []);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: _painColor(pain).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('$pain',
                      style: TextStyle(color: _painColor(pain), fontWeight: FontWeight.bold, fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _painColor(pain).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$pain / 10 — ${_painLabel(pain)}',
                          style: TextStyle(color: _painColor(pain), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(height: 4),
                    Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (stonePassed)
                const Padding(
                    padding: EdgeInsets.only(left: 8), child: Text('💎', style: TextStyle(fontSize: 22))),
            ]),
            const SizedBox(height: 14),
            if (side != 'None' || stonePassed) ...[
              Wrap(
                spacing: 8,
                children: [
                  if (side != 'None') _infoBadge('$side Side', Icons.location_on_outlined, AppColors.primary),
                  if (stonePassed) _infoBadge('Stone Passed', Icons.check_circle_outline, AppColors.success),
                ],
              ),
              const SizedBox(height: 12),
            ],
            if (symptoms.isNotEmpty) ...[
              const Text('SYMPTOMS',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: symptoms.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Text(s,
                      style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500)),
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 14),
            const Text('NOTE',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(note,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedEntries;
    final filtered = _filteredEntries;

    // Render as plain scrollable content — no Scaffold/AppBar (parent tab shell provides those)
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_entries.isEmpty) return _buildEmptyState();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: _buildStatsSection(),
        )),
        SliverToBoxAdapter(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('FILTER & SORT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.1)),
            ),
            _buildFilterBar(),
            const SizedBox(height: 16),
          ],
        )),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(children: [
            const Text('ENTRIES',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.1)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${filtered.length}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ]),
        )),
        if (filtered.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final keys = grouped.keys.toList();
                  final List<Widget> items = [];
                  for (final month in keys) {
                    final monthEntries = grouped[month]!;
                    items.add(_buildMonthHeader(month, monthEntries.length));
                    for (final e in monthEntries) {
                      items.add(_buildEntryCard(e));
                    }
                  }
                  return items[index];
                },
                childCount: grouped.entries.fold<int>(0, (sum, e) => sum + 1 + e.value.length),
              ),
            ),
          ),
      ],
    );
  }
}
