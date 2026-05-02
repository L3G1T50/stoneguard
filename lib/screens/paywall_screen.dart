import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'paywall_screen.dart';

class DoctorViewScreen extends StatefulWidget {
  const DoctorViewScreen({super.key});

  @override
  State<DoctorViewScreen> createState() => _DoctorViewScreenState();
}

class _DoctorViewScreenState extends State<DoctorViewScreen> {
  bool _isLoading = true;
  bool _isPremium = false;

  double _waterGoal = 80;
  double _oxGoal = 200;
  int _daysBack = 30;
  String _userName = '';

  final List<Map<String, dynamic>> _timeframes = [
    {'label': '30D', 'days': 30, 'premium': false},
    {'label': '6M', 'days': 180, 'premium': true},
    {'label': '12M', 'days': 365, 'premium': true},
  ];

  List<Map<String, dynamic>> _entries = [];

  static const Color _bg = Color(0xFFF8F8F8);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFD0D0D8);
  static const Color _textPri = Color(0xFF2C2C2C);
  static const Color _textMuted = Color(0xFF888888);
  static const Color _appBar = Color(0xFFE8E8EC);
  static const Color _teal = Color(0xFF1A8A9A);
  static const Color _red = Color(0xFFD36B6B);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _waterGoal = prefs.getDouble('goal_water') ?? 80.0;
    _oxGoal = prefs.getDouble('goal_oxalate') ?? 200.0;
    _userName = prefs.getString('user_name') ?? '';
    _isPremium = prefs.getBool('is_premium') ?? false;

    final raw = prefs.getStringList('daily_history') ?? [];
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: _daysBack));

    final List<Map<String, dynamic>> entries = [];
    for (final entry in raw) {
      try {
        final map = jsonDecode(entry) as Map<String, dynamic>;
        final dateStr = map['date'] as String?;
        if (dateStr == null) continue;

        final date = DateTime.tryParse(dateStr);
        if (date == null || date.isBefore(cutoff)) continue;

        entries.add({
          'date': date,
          'water_oz': (map['water_oz'] as num?)?.toDouble() ?? 0.0,
          'oxalate_mg': (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0,
        });
      } catch (_) {}
    }

    entries.sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _openPaywall() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _selectTimeframe(Map<String, dynamic> tf) async {
    final isPremiumOnly = tf['premium'] == true;

    if (isPremiumOnly && !_isPremium) {
      await _openPaywall();
      return;
    }

    setState(() {
      _daysBack = tf['days'] as int;
      _isLoading = true;
    });

    await _loadData();
  }

  Map<String, dynamic> _computeStats() {
    if (_entries.isEmpty) {
      return {
        'daysLogged': 0,
        'avgWater': 0.0,
        'avgOxalate': 0.0,
        'waterGoalDays': 0,
        'oxalateGoalDays': 0,
        'waterPct': 0,
        'oxalatePct': 0,
      };
    }

    double tw = 0, to = 0;
    int wg = 0, og = 0;

    for (final e in _entries) {
      final w = e['water_oz'] as double;
      final o = e['oxalate_mg'] as double;
      tw += w;
      to += o;
      if (w >= _waterGoal) wg++;
      if (o <= _oxGoal) og++;
    }

    final n = _entries.length;
    return {
      'daysLogged': n,
      'avgWater': tw / n,
      'avgOxalate': to / n,
      'waterGoalDays': wg,
      'oxalateGoalDays': og,
      'waterPct': ((wg / n) * 100).round(),
      'oxalatePct': ((og / n) * 100).round(),
    };
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _buildReportText() {
    final stats = _computeStats();
    final now = DateTime.now();
    final dateFrom =
    _entries.isNotEmpty ? _fmt(_entries.first['date'] as DateTime) : '—';
    final dateTo =
    _entries.isNotEmpty ? _fmt(_entries.last['date'] as DateTime) : '—';
    final patLine = _userName.isNotEmpty ? 'Patient: $_userName\n' : '';

    final buf = StringBuffer();
    buf.writeln('════════════════════════════════');
    buf.writeln('   StoneGuard — Doctor Report');
    buf.writeln('════════════════════════════════');
    buf.writeln('${patLine}Generated : ${_fmt(now)}');
    buf.writeln('Period    : $dateFrom → $dateTo ($_daysBack-day window)');
    buf.writeln(
      'Goals     : Water ≥ ${_waterGoal.toStringAsFixed(0)} oz/day  |  Oxalate ≤ ${_oxGoal.toStringAsFixed(0)} mg/day',
    );
    buf.writeln();
    buf.writeln('─── SUMMARY ────────────────────');
    buf.writeln('Days logged          : ${stats['daysLogged']}');
    buf.writeln(
      'Avg daily water      : ${(stats['avgWater'] as double).toStringAsFixed(1)} oz',
    );
    buf.writeln(
      'Avg daily oxalate    : ${(stats['avgOxalate'] as double).toStringAsFixed(1)} mg',
    );
    buf.writeln(
      'Water goal met       : ${stats['waterGoalDays']} / ${stats['daysLogged']} days  (${stats['waterPct']}%)',
    );
    buf.writeln(
      'Oxalate goal met     : ${stats['oxalateGoalDays']} / ${stats['daysLogged']} days  (${stats['oxalatePct']}%)',
    );
    buf.writeln();
    buf.writeln('─── DAILY LOG ──────────────────');
    buf.writeln('Date         Water(oz)  Oxalate(mg)');
    buf.writeln('─────────────────────────────────');

    for (final e in _entries) {
      final d = _fmt(e['date'] as DateTime);
      final w = (e['water_oz'] as double).toStringAsFixed(1).padLeft(9);
      final o = (e['oxalate_mg'] as double).toStringAsFixed(1).padLeft(11);
      buf.writeln('$d  $w  $o');
    }

    buf.writeln();
    buf.writeln('─── DISCLAIMER ─────────────────');
    buf.writeln('StoneGuard is a self-tracking tool only.');
    buf.writeln('This report does not replace clinical evaluation,');
    buf.writeln('lab results, imaging, or medical advice.');
    buf.writeln('Please review with your healthcare provider.');
    buf.writeln();
    buf.writeln(
      'Privacy Policy: https://www.freeprivacypolicy.com/live/c256b9ff-8fd7-4252-ac3b-2cc80b29633f',
    );
    return buf.toString();
  }

  Future<Uint8List> _buildPdf() async {
    final stats = _computeStats();
    final now = DateTime.now();
    final dateFrom =
    _entries.isNotEmpty ? _fmt(_entries.first['date'] as DateTime) : '—';
    final dateTo =
    _entries.isNotEmpty ? _fmt(_entries.last['date'] as DateTime) : '—';

    final pdf = pw.Document();
    const pdfTeal = PdfColor.fromInt(0xFF1A8A9A);
    const pdfRed = PdfColor.fromInt(0xFFD36B6B);
    const pdfGrey = PdfColor.fromInt(0xFF888888);
    const pdfLight = PdfColor.fromInt(0xFFF0F4F5);
    const pdfBorder = PdfColor.fromInt(0xFFD0D0D8);
    const pdfBlack = PdfColor.fromInt(0xFF2C2C2C);
    const pdfWhite = PdfColors.white;

    pw.Widget sectionHeader(String title) => pw.Container(
      margin: const pw.EdgeInsets.only(top: 16, bottom: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const pw.BoxDecoration(
        color: pdfTeal,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: pdfWhite,
          fontWeight: pw.FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );

    pw.Widget barChart({
      required List<double> values,
      required double goal,
      required PdfColor barColor,
      required String unit,
      required bool goalIsMax,
    }) {
      if (values.isEmpty) {
        return pw.Text('No data', style: const pw.TextStyle(color: pdfGrey));
      }

      const chartH = 100.0;
      const chartW = 460.0;
      final maxVal = values.fold(0.0, (m, v) => v > m ? v : m);
      final scaleMax = (goal > maxVal ? goal : maxVal) * 1.15;
      final barW = (chartW / values.length).clamp(2.0, 14.0);
      final gap = (barW * 0.2).clamp(1.0, 3.0);

      return pw.SizedBox(
        width: chartW,
        height: chartH + 24,
        child: pw.Stack(
          children: [
            pw.Positioned(
              left: 0,
              right: 0,
              bottom: 24 + (goal / scaleMax) * chartH - 1,
              child: pw.Container(
                height: 1.5,
                color: PdfColor(
                  barColor.red,
                  barColor.green,
                  barColor.blue,
                  0.4,
                ),
              ),
            ),
            pw.Positioned(
              right: 0,
              bottom: 24 + (goal / scaleMax) * chartH + 2,
              child: pw.Text(
                'goal ${goal.toStringAsFixed(0)} $unit',
                style: pw.TextStyle(
                  fontSize: 7,
                  color: barColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              top: 0,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: values.map((v) {
                  final h = scaleMax == 0 ? 0.0 : (v / scaleMax) * chartH;
                  final met = goalIsMax ? v >= goal : v <= goal;
                  return pw.Padding(
                    padding: pw.EdgeInsets.only(right: gap),
                    child: pw.Container(
                      width: barW,
                      height: h.clamp(2.0, chartH),
                      decoration: pw.BoxDecoration(
                        color: met ? barColor : pdfRed,
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(2),
                          topRight: pw.Radius.circular(2),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            pw.Positioned(
              left: 0,
              right: 0,
              bottom: 23,
              child: pw.Container(height: 1, color: pdfBorder),
            ),
          ],
        ),
      );
    }

    final waterValues = _entries.map((e) => e['water_oz'] as double).toList();
    final oxalateValues =
    _entries.map((e) => e['oxalate_mg'] as double).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'StoneGuard',
                      style: pw.TextStyle(
                        color: pdfTeal,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Doctor Report',
                      style: const pw.TextStyle(color: pdfGrey, fontSize: 11),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (_userName.isNotEmpty)
                      pw.Text(
                        'Patient: $_userName',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: pdfBlack,
                        ),
                      ),
                    pw.Text(
                      'Generated: ${_fmt(now)}',
                      style: const pw.TextStyle(fontSize: 9, color: pdfGrey),
                    ),
                    pw.Text(
                      'Period: $dateFrom → $dateTo',
                      style: const pw.TextStyle(fontSize: 9, color: pdfGrey),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(color: pdfTeal, thickness: 1.5),
            pw.SizedBox(height: 4),
          ],
        ),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: pdfLight,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: pdfBorder, width: 0.5),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: const pw.BoxDecoration(
                          color: pdfTeal,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        'Water goal: ≥ ${_waterGoal.toStringAsFixed(0)} oz/day',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: pdfTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 10,
                        height: 10,
                        decoration: const pw.BoxDecoration(
                          color: pdfRed,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        'Oxalate limit: ≤ ${_oxGoal.toStringAsFixed(0)} mg/day',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: pdfRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          sectionHeader('Summary ($_daysBack-Day Window)'),
          pw.Table(
            border: pw.TableBorder.all(color: pdfBorder, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: pdfLight),
                children: [
                  _cell('Metric', bold: true),
                  _cell('Value', bold: true),
                  _cell('Goal Met', bold: true),
                  _cell('%', bold: true),
                ],
              ),
              pw.TableRow(
                children: [
                  _cell('Days Logged'),
                  _cell('${stats['daysLogged']}'),
                  _cell('—'),
                  _cell('—'),
                ],
              ),
              pw.TableRow(
                children: [
                  _cell('Avg Daily Water'),
                  _cell('${(stats['avgWater'] as double).toStringAsFixed(1)} oz'),
                  _cell('${stats['waterGoalDays']} / ${stats['daysLogged']} days'),
                  _cell(
                    '${stats['waterPct']}%',
                    color: (stats['waterPct'] as int) >= 70 ? pdfTeal : pdfRed,
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  _cell('Avg Daily Oxalate'),
                  _cell('${(stats['avgOxalate'] as double).toStringAsFixed(1)} mg'),
                  _cell('${stats['oxalateGoalDays']} / ${stats['daysLogged']} days'),
                  _cell(
                    '${stats['oxalatePct']}%',
                    color: (stats['oxalatePct'] as int) >= 70 ? pdfTeal : pdfRed,
                  ),
                ],
              ),
            ],
          ),
          sectionHeader('Daily Water Intake (oz)'),
          pw.Text(
            'Teal bars = goal met (≥ ${_waterGoal.toStringAsFixed(0)} oz)  •  Red bars = below goal',
            style: const pw.TextStyle(fontSize: 8, color: pdfGrey),
          ),
          pw.SizedBox(height: 6),
          barChart(
            values: waterValues,
            goal: _waterGoal,
            barColor: pdfTeal,
            unit: 'oz',
            goalIsMax: true,
          ),
          sectionHeader('Daily Oxalate Load (mg)'),
          pw.Text(
            'Teal bars = goal met (≤ ${_oxGoal.toStringAsFixed(0)} mg)  •  Red bars = over limit',
            style: const pw.TextStyle(fontSize: 8, color: pdfGrey),
          ),
          pw.SizedBox(height: 6),
          barChart(
            values: oxalateValues,
            goal: _oxGoal,
            barColor: pdfTeal,
            unit: 'mg',
            goalIsMax: false,
          ),
          sectionHeader('Daily Log'),
          pw.Table(
            border: pw.TableBorder.all(color: pdfBorder, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: pdfLight),
                children: [
                  _cell('Date', bold: true),
                  _cell('Water (oz)', bold: true),
                  _cell('Oxalate (mg)', bold: true),
                  _cell('Water ✓', bold: true),
                  _cell('Oxalate ✓', bold: true),
                ],
              ),
              ..._entries.map((e) {
                final d = e['date'] as DateTime;
                final w = e['water_oz'] as double;
                final o = e['oxalate_mg'] as double;
                final wOk = w >= _waterGoal;
                final oOk = o <= _oxGoal;

                return pw.TableRow(
                  children: [
                    _cell(_fmt(d)),
                    _cell(w.toStringAsFixed(1)),
                    _cell(o.toStringAsFixed(1)),
                    _cell(wOk ? '✓' : '✗', color: wOk ? pdfTeal : pdfRed),
                    _cell(oOk ? '✓' : '✗', color: oOk ? pdfTeal : pdfRed),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: pdfLight,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              border: pw.Border.all(color: pdfBorder, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Disclaimer',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfBlack,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'StoneGuard is a self-tracking tool only. This report does not replace clinical evaluation, lab results, imaging, or medical advice. Please review with your healthcare provider.',
                  style: const pw.TextStyle(fontSize: 8, color: pdfGrey),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Privacy Policy: https://www.freeprivacypolicy.com/live/c256b9ff-8fd7-4252-ac3b-2cc80b29633f',
                  style: const pw.TextStyle(fontSize: 7, color: pdfGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _cell(String text, {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? const PdfColor.fromInt(0xFF2C2C2C),
        ),
      ),
    );
  }

  Future<void> _shareText() async {
    if (!_isPremium) {
      await _openPaywall();
      return;
    }

    final text = _buildReportText();
    await Share.share(text, subject: 'StoneGuard Doctor Report');
  }

  Future<void> _sharePdf() async {
    if (!_isPremium) {
      await _openPaywall();
      return;
    }

    final pdfBytes = await _buildPdf();
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'StoneGuard_Report_${_fmt(DateTime.now())}.pdf',
    );
  }

  void _showExportSheet() {
    if (!_isPremium) {
      _openPaywall();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Export Report',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _textPri,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose a format to share with your doctor.',
                style: TextStyle(fontSize: 13, color: _textMuted),
              ),
              const SizedBox(height: 20),
              _exportOption(
                icon: Icons.picture_as_pdf_rounded,
                iconColor: const Color(0xFFD32F2F),
                title: 'PDF Report',
                subtitle:
                'Charts, summary table & full daily log — best for printing or emailing',
                onTap: () {
                  Navigator.pop(context);
                  _sharePdf();
                },
              ),
              const SizedBox(height: 12),
              _exportOption(
                icon: Icons.text_snippet_outlined,
                iconColor: _teal,
                title: 'Plain Text',
                subtitle:
                'Simple text — great for texting or copying into a patient portal',
                onTap: () {
                  Navigator.pop(context);
                  _shareText();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exportOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _textPri,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canExport = _isPremium && !_isLoading && _entries.isNotEmpty;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _appBar,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textPri),
        title: const Text(
          'Doctor View',
          style: TextStyle(color: _textPri, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isLoading && _entries.isNotEmpty)
            Tooltip(
              message: _isPremium ? 'Export report' : 'StoneGuard Plus required',
              child: IconButton(
                icon: const Icon(Icons.ios_share_rounded, color: _teal),
                onPressed: _showExportSheet,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          _buildTimeframePicker(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isPremium) _buildPremiumBanner(),
                  _buildHeaderNote(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildLineCard(
                    title:
                    'Daily Water Intake (oz) — goal ${_waterGoal.toStringAsFixed(0)} oz',
                    color: _teal,
                    goal: _waterGoal,
                    valueSelector: (e) =>
                        (e['water_oz'] as num).toDouble(),
                  ),
                  const SizedBox(height: 16),
                  _buildLineCard(
                    title:
                    'Daily Oxalate Load (mg) — limit ${_oxGoal.toStringAsFixed(0)} mg',
                    color: _red,
                    goal: _oxGoal,
                    valueSelector: (e) =>
                        (e['oxalate_mg'] as num).toDouble(),
                  ),
                  const SizedBox(height: 16),
                  _buildExportCard(canExport: canExport),
                  const SizedBox(height: 8),
                  _buildDisclaimer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF6F8),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFB2DDE4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.lock_outline, color: _teal, size: 22),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Free preview: 30 days only. Upgrade to StoneGuard Plus for 6M and 12M Doctor View, report export, and ad removal.',
            style: TextStyle(
              color: _textPri,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildTimeframePicker() {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: _timeframes.map((tf) {
          final isSelected = _daysBack == tf['days'];
          final isLocked = tf['premium'] == true && !_isPremium;

          return GestureDetector(
            onTap: () => _selectTimeframe(tf),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _teal : _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? _teal : _border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tf['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _textPri,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLocked) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: isSelected ? Colors.white : _textMuted,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderNote() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        'For your healthcare provider',
        style: TextStyle(
          color: _textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      SizedBox(height: 4),
      Text(
        'These charts show my daily water intake and oxalate load. Please review together with labs, imaging, and clinical history.',
        style: TextStyle(color: _textMuted, fontSize: 12, height: 1.4),
      ),
    ],
  );

  Widget _buildSummaryCard() {
    final s = _computeStats();
    final daysLogged = s['daysLogged'] as int;
    final avgWater = s['avgWater'] as double;
    final avgOxalate = s['avgOxalate'] as double;
    final waterPct = s['waterPct'] as int;
    final oxalatePct = s['oxalatePct'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              color: _textPri,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile('Days Logged', '$daysLogged', _textPri),
              _statTile('Avg Water', '${avgWater.toStringAsFixed(1)} oz', _teal),
              _statTile(
                'Avg Oxalate',
                '${avgOxalate.toStringAsFixed(1)} mg',
                _red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile('Water Goal Met', '$waterPct%', _teal),
              _statTile(
                'Oxalate Goal Met',
                '$oxalatePct%',
                oxalatePct >= 70 ? const Color(0xFF4CAF50) : _red,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color valueColor) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );

  Widget _buildLineCard({
    required String title,
    required Color color,
    required double goal,
    required double Function(Map<String, dynamic>) valueSelector,
  }) {
    if (_entries.isEmpty) return _emptyCard('No data to display yet.');

    final spots = <FlSpot>[
      for (int i = 0; i < _entries.length; i++)
        FlSpot(i.toDouble(), valueSelector(_entries[i])),
    ];

    double maxY = spots.fold(0.0, (m, s) => s.y > m ? s.y : m);
    if (goal > maxY) maxY = goal;
    if (maxY == 0) maxY = 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textPri,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
                minY: 0,
                maxY: maxY * 1.2,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) =>
                  const FlLine(color: Color(0xFFE0E0E0), strokeWidth: 1),
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
                      interval: maxY / 4,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          v.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 9, color: _textMuted),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: _entries.length > 1
                          ? (_entries.length / 4).ceilToDouble()
                          : 1,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= _entries.length) {
                          return const SizedBox.shrink();
                        }
                        final d = _entries[idx]['date'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${d.month}/${d.day}',
                            style: const TextStyle(fontSize: 9, color: _textMuted),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goal,
                      color: color.withAlpha(120),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                        labelResolver: (_) => 'goal',
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: color,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: spots.length <= 30,
                      getDotPainter: (spot, idx, bar, pct) => FlDotCirclePainter(
                        radius: 3,
                        color: color,
                        strokeWidth: 0,
                        strokeColor: Colors.transparent,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withAlpha(25),
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

  Widget _buildExportCard({required bool canExport}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF6F8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFB2DDE4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.ios_share_rounded, color: _teal, size: 28),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share with your doctor',
                style: TextStyle(
                  color: _textPri,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Export as a PDF (with charts) or plain text — ready to email, text, or print.',
                style: TextStyle(
                  color: _textMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: canExport ? _showExportSheet : _openPaywall,
          style: ElevatedButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            canExport ? 'Export' : 'Plus only',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildDisclaimer() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      'StoneGuard is a self-tracking tool only. This report does not replace clinical evaluation, lab results, imaging, or medical advice. Please review with your healthcare provider.',
      style: TextStyle(
        color: Color(0xFFAAAAAA),
        fontSize: 11,
        height: 1.4,
      ),
    ),
  );

  Widget _buildEmptyState() => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 56, color: Color(0xFFCCCCCC)),
          SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              color: Color(0xFF2C2C2C),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Log water and food for a few days, then come back here to see your report and share it with your doctor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyCard(String message) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: Text(message, style: const TextStyle(color: _textMuted)),
  );
}