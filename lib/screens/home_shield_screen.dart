// ─── HOME SHIELD SCREEN ────────────────────────────────────
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/banner_ad_widget.dart';
import '../main.dart';
import '../hydration_repository.dart';
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

  // All hydration/oxalate persistence goes through the repository.
  final _repo = HydrationRepository.instance;

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

  // didChangeDependencies intentionally removed — loadData is already called
  // in initState and didChangeAppLifecycleState(resumed). Overriding
  // didChangeDependencies here caused extra SharedPreferences reads and
  // unnecessary setState calls on every theme / media-query change.

  Future<void> loadData() async {
    // Read hydration totals via the repository (single source of truth).
    final snapshot = await _repo.readToday();

    // Read non-hydration prefs (name, avatar, badges) directly — these
    // are not managed by HydrationRepository.
    final prefs = await SharedPreferences.getInstance();
    final celebratedList = prefs.getStringList('celebrated_badges') ?? [];

    if (!mounted) return;
    setState(() {
      waterOz   = snapshot.waterOz;
      oxalateMg = snapshot.oxalateMg;
      goalOz    = snapshot.goalOz;
      goalMg    = snapshot.goalMg;
      _userName    = prefs.getString('user_name')    ?? '';
      _avatarPath  = prefs.getString('avatar_path')  ?? '';
      _celebratedBadges = celebratedList.toSet();
      final visualFill = (snapshot.waterOz / snapshot.goalOz).clamp(0.0, 1.0);
      _fillAnimation =
          Tween<double>(begin: visualFill, end: visualFill)
              .animate(CurvedAnimation(
                  parent: _fillController, curve: Curves.easeInOutCubic));
    });
  }

  Future<void> _addWater(double oz) async {
    // Delegate the write to the repository; it handles prefs + history.
    final newOz = await _repo.addWater(oz);
    if (newOz < 0) return; // repository logged the error

    final currentAnimProg = _fillAnimation.value;
    final newVisualFill = (newOz / goalOz).clamp(0.0, 1.0);
    _fillAnimation =
        Tween<double>(begin: currentAnimProg, end: newVisualFill).animate(
            CurvedAnimation(
                parent: _fillController, curve: Curves.easeInOutCubic));
    _fillController.forward(from: 0);
    setState(() { waterOz = newOz; });
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

    // Delegate the reset to the repository.
    await _repo.resetToday();

    final currentAnimProg = _fillAnimation.value;
    _fillAnimation =
        Tween<double>(begin: currentAnimProg, end: 0).animate(CurvedAnimation(
            parent: _fillController, curve: Curves.easeInOutCubic));
    _fillController.forward(from: 0);
    setState(() {
      waterOz   = 0;
      oxalateMg = 0;
    });
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

  String _motivationalText(double oz) {
    if (oz >= goalOz * 1.25) return '🌊 Super-hydrated! You\'re crushing it today!';
    if (oz >= goalOz) return '🎉 Daily goal reached! Keep going — more is great!';
    if (oz >= goalOz * 0.75) return '💪 Almost there — keep it up!';
    if (oz >= goalOz * 0.50) return '👍 Halfway there, great progress!';
    if (oz >= goalOz * 0.25) return '💧 Good start — keep drinking!';
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
        final displayOz = waterOz;
        final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: SizedBox(
                  height: 190,
                  width: 190,
                  child: CustomPaint(
                    painter: _WavePainter(
                      fillLevel: fillProg,
                      wavePhase: wavePhase,
                      waterColor: ringColor,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${displayOz.toStringAsFixed(displayOz == displayOz.roundToDouble() ? 0 : 1)} oz',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'of ${goalOz.toInt()} oz',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(fillProg * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ringColor,
                    ),
                  ),
                ],
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildOxalateCard(bool isDark) {
    final progress = (oxalateMg / goalMg).clamp(0.0, 1.0);
    final oxColor = _oxalateColor(oxalateMg);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Oxalate Intake',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(
                  '${oxalateMg.toStringAsFixed(1)} / ${goalMg.toInt()} mg',
                  style: TextStyle(
                      fontSize: 14,
                      color: oxColor,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(oxColor),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _oxalateStatus(oxalateMg),
              style: TextStyle(fontSize: 13, color: oxColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ).then((_) => loadData()),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.teal.withValues(alpha: 0.2),
                      backgroundImage: _avatarPath.isNotEmpty
                          ? FileImage(File(_avatarPath))
                          : null,
                      child: _avatarPath.isEmpty
                          ? const Icon(Icons.person, color: Colors.teal)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.isNotEmpty
                              ? 'Hi, $_userName 👋'
                              : 'StoneGuard',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _motivationalText(waterOz),
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Badges chip
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoryProgressScreen()),
                    ).then((_) => loadData()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🏅', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '$_unlockedCount/${_kAllBadges.length}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reset button
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Reset today',
                    onPressed: _resetAll,
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Water meter
                    Center(child: _buildWaterMeter()),

                    const SizedBox(height: 20),

                    // Quick-add water buttons
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.0,
                      children: [8, 12, 16, 20]
                          .map((oz) => _waterButton(oz))
                          .toList(),
                    ),

                    const SizedBox(height: 16),

                    // Oxalate card
                    _buildOxalateCard(isDark),

                    const SizedBox(height: 16),

                    // Navigation cards row
                    Row(
                      children: [
                        Expanded(
                          child: _NavCard(
                            icon: Icons.history_rounded,
                            label: 'History',
                            color: Colors.indigo,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const HistoryProgressScreen()),
                            ).then((_) => loadData()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NavCard(
                            icon: Icons.settings_rounded,
                            label: 'Settings',
                            color: Colors.blueGrey,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()),
                            ).then((_) => loadData()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Banner ad
                    const BannerAdWidget(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SMALL NAV CARD ───────────────────────────────────────────────────────────
class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
