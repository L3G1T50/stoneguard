// ─── HOME SHIELD SCREEN ────────────────────────────────────
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/banner_ad_widget.dart';
import '../main.dart';
import '../history_storage.dart';
import 'settings_screen.dart';
import 'history_progress_screen.dart';

// ─── WAVE PAINTER ────────────────────────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  final double fillLevel;
  final double wavePhase;
  final Color waterColor;

  _WavePainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius - 1)));

    final waterTop = size.height * (1 - fillLevel);
    final amplitude = size.height * 0.028;

    final wavePath = Path()..moveTo(0, waterTop);
    for (double x = 0; x <= size.width; x++) {
      final y = waterTop +
          sin((x / size.width * 2 * pi) + wavePhase) * amplitude +
          sin((x / size.width * 3 * pi) + wavePhase * 1.3) * (amplitude * 0.5);
      wavePath.lineTo(x, y);
    }
    wavePath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final backWavePath = Path()..moveTo(0, waterTop + amplitude);
    for (double x = 0; x <= size.width; x++) {
      final y = waterTop +
          amplitude +
          sin((x / size.width * 2 * pi) + wavePhase + pi * 0.6) * amplitude;
      backWavePath.lineTo(x, y);
    }
    backWavePath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
        backWavePath, Paint()..color = waterColor.withValues(alpha: 0.25));

    canvas.drawPath(
      wavePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            waterColor.withValues(alpha: 0.55),
            waterColor.withValues(alpha: 0.85),
          ],
        ).createShader(
            Rect.fromLTWH(0, waterTop, size.width, size.height - waterTop)),
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.fillLevel != fillLevel ||
      old.wavePhase != wavePhase ||
      old.waterColor != waterColor;
}

// ─── RING PAINTER (glow arc) ──────────────────────────────────────────────────────
class _GlowRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool isGlow;

  _GlowRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.isGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = color.withValues(alpha: isGlow ? 0.08 : 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    if (isGlow) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 10
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0.01) {
      final angle = -pi / 2 + 2 * pi * progress;
      final tipX = center.dx + radius * cos(angle);
      final tipY = center.dy + radius * sin(angle);
      canvas.drawCircle(
        Offset(tipX, tipY),
        strokeWidth / 2 + 1,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_GlowRingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─── ALL BADGE DEFINITIONS (must match progress_screen.dart) ────────────────────────
const List<Map<String, dynamic>> _kAllBadges = [
  {'id': 'first_log',    'icon': '🥇', 'milestone': false},
  {'id': 'streak_3',     'icon': '🔥', 'milestone': false},
  {'id': 'hydration_hero','icon': '💧', 'milestone': false},
  {'id': 'stone_guardian','icon': '🛡️', 'milestone': false},
  {'id': 'champ_7',      'icon': '🏆', 'milestone': true},
  {'id': 'logger_14',    'icon': '📅', 'milestone': false},
  {'id': 'habit_21',     'icon': '🌟', 'milestone': false},
  {'id': 'warrior_30',   'icon': '🥈', 'milestone': true},
  {'id': 'streak_30',    'icon': '⚡', 'milestone': true},
  {'id': 'guardian_90',  'icon': '🎖️', 'milestone': true},
  {'id': 'defender_180', 'icon': '🥉', 'milestone': true},
  {'id': 'legend_365',   'icon': '👑', 'milestone': true},
  {'id': 'diamond_730',  'icon': '💎', 'milestone': true},
];

// ─── MAIN SCREEN ────────────────────────────────────────────────────────────────────────────────
class HomeShieldScreen extends StatefulWidget {
  const HomeShieldScreen({super.key});
  @override
  State<HomeShieldScreen> createState() => HomeShieldScreenState();
}

class HomeShieldScreenState extends State<HomeShieldScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  double waterOz = 0;
  double oxalateMg = 0;
  double goalOz = 80;
  double goalMg = 200;

  final HistoryStorage _historyStorage = HistoryStorage();

  Set<String> _celebratedBadges = {};
  int get _unlockedCount => _kAllBadges
      .where((b) => _celebratedBadges.contains(b['id']))
      .length;

  late AnimationController _fillController;
  late Animation<double> _fillAnimation;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _userName = '';
  String _avatarPath = '';

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }

  Future<void> _requestNotificationPermission() async {
    final plugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await plugin?.requestNotificationsPermission();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestNotificationPermission();

    _fillController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _fillAnimation = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(
            parent: _fillController, curve: Curves.easeInOutCubic));

    _waveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fillController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> _saveTodayToHistory() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final existing = await _historyStorage.loadHistory();
    final filtered = existing.where((e) => e['date'] != dateStr).toList();
    filtered.add({
      'date': dateStr,
      'water_oz': waterOz,
      'oxalate_mg': oxalateMg,
    });
    if (filtered.length > 730) filtered.removeAt(0);
    await _historyStorage.saveHistory(filtered);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWater = prefs.getDouble('water_$_todayKey') ?? 0;
    final savedOxalate = prefs.getDouble('oxalate_$_todayKey') ?? 0;
    final savedGoalOz = prefs.getDouble('goal_water') ?? 80;
    final savedGoalMg = prefs.getDouble('goal_oxalate') ?? 200;
    final celebratedList = prefs.getStringList('celebrated_badges') ?? [];

    if (!mounted) return;
    setState(() {
      waterOz = savedWater;
      oxalateMg = savedOxalate;
      goalOz = savedGoalOz;
      goalMg = savedGoalMg;
      _userName = prefs.getString('user_name') ?? '';
      _avatarPath = prefs.getString('avatar_path') ?? '';
      _celebratedBadges = celebratedList.toSet();
      final visualFill = (savedWater / savedGoalOz).clamp(0.0, 1.0);
      _fillAnimation =
          Tween<double>(begin: visualFill, end: visualFill)
              .animate(CurvedAnimation(
                  parent: _fillController, curve: Curves.easeInOutCubic));
    });
  }

  Future<void> _addWater(double oz) async {
    final prefs = await SharedPreferences.getInstance();
    final newOz = (waterOz + oz).clamp(0.0, double.infinity);
    final currentAnimProg = _fillAnimation.value;
    final newVisualFill = (newOz / goalOz).clamp(0.0, 1.0);
    _fillAnimation =
        Tween<double>(begin: currentAnimProg, end: newVisualFill).animate(
            CurvedAnimation(
                parent: _fillController, curve: Curves.easeInOutCubic));
    _fillController.forward(from: 0);
    setState(() { waterOz = newOz; });
    await prefs.setDouble('water_$_todayKey', newOz);
    await _saveTodayToHistory();
    if (newOz >= goalOz) {
      _pulseController.forward(from: 0).then((_) => _pulseController.reverse());
    }
  }

  Future<void> _resetAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Today?'),
        content: const Text(
            'This will clear all water and oxalate data for today. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    final currentAnimProg = _fillAnimation.value;
    _fillAnimation =
        Tween<double>(begin: currentAnimProg, end: 0).animate(CurvedAnimation(
            parent: _fillController, curve: Curves.easeInOutCubic));
    _fillController.forward(from: 0);
    setState(() {
      waterOz = 0;
      oxalateMg = 0;
    });
    await prefs.setDouble('water_$_todayKey', 0);
    await prefs.setDouble('oxalate_$_todayKey', 0);
    await prefs.setStringList('oxalate_log_$_todayKey', []);
    await _saveTodayToHistory();
  }

  // ... rest of file unchanged ...
