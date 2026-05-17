// export_report_screen.dart
//
// Fix 7 — Export path hardening
//   • _sharePdf() and _sharePdfBytes() now route through ExportGuard.
//   • Files are written to app-private Documents/stoneguard_exports/ only.
//   • Filename is sanitised inside ExportGuard.saveToPrivateDir().
//   • The export file is deleted after the share sheet closes.
//   • _loadData() reads goals/name from SecurePrefs (not plain prefs).

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../export_guard.dart';
import '../hydration_repository.dart'; // SaveResult, SaveFailure
import '../history_storage.dart';
import '../secure_prefs.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  // ── Colours ───────────────────────────────────────────────────────────────
  static const Color accentTeal  = Color(0xFF1A8A9A);
  static const Color cardColor   = Color(0xFFFFFFFF);
  static const Color bgColor     = Color(0xFFF4F8FA);
  static const Color textDark    = Color(0xFF1A2530);
  static const Color textMuted   = Color(0xFF607D8B);
  static const Color successGreen= Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color dangerRed   = Color(0xFFD32F2F);

  // ── State ─────────────────────────────────────────────────────────────────
  bool   _isLoading     = true;
  bool   _isGenerating  = false;
  int    _selectedDays  = 30;

  String _userName      = '';
  double _oxalateGoal   = 200;
  double _waterGoal     = 80;

  Map<String, double> _dailyOxalate = {};
  Map<String, double> _dailyWater   = {};

  final List<int> _dayOptions = [7, 30, 90, 365, 730];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final secure = SecurePrefs.instance;
      final results = await Future.wait([
        secure.getString('user_name',    defaultValue: ''),
        secure.getDouble('goal_oxalate', defaultValue: 200.0),
        secure.getDouble('goal_water',   defaultValue: 80.0),
      ]);
      _userName    = results[0] as String;
      _oxalateGoal = results[1] as double;
      _waterGoal   = results[2] as double;

      final storage = HistoryStorage.instance;
      final now     = DateTime.now();

      final oxMap  = <String, double>{};
      final watMap = <String, double>{};

      for (int i = 0; i < _selectedDays; i++) {
        final day = now.subtract(Duration(days: i));
        final k   = _dateKey(day);
        final ox  = await storage.getDailyOxalate(day);
        final wat = await storage.getDailyWater(day);
        if (ox  != null) oxMap[k]  = ox;
        if (wat != null) watMap[k] = wat;
      }

      setState(() {
        _dailyOxalate = oxMap;
        _dailyWater   = watMap;
        _isLoading    = false;
      });
    } catch (e, st) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
      rethrow;
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  String get _rangeLabel {
    switch (_selectedDays) {
      case 7:   return 'Last 7 Days';
      case 30:  return 'Last 30 Days';
      case 90:  return 'Last 90 Days';
      case 365: return 'Last 1 Year';
      case 730: return 'Last 2 Years';
      default:  return 'Last $_selectedDays Days';
    }
  }

  // ── PDF Generation ────────────────────────────────────────────────────────────
  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();
    final now  = DateTime.now();

    final allRows = <Map<String, dynamic>>[];
    for (int i = _selectedDays - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final k   = _dateKey(day);
      final ox  = _dailyOxalate[k] ?? 0.0;
      final wat = _dailyWater[k]   ?? 0.0;
      if (ox == 0 && wat == 0) continue;
      allRows.add({
        'date':  '${day.month}/${day.day}/${day.year}',
        'ox':    ox,
        'wat':   wat,
        'oxOk':  ox == 0 ? null : ox <= _oxalateGoal,
        'watOk': wat == 0 ? null : wat >= _waterGoal,
      });
    }

    final double avgOx = allRows.isEmpty ? 0
        : allRows.map((r) => r['ox'] as double).reduce((a,b) => a+b) / allRows.length;
    final double avgWat = allRows.isEmpty ? 0
        : allRows.map((r) => r['wat'] as double).reduce((a,b) => a+b) / allRows.length;
    final int daysUnderOx = allRows.where((r) => r['oxOk'] == true).length;
    final int daysMetWat  = allRows.where((r) => r['watOk'] == true).length;

    pw.PdfColor teal(double opacity) =>
        PdfColor.fromInt(0xFF1A8A9A).flatten(PdfColor.fromInt(0xFFFFFFFF), 1 - opacity);
    const pw.PdfColor dark    = PdfColor.fromInt(0xFF1A2530);
    const pw.PdfColor muted   = PdfColor.fromInt(0xFF607D8B);
    const pw.PdfColor success = PdfColor.fromInt(0xFF2E7D32);
    const pw.PdfColor warning = PdfColor.fromInt(0xFFF57C00);
    const pw.PdfColor danger  = PdfColor.fromInt(0xFFD32F2F);
    const pw.PdfColor white   = PdfColor.fromInt(0xFFFFFFFF);
    const pw.PdfColor lightBg = PdfColor.fromInt(0xFFF4F8FA);

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
                pw.Text(
                  'StoneGuard Health Report',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF1A8A9A),
                  ),
                ),
                pw.Text(
                  '${now.month}/${now.day}/${now.year}',
                  style: pw.TextStyle(fontSize: 10, color: muted),
                ),
              ],
            ),
            if (_userName.isNotEmpty)
              pw.Text(
                'Prepared for: $_userName',
                style: pw.TextStyle(fontSize: 10, color: muted),
              ),
            pw.Text(
              _rangeLabel,
              style: pw.TextStyle(fontSize: 10, color: muted),
            ),
            pw.Divider(color: PdfColor.fromInt(0xFFDDE3E7)),
            pw.SizedBox(height: 4),
          ],
        ),
        build: (ctx) => [
          // ── Summary cards ──
          pw.Row(
            children: [
              _pdfSummaryCard('Avg Oxalate',
                  '${avgOx.toStringAsFixed(0)} mg/day',
                  avgOx <= _oxalateGoal ? success : danger,
                  lightBg),
              pw.SizedBox(width: 8),
              _pdfSummaryCard('Goal Met',
                  '$daysUnderOx / ${allRows.length} days',
                  daysUnderOx >= allRows.length * 0.8 ? success : warning,
                  lightBg),
              pw.SizedBox(width: 8),
              _pdfSummaryCard('Avg Water',
                  '${avgWat.toStringAsFixed(0)} oz/day',
                  avgWat >= _waterGoal ? success : danger,
                  lightBg),
              pw.SizedBox(width: 8),
              _pdfSummaryCard('Hydration Met',
                  '$daysMetWat / ${allRows.length} days',
                  daysMetWat >= allRows.length * 0.8 ? success : warning,
                  lightBg),
            ],
          ),
          pw.SizedBox(height: 16),

          if (allRows.isEmpty)
            pw.Center(
              child: pw.Text(
                'No data logged for this period.',
                style: pw.TextStyle(color: muted, fontSize: 11),
              ),
            )
          else ...[
            // ── Table header ──
            pw.Table(
              border: pw.TableBorder(
                bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFDDE3E7)),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF1A8A9A)),
                  children: [
                    _pdfHeaderCell('Date',    white),
                    _pdfHeaderCell('Oxalate', white),
                    _pdfHeaderCell('Status',  white),
                    _pdfHeaderCell('Water',   white),
                    _pdfHeaderCell('Status',  white),
                  ],
                ),
                ...allRows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final r = entry.value;
                  final rowBg = i.isEven
                      ? white
                      : PdfColor.fromInt(0xFFF4F8FA);
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowBg),
                    children: [
                      _pdfCell(r['date'] as String, dark),
                      _pdfCell('${(r['ox'] as double).toStringAsFixed(0)} mg', dark),
                      _pdfStatusCell(r['oxOk'] as bool?, 'Under', 'Over', success, danger),
                      _pdfCell('${(r['wat'] as double).toStringAsFixed(0)} oz', dark),
                      _pdfStatusCell(r['watOk'] as bool?, 'Met', 'Low', success, warning),
                    ],
                  );
                }),
              ],
            ),
          ],

          pw.SizedBox(height: 24),
          pw.Text(
            'Goals: Oxalate ≤ ${_oxalateGoal.toInt()} mg/day · Water ≥ ${_waterGoal.toInt()} oz/day',
            style: pw.TextStyle(fontSize: 9, color: muted),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'StoneGuard is a self-tracking tool, not a medical device. '
            'Always consult your healthcare provider for clinical guidance.',
            style: pw.TextStyle(
              fontSize: 8,
              color: muted,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfSummaryCard(
      String label, String value, pw.PdfColor valueColor, pw.PdfColor bg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 8,
                    color: const PdfColor.fromInt(0xFF607D8B))),
            pw.SizedBox(height: 2),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: valueColor)),
          ],
        ),
      ),
    );
  }

  pw.Widget _pdfHeaderCell(String text, pw.PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontSize: 9, fontWeight: pw.FontWeight.bold, color: color),
      ),
    );
  }

  pw.Widget _pdfCell(String text, pw.PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 9, color: color)),
    );
  }

  pw.Widget _pdfStatusCell(
      bool? ok,
      String goodLabel,
      String badLabel,
      pw.PdfColor goodColor,
      pw.PdfColor badColor) {
    if (ok == null) return pw.SizedBox();
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        ok ? goodLabel : badLabel,
        style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: ok ? goodColor : badColor),
      ),
    );
  }

  // ── Share flow ────────────────────────────────────────────────────────────
  Future<void> _sharePdf() async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await _buildPdf();
      if (!mounted) return;
      final now   = DateTime.now();
      final fname = 'stoneguard_report_'
          '${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}.pdf';
      await ExportGuard.saveShareAndClear(
        bytes: bytes,
        filename: fname,
        shareText: 'My StoneGuard health report.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  /// Share from the preview screen: same ExportGuard flow.
  Future<void> _sharePdfBytes(Uint8List bytes) async {
    final now   = DateTime.now();
    final fname = 'stoneguard_report_'
        '${now.year}${now.month.toString().padLeft(2,'0')}${now.day.toString().padLeft(2,'0')}.pdf';
    await ExportGuard.saveShareAndClear(
      bytes: bytes,
      filename: fname,
      shareText: 'My StoneGuard health report.',
    );
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share PDF',
                  onPressed: () => _sharePdfBytes(bytes),
                ),
              ],
            ),
            body: PdfPreview(
              build: (_) => bytes,
              allowSharing: false,
              allowPrinting: true,
              canChangePageFormat: false,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preview failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: textDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Export Report',
          style: TextStyle(
            color: Color(0xFF1A2530),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: accentTeal.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.description_outlined,
                                color: accentTeal, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Doctor Report',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _userName.isNotEmpty
                                      ? 'Prepared for $_userName'
                                      : 'Your hydration & oxalate summary',
                                  style: const TextStyle(
                                      fontSize: 12, color: textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Date range picker ──
                    const Text(
                      'Report Period',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _dayOptions.map((days) {
                        final selected = days == _selectedDays;
                        return GestureDetector(
                          onTap: () async {
                            setState(() => _selectedDays = days);
                            await _loadData();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? accentTeal
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? accentTeal
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: accentTeal.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              _rangeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : textMuted,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Action buttons ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _previewPdf,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.preview_outlined),
                        label: Text(
                            _isGenerating ? 'Generating…' : 'Preview Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _isGenerating ? null : _sharePdf,
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share / Save PDF'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentTeal,
                          side: const BorderSide(color: accentTeal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Disclaimer ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: warningOrange.withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: warningOrange, size: 18),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'This report is a self-tracking summary only — '
                              'not a clinical document. Share with your doctor '
                              'as a conversation aid, not a diagnosis.',
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF5D4037)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
