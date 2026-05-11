// ─── MAIN ENTRY POINT ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Global ThemeNotifier — created once in main, accessed via ThemeNotifier.of(context)
final ThemeNotifier themeNotifier = ThemeNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  MobileAds.instance.initialize();
  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  await requestExactAlarmPermission();

  runApp(const MyApp());
}

Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ThemeNotifierProvider(
      notifier: themeNotifier,
      child: MaterialApp(
        title: 'StoneGuard',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: themeNotifier.mode,
        home: const SplashScreen(),
      ),
    );
  }
}

// ─── MAIN SHELL ───────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final GlobalKey<HomeShieldScreenState> _shieldKey =
      GlobalKey<HomeShieldScreenState>();

  void _onTabSelected(int index) {
    if (index == 0) {
      _shieldKey.currentState?.loadData();
    }
    setState(() => _currentIndex = index);
  }

  void _onLogFood(double mg, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final logKey = 'oxalate_log_${now.year}_${now.month}_${now.day}';
    final oxKey  = 'oxalate_${now.year}_${now.month}_${now.day}';

    final log = List<String>.from(prefs.getStringList(logKey) ?? []);
    log.add('$name|$mg');
    await prefs.setStringList(logKey, log);

    final current = prefs.getDouble(oxKey) ?? 0.0;
    await prefs.setDouble(oxKey, current + mg);

    // Shield refreshes via its own loadData(); no need to rebuild MainShell.
    _shieldKey.currentState?.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: isDark ? AppColors.darkNavBg : Colors.white,
        indicatorColor: isDark
            ? AppColors.darkNavIndicator
            : const Color(0xFF01696F).withValues(alpha: 0.12),
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: Color(0xFF01696F)),
            label: 'Shield',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: Color(0xFF01696F)),
            label: 'Food',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF01696F)),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book, color: Color(0xFF01696F)),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag, color: Color(0xFF01696F)),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: Color(0xFF01696F)),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}
