// ─── MAIN ENTRY POINT ─────────────────────────────────────────────────────────
//
// Fix 2: AdMob consent gate
//   • MobileAds.instance.initialize() has been REMOVED from here.
//   • AdMob is now ONLY initialised inside ConsentManager._initAdMob(),
//     which is called only if the user taps "Accept Ads" in the consent dialog.
//   • This ensures no ad SDK tracking begins before explicit user consent,
//     satisfying GDPR / Play Store data-safety requirements.
//
// Fix 4 / Batch C: Decrypt-failure / key-loss recovery
//   • SecurePrefs.checkIntegrity() is called once on every cold start.
//   • The result is passed to SplashScreen(showKeyLossWarning: !integrityOk)
//     so the dialog is shown from a live BuildContext.
//
// Batch C: Legacy migration
//   • HydrationRepository.migrateLegacyPlainTextPrefs() is called on startup
//     so users upgrading from plain-text builds don’t silently lose data.
//
// Fix 8 branding patch:
//   • MaterialApp title corrected from 'KidneyShield' → 'StoneGuard'.
//
// Fix 12: Global crash handler (retained)
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

// Global ThemeNotifier — created once in main, accessed via ThemeNotifier.of(context)
final ThemeNotifier themeNotifier = ThemeNotifier(ThemeMode.light);

Future<void> main() async {
  // ── Fix 12: Route Flutter framework errors through AppLogger ────────────
  FlutterError.onError = AppLogger.flutterError;

  // ── Fix 12: Catch all unhandled async/zone errors ───────────────────
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ── Fix 4 / Batch C: Check encryption key integrity ─────────────────
      final integrityOk = await SecurePrefs.instance.checkIntegrity();

      // ── Batch C: Migrate legacy plain-text prefs ──────────────────────
      await HydrationRepository.instance.migrateLegacyPlainTextPrefs();

      // Load saved theme preference
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
      await requestExactAlarmPermission();

      runApp(MyApp(integrityOk: integrityOk));
    },
    (Object error, StackTrace stack) {
      AppLogger.error('ZoneHandler', 'Unhandled async error', error, stack);
    },
  );
}

Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

// ─── MyApp ─────────────────────────────────────────────────────────────
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
      title: 'StoneGuard',         // Fix 8 branding: was 'KidneyShield'
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: notifier.mode,
      home: SplashScreen(showKeyLossWarning: !integrityOk),
    );
  }
}

// ─── MAIN SHELL ─────────────────────────────────────────────────────────────
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

  // Fix 5: surface save failures to the user
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
