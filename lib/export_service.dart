// export_service.dart  (Fix 7 — Export path hardening)
//
// share_plus ^10.x API: Share.shareXFiles([XFile(...)]) — no SharePlus.instance.
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'app_logger.dart';

class ExportException implements Exception {
  final String message;
  const ExportException(this.message);
  @override
  String toString() => 'ExportException: $message';
}

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  Future<void> exportPdf({
    required pw.Document doc,
    required String filename,
  }) async {
    File? outputFile;
    try {
      final dir = await _resolveExportDirectory();
      outputFile = File('${dir.path}/$filename');

      final bytes = await doc.save();
      await outputFile.writeAsBytes(bytes, flush: true);

      final size = await outputFile.length();
      if (size == 0) {
        throw const ExportException(
            'PDF was written but is empty — generation may have failed.');
      }

      // share_plus ^10.x — use Share.shareXFiles directly.
      await Share.shareXFiles(
        [XFile(outputFile.path, mimeType: 'application/pdf')],
        text: 'My StoneGuard health report',
      );
    } catch (e, st) {
      if (e is ExportException) rethrow;
      AppLogger.error('ExportService', 'exportPdf failed', e, st);
      throw ExportException('Export failed: $e');
    } finally {
      try {
        if (outputFile != null && await outputFile.exists()) {
          await outputFile.delete();
        }
      } catch (e) {
        AppLogger.error('ExportService', 'cleanup failed', e);
      }
    }
  }

  Future<Directory> _resolveExportDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${dir.path}/stoneguard_exports');
      if (!await exportDir.exists()) await exportDir.create(recursive: true);
      return exportDir;
    } catch (e) {
      AppLogger.error('ExportService', 'documents dir failed, using temp', e);
    }
    try {
      return getTemporaryDirectory();
    } catch (e) {
      throw ExportException(
          'Could not resolve a writable directory for export: $e');
    }
  }
}
