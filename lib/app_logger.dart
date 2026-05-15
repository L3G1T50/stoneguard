// ─── APP LOGGER ───────────────────────────────────────────────────────────────
// Centralised logging utility for StoneGuard.
//
// Rules:
//   1. NEVER log PHI (journal text, food names in errors, personal details).
//   2. Verbose output (debug + stack traces) only appears in DEBUG builds.
//   3. In release builds every call is a no-op, so no internal details leak.
//
// Usage:
//   AppLogger.debug('HydrationRepository', 'addWater called with oz=$oz');
//   AppLogger.error('HistoryStorage', 'decrypt failed', e, st);

import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  // ── Debug ──────────────────────────────────────────────────────────────────
  /// Low-level trace messages. Compiled away in release.
  static void debug(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  // ── Error ──────────────────────────────────────────────────────────────────
  /// Non-fatal errors. In debug, prints tag + message + error + stack trace.
  /// In release, completely silent (no-op) so nothing leaks to logcat.
  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      final buf = StringBuffer('[$tag] ERROR: $message');
      if (error != null) buf.write('\n  error : $error');
      if (stackTrace != null) buf.write('\n  stack : $stackTrace');
      debugPrint(buf.toString());
    }
    // TODO(release): wire to a privacy-respecting crash reporter here,
    // e.g. Firebase Crashlytics with PHI scrubbing, once one is chosen.
  }

  // ── Framework errors (used by FlutterError.onError) ────────────────────────
  /// Routes Flutter framework errors through the same pipeline.
  static void flutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
    // In release: silent — keeps internal structure out of production logs.
  }
}
