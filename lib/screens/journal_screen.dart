import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

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

  static const Color bgColor     = Color(0xFFF8F8F8);
  static const Color cardColor   = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFD0D0D8);
  static const Color textColor   = Color(0xFF2C2C2C);
  static const Color mutedColor  = Color(0xFF888888);
  static const Color accentTeal  = Color(0xFF1A8A9A);
  static const Color appBarColor = Color(0xFFE8E8EC);

  static const List<String> _symptomOptions = [
    'Flank Pain',
    'Nausea',
    'Blood in Urine',
    'Frequent Urination',
    'Fever',
    'Vomiting',
  ];

  static const List<String> _sideOptions = ['None', 'Left', 'Both', 'Right'];

  // ── Persistence ───────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('journal_entries') ?? [];
    setState(() {
      _entries = raw
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> _saveEntry() async {
    if (_noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a note before saving.')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('journal_entries') ?? [];
    final entry = {
      'date': DateTime.now().toIso8601String(),
      'pain': _painLevel,
      'note': _noteController.text.trim(),
      'side': _side,
      'stonePassed': _stonePassed,
      'symptoms': _selectedSymptoms.toList(),
    };
    raw.add(jsonEncode(entry));
    await prefs.setStringList('journal_entries', raw);
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
        backgroundColor: accentTeal,
      ),
    );
  }

  Future<void> _deleteEntry(int reversedIndex) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('journal_entries') ?? [];
    final actualIndex = raw.length - 1 - reversedIndex;
    raw.removeAt(actualIndex);
    await prefs.setStringList('journal_entries', raw);
    _loadEntries();
  }

  Future<void> _updateEntry(int reversedIndex, Map<String, dynamic> updated) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('journal_entries') ?? [];
    final actualIndex = raw.length - 1 - reversedIndex;
    raw[actualIndex] = jsonEncode(updated);
    await prefs.setStringList('journal_entries', raw);
    _loadEntries();
  }

  // ── Edit Sheet ────────────────────────────────────────────────
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
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: cardColor,
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
                        color: borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Edit Entry',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: textColor)),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Text('Pain Level',
                        style: TextStyle(
                            fontSize: 13,
                            color: mutedColor,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                  const Text('Side',
                      style: TextStyle(
                          fontSize: 13,
                          color: mutedColor,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _buildSideSelector(editSide,
                          (s) => setSheetState(() => editSide = s)),
                  const SizedBox(height: 12),
                  const Text('Symptoms',
                      style: TextStyle(
                          fontSize: 13,
                          color: mutedColor,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  _buildSymptomChips(editSymptoms,
                          (tag, val) => setSheetState(() {
                        val ? editSymptoms.add(tag) : editSymptoms.remove(tag);
                      })),
                  const SizedBox(height: 12),
                  _buildStonePassedToggle(
                      editStonePassed,
                          (v) => setSheetState(() => editStonePassed = v)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: editNote,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Notes...',
                      hintStyle: const TextStyle(color: mutedColor, fontSize: 13),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: accentTeal, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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
                      child: const Text('Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w600)),
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

  // ── Detail Sheet ──────────────────────────────────────────────
  void _showEntryDetail(Map<String, dynamic> entry, int index) {
    final pain        = entry['pain'] as int;
    final note        = entry['note'] as String;
    final dateStr     = _formatDate(entry['date'] as String);
    final side        = (entry['side'] as String?) ?? 'None';
    final stonePassed = (entry['stonePassed'] as bool?) ?? false;
    final symptoms    = List<String>.from(
        (entry['symptoms'] as List<dynamic>?) ?? []);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: cardColor,
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
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
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
                      style: TextStyle(
                          color: _painColor(pain),
                          fontWeight: FontWeight.bold,
                          fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                    Text(dateStr,
                        style: const TextStyle(color: mutedColor, fontSize: 12)),
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
                  _infoBadge('$side Side', Icons.location_on_outlined, accentTeal),
                if (stonePassed)
                  _infoBadge('Stone Passed', Icons.check_circle_outline, Colors.green),
              ]),
              const SizedBox(height: 12),
            ],
            if (symptoms.isNotEmpty) ...[
              const Text('Symptoms',
                  style: TextStyle(
                      color: mutedColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: symptoms.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Text(s,
                      style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],
            const Divider(color: borderColor, height: 1),
            const SizedBox(height: 14),
            const Text('NOTE',
                style: TextStyle(
                    color: mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Text(note,
                  style: const TextStyle(
                      color: textColor, fontSize: 14, height: 1.6)),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                  label: const Text('Delete',
                      style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                  icon: const Icon(Icons.edit_outlined,
                      color: accentTeal, size: 18),
                  label: const Text('Edit',
                      style: TextStyle(color: accentTeal)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: accentTeal),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                    backgroundColor: accentTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── Reusable widgets ──────────────────────────────────────────
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
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildSideSelector(
      String currentSide, void Function(String) onSelect) {
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
                color: selected ? accentTeal.withValues(alpha: 0.12) : bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: selected ? accentTeal : borderColor, width: 1.5),
              ),
              child: Center(
                child: Text(s,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected ? accentTeal : mutedColor)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomChips(
      Set<String> selected, void Function(String, bool) onToggle) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _symptomOptions.map((tag) {
        final active = selected.contains(tag);
        return GestureDetector(
          onTap: () => onToggle(tag, !active),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? Colors.orange.withValues(alpha: 0.12) : bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: active
                      ? Colors.orange.withValues(alpha: 0.5)
                      : borderColor),
            ),
            child: Text(tag,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.orange : mutedColor)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStonePassedToggle(
      bool value, void Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: value ? Colors.green.withValues(alpha: 0.08) : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value
                ? Colors.green.withValues(alpha: 0.4)
                : borderColor),
      ),
      child: Row(children: [
        const Text('💎', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Stone Passed',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
          Text('Mark if you passed a stone today',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ]),
        const Spacer(),
        Switch(
          value: value,
          activeThumbColor: Colors.green,
          activeTrackColor: Colors.green.withValues(alpha: 0.4),
          onChanged: onChanged,
        ),
      ]),
    );
  }

  // ── Pain trend sparkline ──────────────────────────────────────
  Widget _buildPainTrend() {
    if (_entries.length < 2) return const SizedBox.shrink();
    final recent = _entries.take(7).toList().reversed.toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('7-Entry Pain Trend',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: mutedColor)),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: CustomPaint(
              size: const Size(double.infinity, 48),
              painter: _SparklinePainter(
                  recent.map((e) => (e['pain'] as int).toDouble()).toList()),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${recent.length} entries ago',
                  style: const TextStyle(fontSize: 10, color: mutedColor)),
              const Text('Latest',
                  style: TextStyle(fontSize: 10, color: mutedColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Color _painColor(int level) {
    if (level <= 3) return Colors.green;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }

  String _painLabel(int level) {
    if (level <= 2) return 'No Pain';
    if (level <= 4) return 'Mild';
    if (level <= 6) return 'Moderate';
    if (level <= 8) return 'Severe';
    return 'Extreme';
  }

  String _formatDate(String isoDate) {
    final date   = DateTime.parse(isoDate);
    final days   = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min  = date.minute.toString().padLeft(2, '0');
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} '
        '${date.day} · $hour:$min $ampm';
  }

  List<Map<String, dynamic>> get _filteredEntries {
    if (_filterSeverity == 'All') return _entries;
    return _entries.where((e) {
      final p = e['pain'] as int;
      switch (_filterSeverity) {
        case 'Mild':     return p <= 4;
        case 'Moderate': return p >= 5 && p <= 7;
        case 'Severe':   return p >= 8;
        default:         return true;
      }
    }).toList();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildJournalEmptyState() {
    final isFiltered = _filterSeverity != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentTeal.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  size: 42,
                  color: accentTeal,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isFiltered ? 'No matching entries' : 'No journal entries yet',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isFiltered
                    ? 'Try a different filter to see more entries.'
                    : 'Use Journal to track pain, symptoms, stone events, and notes for your doctor.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (isFiltered) {
                      setState(() => _filterSeverity = 'All');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fill out the form above to create your first journal entry.'),
                          backgroundColor: accentTeal,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    isFiltered ? Icons.filter_alt_off_rounded : Icons.edit_rounded,
                  ),
                  label: Text(
                    isFiltered ? 'Clear filter' : 'Write my first note',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEntries;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pain Journal',
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      // ── CustomScrollView: everything is a Sliver ─────────────
      body: CustomScrollView(
        slivers: [

          // ── 1. Entry form ────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
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
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  const SizedBox(height: 14),
                  // Pain level
                  Row(children: [
                    const Text('Pain Level',
                        style: TextStyle(
                            fontSize: 13,
                            color: mutedColor,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
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
                    label: '$_painLevel',
                    activeColor: _painColor(_painLevel),
                    inactiveColor: _painColor(_painLevel).withValues(alpha: 0.15),
                    onChanged: (v) => setState(() => _painLevel = v.round()),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 - No pain',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400)),
                      Text('10 - Extreme',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Side selector
                  const Text('Pain Side',
                      style: TextStyle(
                          fontSize: 13,
                          color: mutedColor,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildSideSelector(_side, (s) => setState(() => _side = s)),
                  const SizedBox(height: 14),
                  // Symptoms
                  const Text('Symptoms',
                      style: TextStyle(
                          fontSize: 13,
                          color: mutedColor,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildSymptomChips(
                      _selectedSymptoms,
                          (tag, val) => setState(() =>
                      val ? _selectedSymptoms.add(tag)
                          : _selectedSymptoms.remove(tag))),
                  const SizedBox(height: 14),
                  // Stone passed
                  _buildStonePassedToggle(
                      _stonePassed, (v) => setState(() => _stonePassed = v)),
                  const SizedBox(height: 14),
                  // Notes
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Notes — symptoms, water intake, diet, mood...',
                      hintStyle: const TextStyle(color: mutedColor, fontSize: 13),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          const BorderSide(color: accentTeal, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Entry',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveEntry,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 2. Pain trend sparkline ──────────────────────────
          SliverToBoxAdapter(child: _buildPainTrend()),

          // ── 3. Past entries header + filter ─────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('Past Entries',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${filtered.length}',
                          style: const TextStyle(
                              color: accentTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                    const Spacer(),
                    const Text('Tap to view',
                        style: TextStyle(color: mutedColor, fontSize: 11)),
                  ]),
                  const SizedBox(height: 8),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Mild', 'Moderate', 'Severe'].map((f) {
                        final active = _filterSeverity == f;
                        Color chipColor;
                        switch (f) {
                          case 'Mild':     chipColor = Colors.green; break;
                          case 'Moderate': chipColor = Colors.orange; break;
                          case 'Severe':   chipColor = Colors.red; break;
                          default:         chipColor = accentTeal;
                        }
                        return GestureDetector(
                          onTap: () => setState(() => _filterSeverity = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: active
                                  ? chipColor.withValues(alpha: 0.12)
                                  : bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: active ? chipColor : borderColor,
                                  width: 1.5),
                            ),
                            child: Text(f,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: active ? chipColor : mutedColor)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 4. Entry list or empty state ─────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(
            hasScrollBody: false,
            child: _buildJournalEmptyState(),
          )
              : SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final e           = filtered[i];
                  final pain        = e['pain'] as int;
                  final note        = e['note'] as String;
                  final dateStr     = _formatDate(e['date'] as String);
                  final stonePassed = (e['stonePassed'] as bool?) ?? false;
                  final symptoms    = List<String>.from(
                      (e['symptoms'] as List<dynamic>?) ?? []);
                  final masterIndex = _entries.indexOf(e);

                  return GestureDetector(
                    onTap: () => _showEntryDetail(e, masterIndex),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 1)),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pain badge
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: _painColor(pain).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('$pain',
                                  style: TextStyle(
                                      color: _painColor(pain),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(note,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: textColor, fontSize: 14)),
                                const SizedBox(height: 4),
                                if (symptoms.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 4,
                                    children: symptoms.take(3).map((s) =>
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(s,
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.orange)),
                                        )).toList(),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Row(children: [
                                  Text(dateStr,
                                      style: const TextStyle(
                                          color: mutedColor, fontSize: 11)),
                                  if (stonePassed) ...[
                                    const SizedBox(width: 6),
                                    const Text('💎',
                                        style: TextStyle(fontSize: 11)),
                                  ],
                                ]),
                              ],
                            ),
                          ),
                          // Chevron + delete
                          Column(children: [
                            const Icon(Icons.chevron_right_rounded,
                                color: mutedColor, size: 20),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _deleteEntry(masterIndex),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent, size: 20),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sparkline painter ─────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  _SparklinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minV  = data.reduce(math.min);
    final maxV  = data.reduce(math.max);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    double x(int i) => i * size.width / (data.length - 1);
    double y(double v) => size.height - ((v - minV) / range) * size.height;

    // Fill
    final fillPath = Path();
    fillPath.moveTo(x(0), size.height);
    for (int i = 0; i < data.length; i++) {
      fillPath.lineTo(x(i), y(data[i]));
    }
    fillPath.lineTo(x(data.length - 1), size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A8A9A).withValues(alpha: 0.2),
            const Color(0xFF1A8A9A).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path();
    linePath.moveTo(x(0), y(data[0]));
    for (int i = 1; i < data.length; i++) {
      linePath.lineTo(x(i), y(data[i]));
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF1A8A9A)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dots
    for (int i = 0; i < data.length; i++) {
      final color = data[i] <= 3
          ? Colors.green
          : data[i] <= 6
          ? Colors.orange
          : Colors.red;
      canvas.drawCircle(
        Offset(x(i), y(data[i])),
        3.5,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.data != data;
}