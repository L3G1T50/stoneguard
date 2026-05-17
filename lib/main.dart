// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_logger.dart';
import 'secure_prefs.dart';
import 'services/revenue_cat_service.dart';
import 'services/subscription_notifier.dart';
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

/// Global notifications plugin instance.
/// Declared here so home_shield_screen.dart (and any other screen)
/// can import it from main.dart without creating duplicate instances.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// App-wide subscription notifier — initialised in main() before runApp().
/// Any widget can read it via: SubscriptionNotifier.of(context)
final SubscriptionNotifier subscriptionNotifier = SubscriptionNotifier();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error handler
  FlutterError.onError = AppLogger.flutterError;

  // Catch async errors outside the widget tree
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    AppLogger.error('PlatformDispatcher', error.toString(), error, stack);
    return true;
  };

  // Initialise local notifications (Android settings; iOS handled by plugin)
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Key-loss integrity check
  final integrityOk = await SecurePrefs.instance.checkIntegrity();

  // ── RevenueCat initialisation ────────────────────────────────────────────
  // Initialise the SDK before runApp so subscription status is ready
  // as early as possible. Anonymous user ID used (no auth layer yet).
  await RevenueCatService().initialise();

  // Fire the first subscriber-status fetch in the background.
  // The notifier starts with isLoading = true; widgets show a loader until
  // this completes and notifyListeners() fires.
  unawaited(subscriptionNotifier.init());
  // ─────────────────────────────────────────────────────────────────────────

  runApp(MyApp(integrityOk: integrityOk));
}

// Suppress "unawaited future" lint for intentional fire-and-forget calls.
void unawaited(Future<void> future) {}

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
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showKeyLossDialog());
    }
  }

  void _showKeyLossDialog() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    showDialog<void>(
      context: ctx,
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
    // ── SubscriptionProvider wraps the entire app ────────────────────────
    // This makes `SubscriptionNotifier.of(context)` available to every
    // widget in the tree — screens, dialogs, bottom sheets, everything.
    return SubscriptionProvider(
      notifier: subscriptionNotifier,
      child: MaterialApp(
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
      ),
    );
  }
}
