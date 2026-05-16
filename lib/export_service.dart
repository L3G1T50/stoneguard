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
import 'package:printing/printing.dart';
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

      // Validate: a zero-byte file means pdf.save() silently failed.
      final length = await outputFile.length();
      if (length == 0) {
        throw const ExportException(
            'PDF was written as empty — report generation failed.');
      }

      await Share.shareXFiles(
        [XFile(outputFile.path, mimeType: 'application/pdf')],
        subject: 'KidneyShield Report',
      );
    } catch (e, st) {
      AppLogger.error('ExportService', 'exportPdf failed', e, st);
      if (e is ExportException) rethrow;
      throw ExportException(e.toString());
    } finally {
      // Always clean up the temp file, even if share failed.
      if (outputFile != null) {
        try {
          if (await outputFile.exists()) await outputFile.delete();
        } catch (_) {
          // Non-fatal: temp file will be cleaned up by the OS eventually.
        }
      }
    }
  }

  /// Returns a writable directory that does not require any runtime
  /// permission on any Android API level.
  Future<Directory> _resolveExportDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      AppLogger.warn(
          'ExportService', 'getApplicationDocumentsDirectory failed: $e');
    }
    try {
      return await getTemporaryDirectory();
    } catch (e) {
      AppLogger.warn('ExportService', 'getTemporaryDirectory failed: $e');
    }
    throw const ExportException(
        'No writable directory available for export.');
  }
}
