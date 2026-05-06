import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  // ── Colours ─────────────────────────────────────────────────────────────
  static const Color accentTeal  = Color(0xFF1A8A9A);
  static const Color cardColor   = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFD0D0D8);
  static const Color textColor   = Color(0xFF2C2C2C);
  static const Color mutedColor  = Color(0xFF888888);
  static const Color accentGreen = Color(0xFF2A9A5A);
  static const Color bgColor     = Color(0xFFF5F7FA);

  // ── State ────────────────────────────────────────────────────────────────
  bool   _isLoading     = true;
  bool   _isGenerating  = false;
  String _patientName   = 'Patient';
  double _oxalateGoal   = 200.0;
  double _waterGoal     = 80.0;
  int    _selectedDays  = 30;

  // Period options: days → display label
  static const List<Map<String, dynamic>> _periods = [
    {'days': 7,   'label': '7 Days'},
    {'days': 30,  'label': '30 Days'},
    {'days': 90,  'label': '90 Days'},
    {'days': 365, 'label': '1 Year'},
    {'days': 730, 'label': '2 Years'},
  ];

  // Loaded data
  Map<String, double> _dailyOxalate = {};
  Map<String, double> _dailyWater   = {};
  int    _currentStreak   = 0;
  int    _totalDaysLogged = 0;
  double _avgOxalate      = 0;
  double _avgWater        = 0;
  int    _daysUnderGoal   = 0;
  int    _daysMetWater    = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Data loading ─────────────────────────────────────────────────────────
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _oxalateGoal = prefs.getDouble('goal_oxalate') ?? 200.0;
    _waterGoal   = prefs.getDouble('goal_water')   ?? 80.0;
    _patientName = prefs.getString('user_name')    ?? 'Patient';

    // Load full daily history
    final historyRaw = prefs.getStringList('daily_history') ?? [];
    final Map<String, double> oxMap  = {};
    final Map<String, double> watMap = {};
    for (final entry in historyRaw) {
      try {
        final map  = jsonDecode(entry) as Map<String, dynamic>;
        final date = map['date'] as String?;
        if (date == null) continue;
        oxMap[date]  = (map['oxalate_mg'] as num?)?.toDouble() ?? 0.0;
        watMap[date] = (map['water_oz']   as num?)?.toDouble() ?? 0.0;
      } catch (_) {}
    }

    // Merge today
    final now      = DateTime.now();
    final todayKey = '${now.year}_${now.month}_${now.day}';
    final todayStr = _dateKey(now);
    oxMap[todayStr]  = prefs.getDouble('oxalate_$todayKey') ?? 0.0;
    watMap[todayStr] = prefs.getDouble('water_$todayKey')   ?? 0.0;

    // Streak — cap at 730 days back
    int streak = 0;
    DateTime cursor = now;
    while (true) {
      final k   = _dateKey(cursor);
      final ox  = oxMap[k]  ?? 0.0;
      final wat = watMap[k] ?? 0.0;
      if (ox > 0 && ox <= _oxalateGoal && wat >= _waterGoal) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else break;
      if (cursor.isBefore(now.subtract(const Duration(days: 730)))) break;
    }

    setState(() {
      _dailyOxalate = oxMap;
      _dailyWater   = watMap;
      _currentStreak   = streak;
      _totalDaysLogged = oxMap.values.where((v) => v > 0).length;
      _isLoading = false;
    });

    _recalcStats();
  }

  void _recalcStats() {
    final now   = DateTime.now();
    double sumOx  = 0, sumWat = 0;
    int    logged = 0, underGoal = 0, metWater = 0;

    for (int i = 0; i < _selectedDays; i++) {
      final day = now.subtract(Duration(days: i));
      final k   = _dateKey(day);
      final ox  = _dailyOxalate[k]  ?? 0.0;
      final wat = _dailyWater[k]    ?? 0.0;
      if (ox > 0) {
        sumOx += ox;
        logged++;
        if (ox <= _oxalateGoal) underGoal++;
      }
      if (wat >= _waterGoal) metWater++;
      sumWat += wat;
    }

    setState(() {
      _avgOxalate   = logged > 0 ? sumOx / logged : 0;
      _avgWater     = sumWat / _selectedDays;
      _daysUnderGoal = underGoal;
      _daysMetWater  = metWater;
    });
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Human-readable label for the currently selected period
  String get _periodLabel {
    switch (_selectedDays) {
      case 7:   return 'Last 7 Days';
      case 30:  return 'Last 30 Days';
      case 90:  return 'Last 90 Days';
      case 365: return 'Last 1 Year';
      case 730: return 'Last 2 Years';
      default:  return 'Last $_selectedDays Days';
    }
  }

  // ── PDF Generation ─────────────────────────────────────────────────────
  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();
    final now  = DateTime.now();

    // Build all rows for the period, then drop days with zero oxalate AND zero water
    final allRows = <Map<String, dynamic>>[];
    for (int i = _selectedDays - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final k   = _dateKey(day);
      final ox  = _dailyOxalate[k] ?? 0.0;
      final wat = _dailyWater[k]   ?? 0.0;
      // Skip completely empty days
      if (ox == 0 && wat == 0) continue;
      allRows.add({
        'date':  '${day.month}/${day.day}/${day.year}',
        'ox':    ox,
        'wat':   wat,
        'oxOk':  ox == 0 ? null : ox <= _oxalateGoal,
        'watOk': wat >= _waterGoal,
      });
    }

    // PDF colours
    final pdfTeal  = PdfColor.fromHex('1A8A9A');
    final pdfGreen = PdfColor.fromHex('2A9A5A');
    final pdfRed   = PdfColor.fromHex('E07070');
    final pdfGray  = PdfColor.fromHex('888888');
    final pdfLight = PdfColor.fromHex('F0F4F7');
    final pdfWhite = PdfColors.white;

    final dateGenerated = '${now.month}/${now.day}/${now.year}';
    final reportPeriod  = _periodLabel;

    // Label for the daily log section header
    final loggedCount = allRows.length;
    final logLabel = loggedCount == 0
        ? 'Daily Log (no entries in this period)'
        : 'Daily Log ($loggedCount day${loggedCount == 1 ? '' : 's'} logged)';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(
                      color: PdfColor.fromInt(0xFF1A8A9A), width: 2))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('StoneGuard Health Report',
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: pdfTeal)),
                  pw.SizedBox(height: 2),
                  pw.Text('Calcium Oxalate Kidney Stone Prevention',
                      style: pw.TextStyle(fontSize: 9, color: pdfGray)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Generated: $dateGenerated',
                      style: pw.TextStyle(fontSize: 9, color: pdfGray)),
                  pw.Text('Period: $reportPeriod',
                      style: pw.TextStyle(fontSize: 9, color: pdfGray)),
                ],
              ),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
              border: pw.Border(
                  top: pw.BorderSide(
                      color: PdfColor.fromInt(0xFFD0D0D8), width: 1))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                  'This report was generated by StoneGuard and is for informational purposes only.',
                  style: pw.TextStyle(fontSize: 7, color: pdfGray)),
              pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: pw.TextStyle(fontSize: 8, color: pdfGray)),
            ],
          ),
        ),
        build: (ctx) => [
          // ── Patient Info ───────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
                color: pdfLight,
                borderRadius: pw.BorderRadius.circular(6)),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PATIENT',
                          style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: pdfGray,
                              letterSpacing: 1.2)),
                      pw.SizedBox(height: 3),
                      pw.Text(_patientName,
                          style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text('Stone Type: Calcium Oxalate',
                          style: pw.TextStyle(
                              fontSize: 10, color: pdfGray)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _pdfLabelValue('Oxalate Goal',
                        '${_oxalateGoal.toStringAsFixed(0)} mg/day', pdfTeal),
                    pw.SizedBox(height: 4),
                    _pdfLabelValue('Water Goal',
                        '${_waterGoal.toStringAsFixed(0)} oz/day', pdfTeal),
                    pw.SizedBox(height: 4),
                    _pdfLabelValue('Total Days Logged',
                        '$_totalDaysLogged days', pdfGray),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ── Summary stats ────────────────────────────────────────────
          pw.Text('Summary — $reportPeriod',
              style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: pdfTeal)),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _pdfStatBox('Avg Oxalate',
                  '${_avgOxalate.toStringAsFixed(0)} mg/day',
                  _avgOxalate <= _oxalateGoal ? pdfGreen : pdfRed,
                  pdfLight),
              pw.SizedBox(width: 8),
              _pdfStatBox('Avg Water',
                  '${_avgWater.toStringAsFixed(0)} oz/day',
                  _avgWater >= _waterGoal ? pdfGreen : pdfRed,
                  pdfLight),
              pw.SizedBox(width: 8),
              _pdfStatBox('Days Under\nOxalate Goal',
                  '$_daysUnderGoal / $_selectedDays',
                  _daysUnderGoal >= (_selectedDays * 0.8).round()
                      ? pdfGreen
                      : pdfRed,
                  pdfLight),
              pw.SizedBox(width: 8),
              _pdfStatBox('Days Met\nWater Goal',
                  '$_daysMetWater / $_selectedDays',
                  _daysMetWater >= (_selectedDays * 0.8).round()
                      ? pdfGreen
                      : pdfRed,
                  pdfLight),
              pw.SizedBox(width: 8),
              _pdfStatBox('Current\nStreak',
                  '$_currentStreak days',
                  _currentStreak >= 7 ? pdfGreen : pdfTeal,
                  pdfLight),
            ],
          ),
          pw.SizedBox(height: 20),

          // ── Doctor note ───────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                  color: PdfColor.fromInt(0xFF1A8A9A), width: 1),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Note for Physician',
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: pdfTeal)),
                pw.SizedBox(height: 6),
                pw.Text(
                  'This report was generated by the StoneGuard app, a kidney stone prevention '
                  'tracking tool for patients with calcium oxalate stones. The data below '
                  'reflects the patient\'s self-reported daily dietary oxalate intake (in mg) '
                  'and fluid intake (in oz) over the selected period. Goals are set by the '
                  'patient in consultation with their care team. Please review these trends '
                  'alongside clinical assessments.',
                  style: pw.TextStyle(fontSize: 9, color: pdfGray,
                      lineSpacing: 3),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ── Daily log table (logged days only) ───────────────────────────
          pw.Text(logLabel,
              style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: pdfTeal)),
          pw.SizedBox(height: 4),
          pw.Text('Only days with at least one entry are shown.',
              style: pw.TextStyle(fontSize: 8, color: pdfGray)),
          pw.SizedBox(height: 8),

          if (loggedCount == 0)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                  color: pdfLight,
                  borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Center(
                child: pw.Text(
                  'No entries recorded in this period.',
                  style: pw.TextStyle(fontSize: 10, color: pdfGray),
                ),
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromInt(0xFFD0D0D8), width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2.5),
                4: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: pdfTeal),
                  children: [
                    _tableCell('Date',         isHeader: true, textColor: pdfWhite),
                    _tableCell('Oxalate (mg)', isHeader: true, textColor: pdfWhite),
                    _tableCell('Status',       isHeader: true, textColor: pdfWhite),
                    _tableCell('Water (oz)',   isHeader: true, textColor: pdfWhite),
                    _tableCell('Status',       isHeader: true, textColor: pdfWhite),
                  ],
                ),
                // Data rows — no-data days already removed
                ...allRows.asMap().entries.map((entry) {
                  final i   = entry.key;
                  final row = entry.value;
                  final ox    = row['ox']    as double;
                  final wat   = row['wat']   as double;
                  final oxOk  = row['oxOk']  as bool?;
                  final watOk = row['watOk'] as bool;
                  final bg = i % 2 == 0 ? pdfWhite : pdfLight;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      _tableCell(row['date'] as String),
                      _tableCell(
                        ox == 0 ? '—' : '${ox.toStringAsFixed(0)} mg',
                        textColor: oxOk == null ? pdfGray : oxOk ? pdfGreen : pdfRed,
                      ),
                      _tableCell(
                        oxOk == null ? '—' : oxOk ? 'Under' : 'Over',
                        textColor: oxOk == null ? pdfGray : oxOk ? pdfGreen : pdfRed,
                      ),
                      _tableCell(
                        wat == 0 ? '—' : '${wat.toStringAsFixed(0)} oz',
                        textColor: watOk ? pdfGreen : pdfRed,
                      ),
                      _tableCell(
                        watOk ? 'Met' : 'Low',
                        textColor: watOk ? pdfGreen : pdfRed,
                      ),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 24),

          // ── Recommendations ───────────────────────────────────────────
          pw.Text('General Kidney Stone Prevention Reminders',
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: pdfTeal)),
          pw.SizedBox(height: 6),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _pdfBullet('Drink at least 2.5–3 liters of water per day (approximately 85–100 oz).', pdfGray),
              _pdfBullet('Limit dietary oxalate to under 200 mg per day unless otherwise directed.', pdfGray),
              _pdfBullet('Consume adequate dietary calcium (do not restrict calcium) to bind oxalate in the gut.', pdfGray),
              _pdfBullet('Limit sodium and animal protein, which can increase urinary calcium and oxalate.', pdfGray),
              _pdfBullet('Maintain a healthy body weight and avoid high-dose vitamin C supplements.', pdfGray),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'DISCLAIMER: This report is generated from patient self-reported data in the StoneGuard '
            'app. It is not a medical diagnosis and should be reviewed by a qualified healthcare '
            'provider. Always follow your physician\'s specific dietary recommendations.',
            style: pw.TextStyle(fontSize: 7, color: pdfGray,
                fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ── PDF helpers ──────────────────────────────────────────────────────────
  pw.Widget _pdfLabelValue(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('888888'))),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: color)),
      ],
    );
  }

  pw.Widget _pdfStatBox(
      String label, String value, PdfColor valueColor, PdfColor bg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
            color: bg, borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 7.5,
                    color: PdfColor.fromHex('888888'),
                    lineSpacing: 2)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: valueColor)),
          ],
        ),
      ),
    );
  }

  pw.Widget _tableCell(String text,
      {bool isHeader = false, PdfColor? textColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 8.5,
          fontWeight:
              isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  pw.Widget _pdfBullet(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('•  ',
              style: pw.TextStyle(
                  fontSize: 9, color: PdfColor.fromHex('1A8A9A'))),
          pw.Expanded(
            child: pw.Text(text,
                style: pw.TextStyle(
                    fontSize: 9, color: color, lineSpacing: 2)),
          ),
        ],
      ),
    );
  }

  // ── Share / Preview actions ────────────────────────────────────────────
  Future<void> _sharePdf() async {
    setState(() => _isGenerating = true);
    try {
      final bytes  = await _buildPdf();
      final dir    = await getTemporaryDirectory();
      final now    = DateTime.now();
      final fname  = 'stoneguard_report_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
      final file   = File('${dir.path}/$fname');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'StoneGuard Health Report — $_patientName',
        text: 'My StoneGuard kidney stone prevention report for doctor review.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not generate report: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _previewPdf() async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await _buildPdf();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Report Preview'),
              backgroundColor: accentTeal,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => _sharePdfBytes(bytes),
                  tooltip: 'Share PDF',
                ),
              ],
            ),
            body: PdfPreview(
              build: (_) async => bytes,
              canChangePageFormat: false,
              canDebug: false,
              pdfPreviewPageDecoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preview failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _sharePdfBytes(Uint8List bytes) async {
    final dir   = await getTemporaryDirectory();
    final now   = DateTime.now();
    final fname = 'stoneguard_report_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
    final file  = File('${dir.path}/$fname');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'StoneGuard Health Report — $_patientName',
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Export to Doctor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: accentTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accentTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  _sectionCard(
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: accentTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.picture_as_pdf_rounded,
                              color: accentTeal, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Doctor Report',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                'Generate a shareable PDF summary of your oxalate & hydration data.',
                                style: TextStyle(
                                    color: mutedColor.withValues(alpha: 0.9),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Report period selector — Wrap so all 5 chips fit on any screen
                  const Text('Report Period',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _periods.map((p) {
                      final days  = p['days']  as int;
                      final label = p['label'] as String;
                      return _periodChip(days, label);
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Preview of what will be in the report
                  const Text('Report Preview',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _sectionCard(
                    child: Column(
                      children: [
                        _previewRow(
                          Icons.person_outline,
                          'Patient',
                          _patientName,
                          accentTeal,
                        ),
                        _divider(),
                        _previewRow(
                          Icons.science_outlined,
                          'Stone Type',
                          'Calcium Oxalate',
                          accentTeal,
                        ),
                        _divider(),
                        _previewRow(
                          Icons.monitor_heart_outlined,
                          'Avg Oxalate',
                          '${_avgOxalate.toStringAsFixed(0)} mg/day',
                          _avgOxalate <= _oxalateGoal
                              ? accentGreen
                              : Colors.redAccent,
                        ),
                        _divider(),
                        _previewRow(
                          Icons.water_drop_outlined,
                          'Avg Water',
                          '${_avgWater.toStringAsFixed(0)} oz/day',
                          _avgWater >= _waterGoal
                              ? accentTeal
                              : Colors.orange,
                        ),
                        _divider(),
                        _previewRow(
                          Icons.check_circle_outline,
                          'Days Under Oxalate Goal',
                          '$_daysUnderGoal / $_selectedDays',
                          accentGreen,
                        ),
                        _divider(),
                        _previewRow(
                          Icons.local_drink_outlined,
                          'Days Met Water Goal',
                          '$_daysMetWater / $_selectedDays',
                          accentTeal,
                        ),
                        _divider(),
                        _previewRow(
                          Icons.local_fire_department_outlined,
                          'Current Streak',
                          '$_currentStreak days',
                          Colors.deepOrange,
                        ),
                        _divider(),
                        _previewRow(
                          Icons.calendar_today_outlined,
                          'Total Days Logged',
                          '$_totalDaysLogged days',
                          accentTeal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // What's included
                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('What\'s Included in the PDF',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const SizedBox(height: 10),
                        _includedItem('📄', 'Patient info & stone type'),
                        _includedItem('📊', 'Summary stats (averages, goals met)'),
                        _includedItem('📅', 'Daily log (logged days only, no blank rows)'),
                        _includedItem('💧', 'Hydration tracking per day'),
                        _includedItem('👨‍⚕️', 'Note for your physician'),
                        _includedItem('✅', 'Prevention reminders'),
                        _includedItem('⚠️', 'Medical disclaimer'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isGenerating ? null : _previewPdf,
                          icon: const Icon(Icons.visibility_outlined,
                              size: 18),
                          label: const Text('Preview'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentTeal,
                            side: const BorderSide(color: accentTeal),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _sharePdf,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2))
                              : const Icon(Icons.share_rounded, size: 18),
                          label: Text(
                              _isGenerating ? 'Generating…' : 'Share PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentTeal,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Tip: Share directly to email, WhatsApp, or save to Files',
                      style: TextStyle(
                          color: mutedColor.withValues(alpha: 0.8),
                          fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ── UI helpers ──────────────────────────────────────────────────────────
  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _periodChip(int days, String label) {
    final selected = _selectedDays == days;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedDays = days);
        _recalcStats();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? accentTeal : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentTeal : borderColor,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: accentTeal.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : mutedColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _previewRow(
      IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accentTeal.withValues(alpha: 0.7)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style:
                      const TextStyle(color: mutedColor, fontSize: 13))),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1,
      thickness: 1,
      color: borderColor.withValues(alpha: 0.5));

  Widget _includedItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(color: mutedColor, fontSize: 12)),
        ],
      ),
    );
  }
}
