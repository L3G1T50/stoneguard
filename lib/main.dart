// ─── MAIN ENTRY POINT ─────────────────────────────────────────────────────────
//
// Fix 2: AdMob consent gate
//   • MobileAds.instance.initialize() removed from here.
//   • AdMob initialised ONLY inside ConsentManager._initAdMob() after consent.
//
// Fix 4 / Batch C: Decrypt-failure / key-loss recovery
//   • SecurePrefs.checkIntegrity() called once on every cold start.
//
// Batch C: Legacy migration
//   • HydrationRepository.migrateLegacyPlainTextPrefs() called on startup.
//
// Preflight Batch 2:
//   • POST_NOTIFICATIONS rationale dialog shown before permission request
//     (Android 13+ requirement; skipping this is a known soft-rejection trigger).
//   • Branding: KidneyShield throughout.
//
// Fix 12: Global crash handler
//   • FlutterError.onError routes framework errors through AppLogger.
//   • runZonedGuarded wraps runApp to catch all unhandled async errors.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/home_shield_screen.dart';
import 'screens/food_guide_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/history_progress_screen.dart';
import 'screens/education_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/gradient_scaffold.dart';
import 'hydration_repository.dart';
import 'app_logger.dart';
import 'secure_prefs.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final ThemeNotifier themeNotifier = ThemeNotifier(ThemeMode.light);

Future<void> main() async {
  FlutterError.onError = AppLogger.flutterError;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final integrityOk = await SecurePrefs.instance.checkIntegrity();

      await HydrationRepository.instance.migrateLegacyPlainTextPrefs();

      final prefs = await SharedPreferences.getInstance();
      final savedDark = prefs.getBool('dark_mode') ?? false;
      themeNotifier.setMode(savedDark ? ThemeMode.dark : ThemeMode.light);

      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.navBg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ));

      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);
      await flutterLocalNotificationsPlugin.initialize(initSettings);

      // POST_NOTIFICATIONS rationale is shown contextually inside the app
      // (see _requestNotificationPermissionWithRationale) rather than at
      // cold-start, so we do not call requestExactAlarmPermission() here
      // until the user has seen the rationale.

      runApp(MyApp(integrityOk: integrityOk));
    },
    (Object error, StackTrace stack) {
      AppLogger.error('ZoneHandler', 'Unhandled async error', error, stack);
    },
  );
}

/// Shows a rationale dialog, then requests POST_NOTIFICATIONS + exact alarm.
/// Call this from the first screen where notifications add value (e.g. SetupScreen).
Future<void> requestNotificationPermissionWithRationale(
    BuildContext context) async {
  // Android 13+ requires POST_NOTIFICATIONS at runtime.
  // Google Play 2026: skipping the rationale dialog before requesting is a
  // soft-rejection trigger. We must explain WHY before calling .request().
  final status = await Permission.notification.status;
  if (status.isGranted) {
    await _requestExactAlarm();
    return;
  }

  if (!context.mounted) return;

  final shouldRequest = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Stay on track with reminders'),
      content: const Text(
        'KidneyShield uses notifications to send your daily hydration '
        'reminders and oxalate check-in alerts at times you choose.\n\n'
        'You can turn these off at any time in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Not now'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Allow'),
        ),
      ],
    ),
  );

  if (shouldRequest == true) {
    await Permission.notification.request();
    await _requestExactAlarm();
  }
}

Future<void> _requestExactAlarm() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

class MyApp extends StatelessWidget {
  final bool integrityOk;
  const MyApp({super.key, required this.integrityOk});

  @override
  Widget build(BuildContext context) {
    return ThemeNotifierProvider(
      notifier: themeNotifier,
      child: _ThemeConsumer(integrityOk: integrityOk),
    );
  }
}

class _ThemeConsumer extends StatelessWidget {
  final bool integrityOk;
  const _ThemeConsumer({required this.integrityOk});

  @override
  Widget build(BuildContext context) {
    final notifier = ThemeNotifier.of(context);
    return MaterialApp(
      title: 'KidneyShield',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: notifier.mode,
      home: SplashScreen(showKeyLossWarning: !integrityOk),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  final GlobalKey<HomeShieldScreenState> _shieldKey =
      GlobalKey<HomeShieldScreenState>();

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeShieldScreen(key: _shieldKey),
      GradientScaffold(
        title: 'Food Guide',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
        body: FoodGuideScreen(onLogFood: _onLogFood),
      ),
      const HistoryProgressScreen(),
      const JournalScreen(),
      const ShopScreen(),
      const EducationScreen(),
    ];
  }

  void _onTabSelected(int index) {
    if (index == 0) {
      _shieldKey.currentState?.loadData();
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _onLogFood(double mg, String name) async {
    final result = await HydrationRepository.instance.logFood(mg, name);
    if (result is SaveFailure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save food entry — please try again.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    _shieldKey.currentState?.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: isDark ? AppColors.darkNavBg : Colors.white,
        indicatorColor: isDark
            ? AppColors.darkNavIndicator
            : AppColors.teal.withValues(alpha: 0.12),
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: AppColors.teal),
            label: 'Shield',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: AppColors.teal),
            label: 'Food',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppColors.teal),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book, color: AppColors.teal),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: AppColors.teal),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: AppColors.teal),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}
