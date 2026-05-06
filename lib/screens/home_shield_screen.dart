// ─── HOME SHIELD SCREEN ──────────────────────────────────────────────
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/banner_ad_widget.dart';
import '../main.dart';
import 'settings_screen.dart';
import 'history_progress_screen.dart';

// ─── WAVE PAINTER ────────────────────────────────────────────────────
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

// ─── RING PAINTER (glow arc) ─────────────────────────────────────────
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

// ─── ALL BADGE DEFINITIONS (must match progress_screen.dart) ─────────
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

// ─── MAIN SCREEN ─────────────────────────────────────────────────────
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

  // Achievement card data
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
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final entry = jsonEncode({
      'date': dateStr,
      'water_oz': waterOz,
      'oxalate_mg': oxalateMg,
    });
    final raw = prefs.getStringList('daily_history') ?? [];
    final updated = raw.where((e) {
      final map = Map<String, dynamic>.from(jsonDecode(e));
      return map['date'] != dateStr;
    }).toList();
    updated.add(entry);
    if (updated.length > 730) updated.removeAt(0);
    await prefs.setStringList('daily_history', updated);
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
      _fillAnimation =
          Tween<double>(begin: savedWater / goalOz, end: savedWater / goalOz)
              .animate(CurvedAnimation(
                  parent: _fillController, curve: Curves.easeInOutCubic));
    });
  }

  Future<void> _addWater(double oz) async {
    final prefs = await SharedPreferences.getInstance();
    final newOz = (waterOz + oz).clamp(0.0, goalOz);

    final currentAnimProg = _fillAnimation.value;

    _fillAnimation =
        Tween<double>(begin: currentAnimProg, end: newOz / goalOz).animate(
            CurvedAnimation(
                parent: _fillController, curve: Curves.easeInOutCubic));
    _fillController.forward(from: 0);

    setState(() {
      waterOz = newOz;
    });
    await prefs.setDouble('water_$_todayKey', newOz);
    await _saveTodayToHistory();

    if (newOz >= goalOz) {
      _pulseController.forward(from: 0).then((_) => _pulseController.reverse());
    }
  }

  Future<void> _resetAll() async {
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

  Color _lerpShieldColor(double p) {
    const stops = [
      (t: 0.00, c: Color(0xFF78909C)),
      (t: 0.25, c: Color(0xFFFFA726)),
      (t: 0.50, c: Color(0xFFFFEE58)),
      (t: 0.75, c: Color(0xFF66BB6A)),
      (t: 1.00, c: Color(0xFF00BCD4)),
    ];
    for (int i = 0; i < stops.length - 1; i++) {
      if (p <= stops[i + 1].t) {
        final t = (p - stops[i].t) / (stops[i + 1].t - stops[i].t);
        return Color.lerp(stops[i].c, stops[i + 1].c, t)!;
      }
    }
    return stops.last.c;
  }

  Color _oxalateColor(double mg) {
    if (mg >= goalMg) return const Color(0xFFE53935);
    if (mg >= goalMg * 0.75) return const Color(0xFFFFA726);
    if (mg >= goalMg * 0.50) return const Color(0xFFFFEE58);
    return const Color(0xFF66BB6A);
  }

  String _oxalateStatus(double mg) {
    if (mg >= goalMg) return '⛔ Daily limit reached — no more high-oxalate foods!';
    if (mg >= goalMg * 0.75) return '⚠️ Getting close to your limit — be careful!';
    if (mg >= goalMg * 0.50) return '🟡 Moderate intake — watch your next meal';
    return '✅ Great job — staying well within your limit!';
  }

  String _motivationalText(double progress) {
    if (progress >= 1.0) return '🎉 Daily goal reached! Stones don\'t stand a chance!';
    if (progress >= 0.75) return '💪 Almost there — keep it up!';
    if (progress >= 0.50) return '👍 Halfway there, great progress!';
    if (progress >= 0.25) return '💧 Good start — keep drinking!';
    return '🛡️ Start hydrating to build your shield!';
  }

  Widget _waterButton(int oz) {
    return ElevatedButton(
      onPressed: () => _addWater(oz.toDouble()),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text('+$oz oz',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildWaterMeter() {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_fillAnimation, _waveController, _pulseAnimation]),
      builder: (context, _) {
        final fillProg = _fillAnimation.value.clamp(0.0, 1.0);
        final ringColor = _lerpShieldColor(fillProg);
        final wavePhase = _waveController.value * 2 * pi;
        final displayOz =
            (_fillAnimation.value * goalOz).clamp(0.0, goalOz);

        return ScaleTransition(
          scale: _pulseAnimation,
          child: SizedBox(
            height: 230,
            width: 230,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                height: 230,
                width: 230,
                child: CustomPaint(
                  painter: _GlowRingPainter(
                    progress: fillProg,
                    color: ringColor,
                    strokeWidth: 18,
                    isGlow: true,
                  ),
                ),
              ),
              SizedBox(
                height: 230,
                width: 230,
                child: CustomPaint(
                  painter: _GlowRingPainter(
                    progress: fillProg,
                    color: ringColor,
                    strokeWidth: 14,
                  ),
                ),
              ),
              ClipOval(
                child: Container(
                  height: 170,
                  width: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF0F4F8),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _WavePainter(
                      fillLevel: fillProg,
                      wavePhase: wavePhase,
                      waterColor: ringColor,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => LinearGradient(
                              colors: [
                                ringColor,
                                ringColor.withValues(alpha: 0.7)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(b),
                            child: const Icon(Icons.water_drop,
                                size: 28, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayOz.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: fillProg > 0.45
                                  ? Colors.white
                                  : const Color(0xFF2E3A45),
                              shadows: fillProg > 0.45
                                  ? [
                                      const Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4)
                                    ]
                                  : null,
                            ),
                          ),
                          Text(
                            'of ${goalOz.toInt()} oz',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: fillProg > 0.45
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ─── ACHIEVEMENTS TROPHY CARD ───────────────────────────────────────
  Widget _buildAchievementsCard() {
    final total      = _kAllBadges.length;
    final unlocked   = _unlockedCount;
    final progress   = total > 0 ? unlocked / total : 0.0;
    final pct        = (progress * 100).round();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistoryProgressScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFD4A020).withValues(alpha: 0.10),
              const Color(0xFF01696F).withValues(alpha: 0.06),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFD4A020).withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A020).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A020).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🏅', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      Text(
                        '$unlocked of $total unlocked · $pct%',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF888888)),
                      ),
                    ],
                  ),
                ]),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF888888), size: 20),
              ],
            ),

            const SizedBox(height: 12),

            // ── Progress bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD4A020)),
              ),
            ),

            const SizedBox(height: 14),

            // ── Badge icon strip ──
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _kAllBadges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final badge      = _kAllBadges[i];
                  final isUnlocked = _celebratedBadges.contains(badge['id']);
                  final isMilestone = badge['milestone'] as bool;

                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isUnlocked
                          ? (isMilestone
                              ? const Color(0xFFD4A020).withValues(alpha: 0.15)
                              : const Color(0xFF2A9A5A).withValues(alpha: 0.12))
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: isUnlocked
                            ? (isMilestone
                                ? const Color(0xFFD4A020).withValues(alpha: 0.5)
                                : const Color(0xFF2A9A5A).withValues(alpha: 0.4))
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isUnlocked
                          ? Text(badge['icon'] as String,
                              style: const TextStyle(fontSize: 20))
                          : Icon(Icons.lock_outline,
                              size: 16,
                              color: Colors.grey.shade400),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 6),
            const Text(
              'Tap to view all achievements →',
              style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double waterProgress = (waterOz / goalOz).clamp(0.0, 1.0);
    final double remaining = (goalOz - waterOz).clamp(0.0, goalOz);
    final Color oxColor = _oxalateColor(oxalateMg);
    final double oxProgress = (oxalateMg / goalMg).clamp(0.0, 1.0);

    final Widget scrollContent = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(children: [

          // ── HEADER ROW ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  backgroundImage: _avatarPath.isNotEmpty
                      ? FileImage(File(_avatarPath))
                      : null,
                  child: _avatarPath.isEmpty
                      ? const Icon(Icons.person,
                          color: Colors.white, size: 22)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName.isEmpty
                          ? 'Today\'s Shield'
                          : 'Hey, $_userName! 👋',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text('Stay hydrated. Stay protected.',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.75))),
                  ],
                ),
              ]),
              IconButton(
                icon: Icon(Icons.settings_outlined,
                    color: Colors.white.withValues(alpha: 0.85)),
                tooltip: 'Settings',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── WATER METER ──
          _buildWaterMeter(),

          const SizedBox(height: 16),

          // ── MOTIVATIONAL TEXT ──
          Text(_motivationalText(waterProgress),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),

          if (waterOz < goalOz) ...[
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${remaining.toStringAsFixed(0)} oz remaining',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── OXALATE STAT CARD ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  oxColor.withValues(alpha: 0.08),
                  oxColor.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(
                  color: oxColor.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: oxColor.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: oxColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.science_outlined,
                            color: oxColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text('Daily Oxalate',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800)),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: oxColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: oxalateMg.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: oxColor)),
                        TextSpan(
                            text: ' / ${goalMg.toInt()} mg',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                      ])),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: oxProgress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(oxColor),
                  ),
                ),
                const SizedBox(height: 12),
                Text(_oxalateStatus(oxalateMg),
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── ACHIEVEMENTS TROPHY CARD ──
          _buildAchievementsCard(),

          const SizedBox(height: 24),

          // ── WATER BUTTONS ──
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Log Water Intake',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _waterButton(8)),
            const SizedBox(width: 10),
            Expanded(child: _waterButton(12)),
            const SizedBox(width: 10),
            Expanded(child: _waterButton(16)),
          ]),

          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _resetAll,
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            label: const Text('Reset Today',
                style: TextStyle(color: Colors.redAccent)),
          ),
          const SizedBox(height: 16),
          const BannerAdWidget(),
          const SizedBox(height: 8),
        ]),
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0, 0.55),
            colors: [
              Color(0xFF01696F),
              Color(0xFF2A9DA5),
              Color(0xFFE0F4F5),
              Colors.white,
            ],
            stops: [0.0, 0.18, 0.42, 0.62],
          ),
        ),
        child: scrollContent,
      ),
    );
  }
}
