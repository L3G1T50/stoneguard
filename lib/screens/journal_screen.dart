import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import 'settings_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _entries = [];
  final _noteController = TextEditingController();
  int _painLevel = 1;
  String _side = 'None';
  bool _stonePassed = false;
  final Set<String> _selectedSymptoms = {};
  String _filterSeverity = 'All';

  static const List<String> _symptomOptions = [
    'Flank Pain',
    'Nausea',
    'Blood in Urine',
    'Frequent Urination',
    'Fever',
    'Vomiting',
  ];

  static const List<String> _sideOptions = ['None', 'Left', 'Both', 'Right'];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await DatabaseHelper.instance.getAllEntries();
    setState(() => _entries = entries);
  }

  Future<void> _saveEntry() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a note before saving.')),
      );
      return;
    }
    await DatabaseHelper.instance.insertEntry({
      'date': DateTime.now().toIso8601String(),
      'pain': _painLevel,
      'note': _noteController.text.trim(),
      'side': _side,
      'stonePassed': _stonePassed,
      'symptoms': _selectedSymptoms.toList(),
    });
    if (!mounted) return;
    _noteController.clear();
    setState(() {
      _painLevel = 1;
      _side = 'None';
      _stonePassed = false;
      _selectedSymptoms.clear();
    });
    _loadEntries();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal entry saved!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _deleteEntry(int index) async {
  final filtered = _filteredEntries;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Entry'),
      content: const Text('Are you sure you want to delete this entry?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
      ],
    ),
  );
  if (confirmed != true) return;
  final id = filtered[index]['id'] as int;
  await DatabaseHelper.instance.deleteEntry(id);
  _loadEntries();
}

  Future<void> _updateEntry(int index, Map<String, dynamic> updated) async {
    final id = _entries[index]['id'] as int;
    await DatabaseHelper.instance.updateEntry(id, updated);
    _loadEntries();
  }

  void _showEditSheet(Map<String, dynamic> entry, int index) {
    final editNote = TextEditingController(text: entry['note'] as String);
    int editPain = entry['pain'] as int;
    String editSide = (entry['side'] as String?) ?? 'None';
    bool editStonePassed = (entry['stonePassed'] as bool?) ?? false;
    final Set<String> editSymptoms = Set<String>.from(
        (entry['symptoms'] as List<dynamic>?) ?? []);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Edit Entry', style: AppTextStyles.itemTitle.copyWith(fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Text('Pain Level', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _painColor(editPain).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$editPain - ${_painLabel(editPain)}',
                          style: TextStyle(
                              color: _painColor(editPain),
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ]),
                  Slider(
                    value: editPain.toDouble(),
                    min: 1, max: 10, divisions: 9,
                    activeColor: _painColor(editPain),
                    inactiveColor: _painColor(editPain).withValues(alpha: 0.15),
                    onChanged: (v) => setSheetState(() => editPain = v.round()),
                  ),
                  const SizedBox(height: 8),
                  Text('Side', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _buildSideSelector(editSide, (s) => setSheetState(() => editSide = s)),
                  const SizedBox(height: 12),
                  Text('Symptoms', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _buildSymptomChips(editSymptoms, (tag, val) => setSheetState(() {
                    val ? editSymptoms.add(tag) : editSymptoms.remove(tag);
                  })),
                  const SizedBox(height: 12),
                  _buildStonePassedToggle(editStonePassed, (v) => setSheetState(() => editStonePassed = v)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: editNote,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Notes...',
                      hintStyle: AppTextStyles.body,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (editNote.text.trim().isEmpty) return;
                        final updated = Map<String, dynamic>.from(entry);
                        updated['pain'] = editPain;
                        updated['side'] = editSide;
                        updated['stonePassed'] = editStonePassed;
                        updated['symptoms'] = editSymptoms.toList();
                        updated['note'] = editNote.text.trim();
                        Navigator.pop(ctx);
                        await _updateEntry(index, updated);
                      },
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEntryDetail(Map<String, dynamic> entry, int index) {
    final pain        = entry['pain'] as int;
    final note        = entry['note'] as String;
    final dateStr     = _formatDate(entry['date'] as String);
    final side        = (entry['side'] as String?) ?? 'None';
    final stonePassed = (entry['stonePassed'] as bool?) ?? false;
    final symptoms    = List<String>.from((entry['symptoms'] as List<dynamic>?) ?? []);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.3,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _painColor(pain).withValues(alpha: 0.12),
                  child: Text('$pain',
                      style: TextStyle(
                          color: _painColor(pain),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
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
                            style: TextStyle(
                                color: _painColor(pain),
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                      const SizedBox(height: 4),
                      Text(dateStr, style: AppTextStyles.micro),
                    ],
                  ),
                ),
                if (stonePassed)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('💎', style: TextStyle(fontSize: 22)),
                  ),
              ]),
              const SizedBox(height: 14),
              if (side != 'None' || stonePassed) ...[
                Wrap(spacing: 8, children: [
                  if (side != 'None')
                    _infoBadge('$side Side', Icons.location_on_outlined, AppColors.primary),
                  if (stonePassed)
                    _infoBadge('Stone Passed', Icons.check_circle_outline, AppColors.success),
                ]),
                const SizedBox(height: 12),
              ],
              if (symptoms.isNotEmpty) ...[
                Text('Symptoms', style: AppTextStyles.micro.copyWith(letterSpacing: 0.8)),
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
                    child: Text(s, style: const TextStyle(
                        color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500)),
                  )).toList(),
                ),
                const SizedBox(height: 12),
              ],
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 14),
              Text('NOTE', style: AppTextStyles.micro.copyWith(letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(note, style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.6)),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18),
                    label: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _deleteEntry(index);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
                    label: const Text('Edit', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showEditSheet(entry, index);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ],
          ),
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
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildSideSelector(String currentSide, void Function(String) onSelect) {
    return Row(
      children: _sideOptions.map((s) {
        final selected = s == currentSide;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border, width: 1.5),
              ),
              child: Center(
                child: Text(s, style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.textMuted)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomChips(Set<String> selected, void Function(String, bool) onToggle) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _symptomOptions.map((tag) {
        final active = selected.contains(tag);
        return GestureDetector(
          onTap: () => onToggle(tag, !active),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.warning.withValues(alpha: 0.12) : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: active ? AppColors.warning.withValues(alpha: 0.5) : AppColors.border),
            ),
            child: Text(tag, style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? AppColors.warning : AppColors.textMuted)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStonePassedToggle(bool value, void Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: value ? AppColors.success.withValues(alpha: 0.08) : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value ? AppColors.success.withValues(alpha: 0.4) : AppColors.border),
      ),
      child: Row(children: [
        const Text('💎', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Stone Passed', style: AppTextStyles.itemTitle),
          Text('Mark if you passed a stone today', style: AppTextStyles.micro),
        ]),
        const Spacer(),
        Switch(
          value: value,
          activeThumbColor: AppColors.success,
          activeTrackColor: AppColors.success.withValues(alpha: 0.4),
          onChanged: onChanged,
        ),
      ]),
    );
  }

  Color _painColor(int p) {
    if (p <= 3) return AppColors.success;
    if (p <= 6) return AppColors.warning;
    return AppColors.danger;
  }

  String _painLabel(int p) {
    if (p <= 2) return 'Mild';
    if (p <= 4) return 'Moderate';
    if (p <= 6) return 'Significant';
    if (p <= 8) return 'Severe';
    return 'Extreme';
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  ${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2,'0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
    } catch (_) {
      return iso;
    }
  }

  List<Map<String, dynamic>> get _filteredEntries {
    if (_filterSeverity == 'All') return _entries;
    return _entries.where((e) {
      final pain = e['pain'] as int;
      switch (_filterSeverity) {
        case 'Mild': return pain <= 3;
        case 'Moderate': return pain >= 4 && pain <= 6;
        case 'Severe': return pain >= 7;
        default: return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;

    return GradientScaffold(
      title: 'Pain Journal',
      body: ListView(
        padding: EdgeInsets.only(bottom: bottomPad),
        children: [

          // ── Card 1: New entry form ────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How are you feeling today?', style: AppTextStyles.itemTitle),
                const SizedBox(height: 14),
                Row(children: [
                  Text('Pain Level', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _painColor(_painLevel).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$_painLevel - ${_painLabel(_painLevel)}',
                        style: TextStyle(
                            color: _painColor(_painLevel),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                ]),
                Slider(
                  value: _painLevel.toDouble(),
                  min: 1, max: 10, divisions: 9,
                  activeColor: _painColor(_painLevel),
                  inactiveColor: _painColor(_painLevel).withValues(alpha: 0.15),
                  onChanged: (v) => setState(() => _painLevel = v.round()),
                ),
                const SizedBox(height: 8),
                Text('Side', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _buildSideSelector(_side, (s) => setState(() => _side = s)),
                const SizedBox(height: 12),
                Text('Symptoms', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _buildSymptomChips(_selectedSymptoms, (tag, val) {
                  setState(() {
                    val ? _selectedSymptoms.add(tag) : _selectedSymptoms.remove(tag);
                  });
                }),
                const SizedBox(height: 12),
                _buildStonePassedToggle(_stonePassed, (v) => setState(() => _stonePassed = v)),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'How are you feeling? Any symptoms or observations...',
                    hintStyle: AppTextStyles.body,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Entry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      textStyle: AppTextStyles.button,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _saveEntry,
                  ),
                ),
              ],
            ),
          ),

          // ── Card 2: Past Entries ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row (title + filter) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                  child: Row(
                    children: [
                      Text('Past Entries', style: AppTextStyles.itemTitle),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _filterSeverity,
                        underline: const SizedBox(),
                        style: AppTextStyles.body,
                        items: ['All', 'Mild', 'Moderate', 'Severe']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _filterSeverity = v ?? 'All'),
                      ),
                    ],
                  ),
                ),

                // ── Sparkline trend (only with 3+ entries) ──
                if (_entries.length >= 3)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Text('Pain trend', style: AppTextStyles.micro.copyWith(letterSpacing: 0.8)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomPaint(
                                painter: _SparklinePainter(
                                  values: _entries
                                      .take(20)
                                      .map((e) => (e['pain'] as int).toDouble())
                                      .toList()
                                      .reversed
                                      .toList(),
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const Divider(color: AppColors.border, height: 1),

                // ── Empty state ──
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.book_outlined, size: 40, color: AppColors.textHint),
                          const SizedBox(height: 10),
                          Text('No entries yet',
                              style: AppTextStyles.itemTitle.copyWith(color: AppColors.textHint)),
                          const SizedBox(height: 4),
                          Text('Log how you are feeling above', style: AppTextStyles.body),
                        ],
                      ),
                    ),
                  )
                // ── Entry rows ──
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final entry      = filtered[index];
                      final pain       = entry['pain'] as int;
                      final note       = entry['note'] as String;
                      final dateStr    = _formatDate(entry['date'] as String);
                      final stonePassed = (entry['stonePassed'] as bool?) ?? false;
                      final symptoms   = List<String>.from((entry['symptoms'] as List<dynamic>?) ?? []);

                      return InkWell(
                        borderRadius: BorderRadius.circular(0),
                        onTap: () => _showEntryDetail(entry, index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: _painColor(pain).withValues(alpha: 0.12),
                                  child: Text('$pain',
                                      style: TextStyle(
                                          color: _painColor(pain),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$pain/10 — ${_painLabel(pain)}',
                                          style: AppTextStyles.itemTitle.copyWith(
                                              color: _painColor(pain), fontSize: 13)),
                                      Text(dateStr, style: AppTextStyles.micro),
                                    ],
                                  ),
                                ),
                                if (stonePassed)
                                  const Text('💎', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
                              ]),
                              if (symptoms.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: symptoms.take(3).map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(s, style: const TextStyle(
                                        color: AppColors.warning,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500)),
                                  )).toList(),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                note,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body.copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sparkline painter
class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    const minVal = 1.0;
    const maxVal = 10.0;
    final xStep = size.width / (values.length - 1);

    double yFor(double v) =>
        size.height - ((v - minVal) / (maxVal - minVal)) * size.height;

    final path = Path();
    final fillPath = Path();

    path.moveTo(0, yFor(values[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, yFor(values[0]));

    for (int i = 1; i < values.length; i++) {
      final x = i * xStep;
      final y = yFor(values[i]);
      final prevX = (i - 1) * xStep;
      final prevY = yFor(values[i - 1]);
      final cpX = (prevX + x) / 2;
      path.cubicTo(cpX, prevY, cpX, y, x, y);
      fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    canvas.drawCircle(
      Offset(size.width, yFor(values.last)),
      3,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}
