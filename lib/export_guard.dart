// ─── EXPORT GUARD ─────────────────────────────────────────────────────────────
// Batch 4 — Fix 7: Export hardening
//
// Purpose:
//   All PDF / report exports in StoneGuard must:
//     1. Write to app-private storage only (getApplicationDocumentsDirectory).
//        This directory is NOT accessible to other apps or adb backup by
//        default, so PHI stays on-device until the user explicitly shares it.
//     2. Be shared exclusively through the OS share sheet (Share.shareXFiles)
//        so the user always controls the destination (email, Drive, print, etc.).
//     3. Be cleaned up after sharing so stale PHI does not accumulate on disk.
//
// Usage in export_report_screen.dart / doctor_view_screen.dart:
//
//   // 1. Generate your PDF bytes as before
//   final Uint8List pdfBytes = await buildReportPdf(...);
//
//   // 2. Save to private dir
//   final result = await ExportGuard.saveToPrivateDir(
//       bytes: pdfBytes, filename: 'stoneguard_report.pdf');
//
//   if (result is SaveFailure) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Could not save report — please try again.')));
//     return;
//   }
//
//   // 3. Share via OS sheet (user picks destination)
//   await ExportGuard.shareFile(
//       filePath: (result as SaveSuccess<String>).value,
//       shareText: 'My StoneGuard health report');
//
//   // 4. Clean up after share
//   await ExportGuard.clearExports();

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'app_logger.dart';
import 'hydration_repository.dart'; // re-uses SaveResult / SaveSuccess / SaveFailure

abstract final class ExportGuard {
  // Sub-folder name inside Documents so we can wipe exports without touching
  // other app documents.
  static const _exportSubdir = 'stoneguard_exports';

  // ── Save to private dir ────────────────────────────────────────────────
  /// Writes [bytes] to app-private Documents storage.
  /// Returns SaveSuccess<String>(absolutePath) on success.
  /// Returns SaveFailure<String>(reason) on any error.
  ///
  /// Security: getApplicationDocumentsDirectory() is:
  ///   • Android: internal app storage, not accessible to other apps.
  ///   • iOS: Documents folder, backed up by iCloud but not shared.
  ///   Never uses /sdcard, getCacheDir, or any world-readable path.
  static Future<SaveResult<String>> saveToPrivateDir({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${docsDir.path}/$_exportSubdir');
      if (!exportDir.existsSync()) {
        await exportDir.create(recursive: true);
      }

      // Sanitise filename: strip path separators so a crafted name can't
      // escape the export subdirectory.
      final safeName = filename
          .replaceAll('/', '_')
          .replaceAll('\\', '_')
          .replaceAll('..', '_');

      final file = File('${exportDir.path}/$safeName');
      await file.writeAsBytes(bytes, flush: true);

      AppLogger.debug('ExportGuard', 'Saved export to private dir: $safeName');
      return SaveSuccess(file.path);
    } catch (e, st) {
      AppLogger.error('ExportGuard', 'saveToPrivateDir failed', e, st);
      return SaveFailure(e.toString());
    }
  }

  // ── Share via OS sheet ─────────────────────────────────────────────────
  /// Opens the native OS share sheet for [filePath].
  /// The user explicitly chooses where the file goes (email, Drive, print,
  /// messaging, etc.) — StoneGuard never sends PHI anywhere automatically.
  ///
  /// [shareText] is the optional accompanying message.
  static Future<void> shareFile({
    required String filePath,
    String shareText = 'My StoneGuard health report',
    String mimeType = 'application/pdf',
  }) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath, mimeType: mimeType)],
        text: shareText,
      );
    } catch (e, st) {
      AppLogger.error('ExportGuard', 'shareFile failed', e, st);
      rethrow; // Let the caller surface this to the user.
    }
  }

  // ── Clean up stale exports ──────────────────────────────────────────────
  /// Deletes all previously exported files from the private export folder.
  /// Call this after a successful share so stale PHI does not accumulate.
  /// Safe to call even if the folder does not exist (no-op).
  static Future<void> clearExports() async {
    try {
      final docsDir   = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${docsDir.path}/$_exportSubdir');
      if (exportDir.existsSync()) {
        await exportDir.delete(recursive: true);
        AppLogger.debug('ExportGuard', 'Cleared stale exports.');
      }
    } catch (e, st) {
      AppLogger.error('ExportGuard', 'clearExports failed', e, st);
      // Non-fatal: leftover files are private, so this is not a security hole.
    }
  }

  // ── Convenience: save + share + clear in one call ─────────────────────
  /// Full flow: write bytes to private dir → open share sheet → wipe file.
  /// Returns SaveFailure if the write step fails (share sheet is not opened).
  static Future<SaveResult<void>> saveShareAndClear({
    required Uint8List bytes,
    required String filename,
    String shareText = 'My StoneGuard health report',
    String mimeType  = 'application/pdf',
  }) async {
    final writeResult = await saveToPrivateDir(bytes: bytes, filename: filename);
    if (writeResult is SaveFailure) {
      return SaveFailure((writeResult as SaveFailure).reason);
    }
    final path = (writeResult as SaveSuccess<String>).value;
    try {
      await shareFile(filePath: path, shareText: shareText, mimeType: mimeType);
    } finally {
      // Clean up regardless of whether share succeeded or was cancelled.
      await clearExports();
    }
    return const SaveSuccess(null);
  }
}
