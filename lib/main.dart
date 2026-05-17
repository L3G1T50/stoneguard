// main.dart
//
// Fix 4 — Decrypt-failure / key-loss recovery:
//   checkIntegrity() is called before runApp(). If it returns false the
//   user's AES key was wiped (device restore, app reinstall while data
//   remained, or OS-level keystore wipe). MyApp shows a one-time dialog
//   so the user understands why their data was reset.
//
// Fix 12 — Global crash handler:
//   FlutterError.onError and PlatformDispatcher.instance.onError both
//   route to AppLogger.fatal() so unhandled exceptions are captured in
//   release builds (Firebase Crashlytics hook point).
import 'package:flutter/material.dart';
import '../app_logger.dart';
import '../secure_prefs.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_shield_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/history_screen.dart';
import 'screens/doctor_view_screen.dart';
import 'screens/export_report_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/setup_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fix 12 — Global Flutter error handler
  FlutterError.onError = (details) {
    AppLogger.fatal('FlutterError', details.exceptionAsString(),
        details.exception, details.stack);
  };
  // Fix 12 — Catch async errors outside widget tree
  // ignore: deprecated_member_use
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    AppLogger.fatal('PlatformDispatcher', error.toString(), error, stack);
    return true;
  };

  // Fix 4 — Key-loss integrity check
  final integrityOk = await SecurePrefs.instance.checkIntegrity();

  runApp(MyApp(integrityOk: integrityOk));
}

class MyApp extends StatefulWidget {
  final bool integrityOk;
  const MyApp({super.key, required this.integrityOk});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (!widget.integrityOk) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showKeyLossDialog());
    }
  }

  void _showKeyLossDialog() {
    showDialog<void>(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Data Reset'),
        content: const Text(
          'Your secure storage key was reset (this can happen after '
          'an app reinstall or device restore).\n\n'
          'Your logs have been cleared. You can re-enter recent data '
          'from the History screen if you have a backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(navigatorKey.currentContext!),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoneGuard',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A8A9A),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
      initialRoute: '/',
      routes: {
        '/':           (_) => SplashScreen(integrityOk: widget.integrityOk),
        '/onboarding': (_) => const OnboardingScreen(),
        '/setup':      (_) => const SetupScreen(),
        '/home':       (_) => const HomeShieldScreen(),
        '/progress':   (_) => const ProgressScreen(),
        '/history':    (_) => const HistoryScreen(),
        '/doctor':     (_) => const DoctorViewScreen(),
        '/export':     (_) => const ExportReportScreen(),
        '/settings':   (_) => const SettingsScreen(),
        '/about':      (_) => const AboutScreen(),
        '/privacy':    (_) => const PrivacyPolicyScreen(),
      },
    );
  }
}
