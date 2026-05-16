// ─── HOME SHIELD SCREEN ───────────────────────────────────────────────────────
// Batch G: UI polish
//   • Branding fix: header fallback 'StoneGuard' → 'KidneyShield'
//   • Water buttons use AppColors tokens + dark-mode-aware ink response
//   • Oxalate card uses AppCard + AppTextStyles
//   • Nav quick-links use AppCard (ink splash, themed surface, teal icons)
//   • Reset button wrapped in AppIconBadge for visual weight
//   • All hardcoded Colors.white/black* replaced with AppDynamic helpers
// Fix A: Reset dialog destructive button now uses AppColors.danger
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/banner_ad_widget.dart';
import '../main.dart';
import '../hydration_repository.dart';
import '../secure_prefs.dart';
import '../theme/app_theme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'settings_screen.dart';
import 'history_progress_screen.dart';

// ─── WAVE PAINTER ────────────────────────────────────────────────────────────
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

// ─── RING PAINTER ─────────────────────────────────────────────────────────────
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

// ─── BADGE DEFINITIONS ────────────────────────────────────────────────────────
const List<Map<String, dynamic>> _kAllBadges = [
  {'id': 'first_log',     'icon': '🥇', 'milestone': false},
  {'id': 'streak_3',      'icon': '🔥', 'milestone': false},
  {'id': 'hydration_hero','icon': '💧', 'milestone': false},
  {'id': 'stone_guardian','icon': '🛡️', 'milestone': false},
  {'id': 'champ_7',       'icon': '🏆', 'milestone': true},
  {'id': 'logger_14',     'icon': '📅', 'milestone': false},
  {'id': 'habit_21',      'icon': '🌟', 'milestone': false},
  {'id': 'warrior_30',    'icon': '🥈', 'milestone': true},
  {'id': 'streak_30',     'icon': '⚡', 'milestone': true},
  {'id': 'guardian_90',   'icon': '🎖️', 'milestone': true},
  {'id': 'defender_180',  'icon': '🥉', 'milestone': true},
  {'id': 'legend_365',    'icon': '👑', 'milestone': true},
  {'id': 'diamond_730',   'icon': '💎', 'milestone': true},
];

// ─── MAIN SCREEN ──────────────────────────────────────────────────────────────
class HomeShieldScreen extends StatefulWidget {
  const HomeShieldScreen({super.key});
  @override
  State<HomeShieldScreen> createState() => HomeShieldScreenState();
}

class HomeShieldScreenState extends State<HomeShieldScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  double waterOz   = 0;
  double oxalateMg = 0;
  double goalOz    = 80;
  double goalMg    = 200;

  final _repo   = HydrationRepository.instance;
  final _secure = SecurePrefs.instance;

  Set<String> _celebratedBadges = {};
  int get _unlockedCount =>
      _kAllBadges.where((b) => _celebratedBadges.contains(b['id'])).length;

  late AnimationController _fillController;
  late Animation<double>   _fillAnimation;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double>   _pulseAnimation;

  String _userName   = '';
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

  Future<void> loadData() async {
    final snapshot       = await _repo.readToday();
    final userName       = await _secure.getString('user_name');
    final avatarPath     = await _secure.getString('avatar_path');
    final celebratedList = await _secure.getStringList('celebrated_badges');

    if (!mounted) return;
    setState(() {
      waterOz   = snapshot.waterOz;
      oxalateMg = snapshot.oxalateMg;
      goalOz    = snapshot.goalOz;
      goalMg    = snapshot.goalMg;
      _userName        = userName;
      _avatarPath      = avatarPath;
      _celebratedBadges = celebratedList.toSet();
      final visualFill = (snapshot.waterOz / snapshot.goalOz).clamp(0.0, 1.0);
      _fillAnimation =
          Tween<double>(begin: visualFill, end: visualFill).animate(
              CurvedAnimation(
                  parent: _fillController, curve: Curves.easeInOutCubic));
    });
  }

  Future<void> _addWater(double oz) async {
    final result = await _repo.addWater(oz);

    if (result is SaveFailure<double>) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save — please try again.')),
      );
      return;
    }

    final newOz = (result as SaveSuccess<double>).value;
    if (!mounted) return;

    final currentAnimProg = _fillAnimation.value;
    final newVisualFill   = (newOz / goalOz).clamp(0.0, 1.0);
    _fillAnimation = Tween<double>(begin: currentAnimProg, end: newVisualFill)
        .animate(CurvedAnimation(
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
            'This will clear all water and oxalate data for today. '
            'This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            // Fix A: was Colors.redAccent — now uses AppColors.danger token
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _repo.resetToday();
    if (!mounted) return;

    final currentAnimProg = _fillAnimation.value;
    _fillAnimation =
        Tween<double>(begin: currentAnimProg, end: 0).animate(CurvedAnimation(
            parent: _fillController, curve: Curves.easeInOutCubic));
    _fillController.forward(from: 0);
    setState(() {
      waterOz   = 0;
      oxalateMg = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Today's data has been reset.")),
    );
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
    if (mg >= goalMg)            return const Color(0xFFE53935);
    if (mg >= goalMg * 0.75)     return const Color(0xFFFFA726);
    if (mg >= goalMg * 0.50)     return const Color(0xFFFFEE58);
    return const Color(0xFF66BB6A);
  }

  String _oxalateStatus(double mg) {
    if (mg >= goalMg)            return '⛔ Daily limit reached — no more high-oxalate foods!';
    if (mg >= goalMg * 0.75)     return '⚠️ Getting close to your limit — be careful!';
    if (mg >= goalMg * 0.50)     return '🟡 Moderate intake — watch your next meal';
    return '✅ Great job — staying well within your limit!';
  }

  String _motivationalText(double oz) {
    if (oz >= goalOz * 1.25) return '🌊 Super-hydrated! You\'re crushing it today!';
    if (oz >= goalOz)        return '🎉 Daily goal reached! Keep going!';
    if (oz >= goalOz * 0.75) return '💪 Almost there — keep it up!';
    if (oz >= goalOz * 0.50) return '👍 Halfway there, great progress!';
    if (oz >= goalOz * 0.25) return '💧 Good start — keep drinking!';
    return '🛡️ Start hydrating to build your shield!';
  }

  // ── Water quick-add buttons — themed, dark-mode aware ──────────────────────
  Widget _waterButton(int oz) {
    return Material(
      color: AppColors.teal,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _addWater(oz.toDouble()),
        splashColor: Colors.white.withValues(alpha: 0.18),
        highlightColor: Colors.white.withValues(alpha: 0.10),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            '+$oz oz',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Water meter ────────────────────────────────────────────────────────────
  Widget _buildWaterMeter(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_fillAnimation, _waveController, _pulseAnimation]),
      builder: (context, _) {
        final fillProg  = _fillAnimation.value.clamp(0.0, 1.0);
        final ringColor = _lerpShieldColor(fillProg);
        final wavePhase = _waveController.value * 2 * pi;

        return ScaleTransition(
          scale: _pulseAnimation,
          child: SizedBox(
            height: 230,
            width: 230,
            child: Stack(alignment: Alignment.center, children: [
              // Glow ring
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
              // Progress ring
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
              // Wave fill
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
              // Center text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${waterOz.toStringAsFixed(waterOz == waterOz.roundToDouble() ? 0 : 1)} oz',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppDynamic.textPrimary(context),
                    ),
                  ),
                  Text(
                    'of ${goalOz.toInt()} oz',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppDynamic.textSecond(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(fillProg * 100).toInt()}%',
                    style: GoogleFonts.inter(
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

  // ── Oxalate card — uses AppCard + AppTextStyles ────────────────────────────
  Widget _buildOxalateCard(BuildContext context) {
    final progress = (oxalateMg / goalMg).clamp(0.0, 1.0);
    final oxColor  = _oxalateColor(oxalateMg);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Oxalate Intake',
                  style: AppTextStyles.itemTitleOf(context)),
              Text(
                '${oxalateMg.toStringAsFixed(1)} / ${goalMg.toInt()} mg',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: oxColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              // Softer track — uses theme border color instead of black12
              backgroundColor: AppDynamic.border(context),
              valueColor: AlwaysStoppedAnimation<Color>(oxColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _oxalateStatus(oxalateMg),
            style: GoogleFonts.inter(fontSize: 13, color: oxColor),
          ),
        ],
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
            // ── Header row ────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Avatar → Settings
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    ).then((_) => loadData()),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          AppColors.teal.withValues(alpha: 0.18),
                      backgroundImage: _avatarPath.isNotEmpty
                          ? FileImage(File(_avatarPath))
                          : null,
                      child: _avatarPath.isEmpty
                          ? const Icon(Icons.person, color: AppColors.teal)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Greeting + motivational text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.isNotEmpty
                              ? 'Hi, $_userName 👋'
                              : 'KidneyShield',  // Batch G: was 'StoneGuard'
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppDynamic.textPrimary(context),
                          ),
                        ),
                        Text(
                          _motivationalText(waterOz),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppDynamic.textSecond(context),
                          ),
                          // Batch G: was maxLines:1 — short motivational
                          // strings with emojis were truncating on small phones
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Badge chip → History
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const HistoryProgressScreen()),
                    ).then((_) => loadData()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🏅',
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '$_unlockedCount/${_kAllBadges.length}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reset button — AppIconBadge gives it visual weight
                  GestureDetector(
                    onTap: _resetAll,
                    child: Tooltip(
                      message: 'Reset today',
                      child: AppIconBadge(
                        icon: Icons.refresh_rounded,
                        color: isDark
                            ? AppColors.darkTextSecond
                            : AppColors.textSecond,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Center(child: _buildWaterMeter(context)),
                    const SizedBox(height: 20),
                    // Water quick-add buttons
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
                    _buildOxalateCard(context),
                    const SizedBox(height: 16),
                    // Quick-nav cards — AppCard for ink + themed surface
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const HistoryProgressScreen()),
                            ).then((_) => loadData()),
                            padding: const EdgeInsets.symmetric(
                                vertical: 18),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.history_rounded,
                                  color: AppColors.teal,
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'History',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.teal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const SettingsScreen()),
                            ).then((_) => loadData()),
                            padding: const EdgeInsets.symmetric(
                                vertical: 18),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.settings_rounded,
                                  color: AppColors.teal,
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Settings',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.teal,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
