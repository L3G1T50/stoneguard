import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'export_report_screen.dart';

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
    {'label': '30D',  'days': 30,  'premium': false},
    {'label': '6M',   'days': 180, 'premium': true},
    {'label': '12M',  'days': 365, 'premium': true},
    {'label': '2Y',   'days': 730, 'premium': true},
  ];

  List<Map<String, dynamic>> _entries = [];
  List<Map<String, dynamic>> _foodEntries = [];

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

  List<Map<String, dynamic>> _parseFoodLog(
      SharedPreferences prefs, DateTime cutoff) {
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = 0; i <= _daysBack; i++) {
      final d = now.subtract(Duration(days: i));
      if (d.isBefore(cutoff)) break;
      final key = 'oxalate_log_${d.year}_${d.month}_${d.day}';
      final raw = prefs.getStringList(key) ?? [];
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      for (final item in raw) {
        try {
          final map = jsonDecode(item) as Map<String, dynamic>;
          result.add({
            'date': dateStr,
            'food': map['name'] ?? map['food'] ?? 'Unknown',
            'oxalate_mg': (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0,
          });
        } catch (_) {}
      }
    }
    result.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    return result;
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
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    final foodEntries = _parseFoodLog(prefs, cutoff);

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _foodEntries = foodEntries;
      _isLoading = false;
    });
  }

  Future<void> _openPaywall() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    if (!mounted) return;
    if (result == true) await _loadData();
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
        'currentStreak': 0,
        'bestWaterDay': '—',
        'bestWaterVal': 0.0,
        'worstOxDay': '—',
        'worstOxVal': 0.0,
        'trend': 'Not enough data',
      };
    }

    double tw = 0, to = 0;
    int wg = 0, og = 0;
    double bestWater = -1;
    String bestWaterDay = '—';
    double worstOx = -1;
    String worstOxDay = '—';

    for (final e in _entries) {
      final w = e['water_oz'] as double;
      final o = e['oxalate_mg'] as double;
      tw += w;
      to += o;
      if (w >= _waterGoal) wg++;
      if (o <= _oxGoal) og++;
      if (w > bestWater) {
        bestWater = w;
        bestWaterDay = _fmt(e['date'] as DateTime);
      }
      if (o > worstOx) {
        worstOx = o;
        worstOxDay = _fmt(e['date'] as DateTime);
      }
    }

    final n = _entries.length;
    final avgW = tw / n;

    String trend = 'Stable';
    if (n >= 14) {
      final recent = _entries.sublist(n - 7);
      final prior  = _entries.sublist(n - 14, n - 7);
      final rAvg = recent.fold(0.0, (s, e) => s + (e['water_oz'] as double)) / 7;
      final pAvg = prior.fold(0.0, (s, e) => s + (e['water_oz'] as double)) / 7;
      if (rAvg > pAvg + 5) {
        trend = '📈 Improving (water intake up)';
      } else if (rAvg < pAvg - 5) {
        trend = '📉 Declining (water intake down)';
      } else {
        trend = '➡️ Stable';
      }
    }

    int streak = 0;
    for (int i = _entries.length - 1; i >= 0; i--) {
      final e = _entries[i];
      final w = e['water_oz'] as double;
      final o = e['oxalate_mg'] as double;
      if (w >= _waterGoal && o <= _oxGoal) {
        streak++;
      } else {
        break;
      }
    }

    return {
      'daysLogged': n,
      'avgWater': avgW,
      'avgOxalate': to / n,
      'waterGoalDays': wg,
      'oxalateGoalDays': og,
      'waterPct': ((wg / n) * 100).round(),
      'oxalatePct': ((og / n) * 100).round(),
      'currentStreak': streak,
      'bestWaterDay': bestWaterDay,
      'bestWaterVal': bestWater,
      'worstOxDay': worstOxDay,
      'worstOxVal': worstOx,
      'trend': trend,
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
        'Goals     : Water ≥ ${_waterGoal.toStringAsFixed(0)} oz/day  |  Oxalate ≤ ${_oxGoal.toStringAsFixed(0)} mg/day');
    buf.writeln();
    buf.writeln('─── SUMMARY ────────────────────');
    buf.writeln('Days logged          : ${stats['daysLogged']}');
    buf.writeln(
        'Avg daily water      : ${(stats['avgWater'] as double).toStringAsFixed(1)} oz');
    buf.writeln(
        'Avg daily oxalate    : ${(stats['avgOxalate'] as double).toStringAsFixed(1)} mg');
    buf.writeln(
        'Water goal met       : ${stats['waterGoalDays']} / ${stats['daysLogged']} days  (${stats['waterPct']}%)');
    buf.writeln(
        'Oxalate goal met     : ${stats['oxalateGoalDays']} / ${stats['daysLogged']} days  (${stats['oxalatePct']}%)');
    buf.writeln('Current streak       : ${stats['currentStreak']} days (both goals met)');
    buf.writeln('Hydration trend      : ${stats['trend']}');
    buf.writeln(
        'Best water day       : ${stats['bestWaterDay']} (${(stats['bestWaterVal'] as double).toStringAsFixed(1)} oz)');
    buf.writeln(
        'Highest oxalate day  : ${stats['worstOxDay']} (${(stats['worstOxVal'] as double).toStringAsFixed(1)} mg)');
    buf.writeln();
    buf.writeln('─── DAILY LOG ──────────────────');
    buf.writeln('Date         Water(oz)  Oxalate(mg)  Water✓  Ox✓');
    buf.writeln('──────────────────────────────────────────────────');
    for (final e in _entries) {
      final d = _fmt(e['date'] as DateTime);
      final w = (e['water_oz'] as double);
      final o = (e['oxalate_mg'] as double);
      final wOk = w >= _waterGoal ? '✓' : '✗';
      final oOk = o <= _oxGoal ? '✓' : '✗';
      buf.writeln('$d  ${w.toStringAsFixed(1).padLeft(9)}  ${o.toStringAsFixed(1).padLeft(11)}   $wOk      $oOk');
    }
    if (_foodEntries.isNotEmpty) {
      buf.writeln();
      buf.writeln('─── FOOD LOG (top oxalate items) ───');
      final sorted = List.of(_foodEntries)
        ..sort((a, b) =>
            (b['oxalate_mg'] as double).compareTo(a['oxalate_mg'] as double));
      final top = sorted.take(20);
      for (final f in top) {
        buf.writeln(
            '${f['date']}  ${(f['food'] as String).padRight(28)}  ${(f['oxalate_mg'] as double).toStringAsFixed(1)} mg');
      }
    }
    buf.writeln();
    buf.writeln('─── DISCLAIMER ─────────────────');
    buf.writeln('StoneGuard is a self-tracking tool only.');
    buf.writeln('This report does not replace clinical evaluation,');
    buf.writeln('lab results, imaging, or medical advice.');
    buf.writeln('Please review with your healthcare provider.');
    buf.writeln();
    buf.writeln(
        'Privacy Policy: https://www.freeprivacypolicy.com/live/c256b9ff-8fd7-4252-ac3b-2cc80b29633f');
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
    const pdfTeal   = PdfColor.fromInt(0xFF1A8A9A);
    const pdfRed    = PdfColor.fromInt(0xFFD36B6B);
    const pdfGrey   = PdfColor.fromInt(0xFF888888);
    const pdfLight  = PdfColor.fromInt(0xFFF0F4F5);
    const pdfBorder = PdfColor.fromInt(0xFFD0D0D8);
    const pdfBlack  = PdfColor.fromInt(0xFF2C2C2C);
    const pdfWhite  = PdfColors.white;

    pw.Widget sectionHeader(String title) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 16, bottom: 6),
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              left: 0, right: 0,
              bottom: 24 + (goal / scaleMax) * chartH - 1,
              child: pw.Container(
                height: 1.5,
                color: PdfColor(barColor.red, barColor.green, barColor.blue, 0.4),
              ),
            ),
            pw.Positioned(
              right: 0,
              bottom: 24 + (goal / scaleMax) * chartH + 2,
              child: pw.Text(
                'goal ${goal.toStringAsFixed(0)} $unit',
                style: pw.TextStyle(
                    fontSize: 7, color: barColor, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Positioned(
              left: 0, right: 0, bottom: 24, top: 0,
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
              left: 0, right: 0, bottom: 23,
              child: pw.Container(height: 1, color: pdfBorder),
            ),
          ],
        ),
      );
    }

    final waterValues = _entries.map((e) => e['water_oz'] as double).toList();
    final oxalateValues = _entries.map((e) => e['oxalate_mg'] as double).toList();

    final topFoods = List.of(_foodEntries)
      ..sort((a, b) =>
          (b['oxalate_mg'] as double).compareTo(a['oxalate_mg'] as double));
    final top15 = topFoods.take(15).toList();

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
                    pw.Text('StoneGuard',
                        style: pw.TextStyle(
                            color: pdfTeal,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text('Doctor Report',
                        style: const pw.TextStyle(color: pdfGrey, fontSize: 11)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (_userName.isNotEmpty)
                      pw.Text('Patient: $_userName',
                          style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: pdfBlack)),
                    pw.Text('Generated: ${_fmt(now)}',
                        style: const pw.TextStyle(fontSize: 9, color: pdfGrey)),
                    pw.Text('Period: $dateFrom → $dateTo',
                        style: const pw.TextStyle(fontSize: 9, color: pdfGrey)),
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
                  child: pw.Row(children: [
                    pw.Container(
                      width: 10, height: 10,
                      decoration: const pw.BoxDecoration(
                          color: pdfTeal, shape: pw.BoxShape.circle),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text('Water goal: ≥ ${_waterGoal.toStringAsFixed(0)} oz/day',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfTeal)),
                  ]),
                ),
                pw.Expanded(
                  child: pw.Row(children: [
                    pw.Container(
                      width: 10, height: 10,
                      decoration: const pw.BoxDecoration(
                          color: pdfRed, shape: pw.BoxShape.circle),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text('Oxalate limit: ≤ ${_oxGoal.toStringAsFixed(0)} mg/day',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfRed)),
                  ]),
                ),
              ],
            ),
          ),

          sectionHeader('Summary ($_daysBack-Day Window)'),
          pw.Table(
            border: pw.TableBorder.all(color: pdfBorder, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.2),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(0.8),
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
              pw.TableRow(children: [
                _cell('Days Logged'),
                _cell('${stats['daysLogged']}'),
                _cell('—'), _cell('—'),
              ]),
              pw.TableRow(children: [
                _cell('Avg Daily Water'),
                _cell('${(stats['avgWater'] as double).toStringAsFixed(1)} oz'),
                _cell('${stats['waterGoalDays']} / ${stats['daysLogged']} days'),
                _cell('${stats['waterPct']}%',
                    color: (stats['waterPct'] as int) >= 70 ? pdfTeal : pdfRed),
              ]),
              pw.TableRow(children: [
                _cell('Avg Daily Oxalate'),
                _cell('${(stats['avgOxalate'] as double).toStringAsFixed(1)} mg'),
                _cell('${stats['oxalateGoalDays']} / ${stats['daysLogged']} days'),
                _cell('${stats['oxalatePct']}%',
                    color: (stats['oxalatePct'] as int) >= 70 ? pdfTeal : pdfRed),
              ]),
              pw.TableRow(children: [
                _cell('Current Streak'),
                _cell('${stats['currentStreak']} days'),
                _cell('Both goals met'), _cell('—'),
              ]),
              pw.TableRow(children: [
                _cell('Hydration Trend'),
                _cell('${stats['trend']}', colspan: 3),
                _cell(''), _cell(''),
              ]),
              pw.TableRow(children: [
                _cell('Best Water Day'),
                _cell('${stats['bestWaterDay']}'),
                _cell('${(stats['bestWaterVal'] as double).toStringAsFixed(1)} oz'),
                _cell(''),
              ]),
              pw.TableRow(children: [
                _cell('Highest Oxalate Day'),
                _cell('${stats['worstOxDay']}'),
                _cell('${(stats['worstOxVal'] as double).toStringAsFixed(1)} mg'),
                _cell(''),
              ]),
            ],
          ),

          sectionHeader('Daily Hydration (oz)'),
          barChart(
            values: waterValues,
            goal: _waterGoal,
            barColor: pdfTeal,
            unit: 'oz',
            goalIsMax: true,
          ),

          sectionHeader('Daily Oxalate (mg)'),
          barChart(
            values: oxalateValues,
            goal: _oxGoal,
            barColor: pdfRed,
            unit: 'mg',
            goalIsMax: false,
          ),

          if (top15.isNotEmpty) ...[
            sectionHeader('Top Oxalate Foods (last $_daysBack days)'),
            pw.Table(
              border: pw.TableBorder.all(color: pdfBorder, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1.3),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: pdfLight),
                  children: [
                    _cell('Date', bold: true),
                    _cell('Food', bold: true),
                    _cell('Oxalate (mg)', bold: true),
                  ],
                ),
                ...top15.map((f) => pw.TableRow(children: [
                      _cell(f['date'] as String),
                      _cell(f['food'] as String),
                      _cell(
                          '${(f['oxalate_mg'] as double).toStringAsFixed(1)} mg',
                          color: (f['oxalate_mg'] as double) > 50
                              ? pdfRed
                              : pdfBlack),
                    ])),
              ],
            ),
          ],

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
                pw.Text('Disclaimer',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                        color: pdfBlack)),
                pw.SizedBox(height: 4),
                pw.Text(
                  'StoneGuard is a self-tracking tool only. This report does not replace clinical '
                  'evaluation, lab results, imaging, or medical advice. Please review with your '
                  'healthcare provider.',
                  style: const pw.TextStyle(fontSize: 9, color: pdfGrey),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Privacy Policy: https://www.freeprivacypolicy.com/live/c256b9ff-8fd7-4252-ac3b-2cc80b29633f',
                  style: const pw.TextStyle(fontSize: 8, color: pdfGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cell(String text,
      {bool bold = false, PdfColor? color, int colspan = 1}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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

  @override
  Widget build(BuildContext context) {
    final stats = _computeStats();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _appBar,
        elevation: 0,
        title: const Text(
          'Doctor Report',
          style: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Export',
            onSelected: (val) async {
              if (val == 'text') {
                final text = _buildReportText();
                await SharePlus.instance.share(ShareParams(text: text));
              } else if (val == 'pdf') {
                final bytes = await _buildPdf();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExportReportScreen(pdfBytes: bytes),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'text', child: Text('Share as Text')),
              PopupMenuItem(value: 'pdf',  child: Text('Export as PDF')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(stats),
    );
  }

  Widget _buildBody(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _timeframeRow(),
          const SizedBox(height: 16),
          if (_entries.isEmpty)
            _emptyState()
          else ...[
            _summaryGrid(stats),
            const SizedBox(height: 16),
            _trendCard(stats),
            const SizedBox(height: 16),
            _chartCard(
              title: 'Daily Hydration (oz)',
              entries: _entries,
              valueKey: 'water_oz',
              goal: _waterGoal,
              color: _teal,
              goalIsMax: true,
            ),
            const SizedBox(height: 16),
            _chartCard(
              title: 'Daily Oxalate (mg)',
              entries: _entries,
              valueKey: 'oxalate_mg',
              goal: _oxGoal,
              color: _red,
              goalIsMax: false,
            ),
            const SizedBox(height: 16),
            if (_foodEntries.isNotEmpty) _foodTable(),
            const SizedBox(height: 16),
            _disclaimer(),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No data for this period.\nStart logging hydration & food to see your report.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );

  Widget _timeframeRow() => Row(
        children: _timeframes.map((tf) {
          final selected = tf['days'] == _daysBack;
          final isPremiumOnly = tf['premium'] == true;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectTimeframe(tf),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? _teal : _surface,
                  border: Border.all(
                      color: selected ? _teal : _border, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tf['label'] as String,
                      style: TextStyle(
                        color: selected ? Colors.white : _textPri,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (isPremiumOnly && !_isPremium) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.lock_outline,
                          size: 12,
                          color: selected ? Colors.white70 : _textMuted),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );

  Widget _statTile(String label, String value, {Color? valueColor}) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: valueColor ?? _textPri,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _summaryGrid(Map<String, dynamic> stats) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: [
          _statTile('Days Logged', '${stats['daysLogged']}'),
          _statTile('Avg Water / Day',
              '${(stats['avgWater'] as double).toStringAsFixed(1)} oz',
              valueColor: _teal),
          _statTile('Avg Oxalate / Day',
              '${(stats['avgOxalate'] as double).toStringAsFixed(1)} mg',
              valueColor: _red),
          _statTile('Current Streak', '${stats['currentStreak']} days'),
          _statTile('Water Goal Met', '${stats['waterPct']}%',
              valueColor:
                  (stats['waterPct'] as int) >= 70 ? _teal : _red),
          _statTile('Oxalate Goal Met', '${stats['oxalatePct']}%',
              valueColor:
                  (stats['oxalatePct'] as int) >= 70 ? _teal : _red),
        ],
      );

  Widget _trendCard(Map<String, dynamic> stats) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.trending_up_outlined,
                color: Color(0xFF1A8A9A), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hydration Trend',
                      style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('${stats['trend']}',
                      style: const TextStyle(
                          color: Color(0xFF2C2C2C),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _chartCard({
    required String title,
    required List<Map<String, dynamic>> entries,
    required String valueKey,
    required double goal,
    required Color color,
    required bool goalIsMax,
  }) {
    final values = entries.map((e) => e[valueKey] as double).toList();
    if (values.isEmpty) return const SizedBox.shrink();

    final maxVal = values.fold(0.0, (m, v) => v > m ? v : m);
    final scaleMax = (goal > maxVal ? goal : maxVal) * 1.15;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: scaleMax,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: goal,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: color.withAlpha(60),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  drawVerticalLine: false,
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: values.asMap().entries.map((e) {
                  final met = goalIsMax ? e.value >= goal : e.value <= goal;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.clamp(0.5, scaleMax),
                        color: met ? color : _red,
                        width: (300 / values.length).clamp(2, 14),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _legend(color,
                  goalIsMax ? '≥ ${goal.toStringAsFixed(0)}' : '≤ ${goal.toStringAsFixed(0)}',
                  'Goal'),
              const SizedBox(width: 16),
              _legend(_red, 'Missed goal', ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label, String sub) => Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 4),
          Text('$label $sub',
              style: TextStyle(color: _textMuted, fontSize: 11)),
        ],
      );

  Widget _foodTable() {
    final sorted = List.of(_foodEntries)
      ..sort((a, b) =>
          (b['oxalate_mg'] as double).compareTo(a['oxalate_mg'] as double));
    final top = sorted.take(15).toList();

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text('Top Oxalate Foods',
                style: const TextStyle(
                    color: Color(0xFF2C2C2C),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          const Divider(height: 1),
          ...top.map((f) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(f['food'] as String,
                          style: const TextStyle(
                              color: Color(0xFF2C2C2C), fontSize: 13)),
                    ),
                    Text(f['date'] as String,
                        style: TextStyle(color: _textMuted, fontSize: 11)),
                    const SizedBox(width: 12),
                    Text(
                        '${(f['oxalate_mg'] as double).toStringAsFixed(1)} mg',
                        style: TextStyle(
                            color: (f['oxalate_mg'] as double) > 50
                                ? _red
                                : _textPri,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _disclaimer() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _border),
        ),
        child: const Text(
          'StoneGuard is a self-tracking tool only. This report does not replace clinical '
          'evaluation, lab results, imaging, or medical advice. Please review with your '
          'healthcare provider.',
          style: TextStyle(color: Color(0xFF888888), fontSize: 12),
        ),
      );
}
