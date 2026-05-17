// ─── EXPORT SERVICE ──────────────────────────────────────────────────────────
//
// Fix 7 — Export path hardening:
//
//   Problem: getExternalStorageDirectory() returns null on Android 11+ when
//   the app lacks MANAGE_EXTERNAL_STORAGE, causing a silent null-dereference
//   crash when the user taps Export.
//
//   Solution:
//     1. Use getApplicationDocumentsDirectory() as the primary path — always
//        available, no permission required on any API level.
//     2. Fall back to getTemporaryDirectory() if documents dir also fails.
//     3. Throw an explicit ExportException if both fail so the caller can
//        show a meaningful error message instead of crashing.
//     4. Validate that the written file is non-empty before calling share.
//        A zero-byte file means the PDF write silently failed; sharing it
//        produces a confusing empty attachment.
//     5. Clean up the temp file after share_plus has handled it.
//
//   No MANAGE_EXTERNAL_STORAGE permission is needed or requested.
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

  /// Builds a PDF from [doc], saves it to the app documents directory,
  /// verifies it is non-empty, shares it via share_plus, then deletes
  /// the temp file.
  ///
  /// Throws [ExportException] on any unrecoverable error.
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

      // Validate non-empty before sharing.
      final size = await outputFile.length();
      if (size == 0) {
        throw const ExportException(
            'PDF was written but is empty — generation may have failed.');
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(outputFile.path, mimeType: 'application/pdf')],
          text: 'My StoneGuard health report',
        ),
      );
    } catch (e, st) {
      if (e is ExportException) rethrow;
      AppLogger.error('ExportService', 'exportPdf failed', e, st);
      throw ExportException('Export failed: $e');
    } finally {
      // Best-effort cleanup — ignore errors if file is still open.
      try {
        if (outputFile != null && await outputFile.exists()) {
          await outputFile.delete();
        }
      } catch (e) {
        AppLogger.error('ExportService', 'cleanup failed', e);
      }
    }
  }

  /// Resolves a writable directory for the export file.
  /// Primary: getApplicationDocumentsDirectory() — no permission needed.
  /// Fallback: getTemporaryDirectory().
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
