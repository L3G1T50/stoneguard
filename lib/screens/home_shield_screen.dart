// ─── HOME SHIELD SCREEN ────────────────────────────────────────
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/banner_ad_widget.dart';
import '../main.dart';
import 'settings_screen.dart';


class HomeShieldScreen extends StatefulWidget {
  const HomeShieldScreen({super.key});
  @override
  State<HomeShieldScreen> createState() => HomeShieldScreenState();
}


class HomeShieldScreenState extends State<HomeShieldScreen>
    with SingleTickerProviderStateMixin {
  double waterOz = 0;
  double oxalateMg = 0;
  double goalOz = 80;
  double goalMg = 200;
  late AnimationController _animController;
  late Animation<double> _animation;
  double _previousOz = 0;
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
    _requestNotificationPermission();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _animation = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _saveTodayToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day
        .toString().padLeft(2, '0')}';

    final entry = jsonEncode({
      'date': dateStr,
      'water_oz': waterOz,
      'oxalate_mg': oxalateMg,
    });

    final raw = prefs.getStringList('daily_history') ?? [];

    // Replace today's entry if it exists, else add it
    final updated = raw.where((e) {
      final map = Map<String, dynamic>.from(jsonDecode(e));
      return map['date'] != dateStr;
    }).toList();
    updated.add(entry);

    if (updated.length > 730) updated.removeAt(0);

    await prefs.setStringList('daily_history', updated);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedWater = prefs.getDouble('water_$_todayKey') ?? 0;
    final savedOxalate = prefs.getDouble('oxalate_$_todayKey') ?? 0;
    final savedGoalOz = prefs.getDouble('goal_water') ?? 80;
    final savedGoalMg = prefs.getDouble('goal_oxalate') ?? 200;
    setState(() {
      waterOz = savedWater;
      oxalateMg = savedOxalate;
      goalOz = savedGoalOz;
      goalMg = savedGoalMg;
      _previousOz = savedWater;
      _userName = prefs.getString('user_name') ?? '';
      _avatarPath = prefs.getString('avatar_path') ?? '';
      _animation = Tween<double>(begin: savedWater / goalOz, end: savedWater / goalOz)
          .animate(_animController);
    });
  }

  Future<void> _addWater(double oz) async {
    final prefs = await SharedPreferences.getInstance();
    final newOz = (waterOz + oz).clamp(0.0, goalOz);
    _animation = Tween<double>(begin: _previousOz / goalOz, end: newOz / goalOz)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward(from: 0);
    setState(() {
      _previousOz = waterOz;
      waterOz = newOz;
    });
    await prefs.setDouble('water_$_todayKey', newOz);
    await _saveTodayToHistory();
  }

  Future<void> _resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    _animation = Tween<double>(begin: waterOz / goalOz, end: 0)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeInCubic));
    _animController.forward(from: 0);
    setState(() {
      _previousOz = 0;
      waterOz = 0;
      oxalateMg = 0;
    });
    await prefs.setDouble('water_$_todayKey', 0);
    await prefs.setDouble('oxalate_$_todayKey', 0);
    await prefs.setStringList('oxalate_log_$_todayKey', []);
    await _saveTodayToHistory();
  }

  Color _shieldColor(double progress) {
    if (progress >= 1.0) return const Color(0xFF00BCD4);
    if (progress >= 0.75) return const Color(0xFF66BB6A);
    if (progress >= 0.50) return const Color(0xFFFFEE58);
    if (progress >= 0.25) return const Color(0xFFFFA726);
    return const Color(0xFF78909C);
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

  Widget _tealDropIcon() {
    return ShaderMask(
      shaderCallback: (b) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF00B8D4), Color(0xFF0097A7)],
      ).createShader(b),
      child: const Icon(Icons.water_drop, size: 40, color: Colors.white),
    );
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

  @override
  Widget build(BuildContext context) {
    final double waterProgress = (waterOz / goalOz).clamp(0.0, 1.0);
    final Color activeColor = _shieldColor(waterProgress);
    final double remaining = (goalOz - waterOz).clamp(0.0, goalOz);
    final Color oxColor = _oxalateColor(oxalateMg);
    final double oxProgress = (oxalateMg / goalMg).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(children: [

            // ── HEADER ──
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: _avatarPath.isNotEmpty
                      ? FileImage(File(_avatarPath))
                      : null,
                  child: _avatarPath.isEmpty
                      ? const Icon(Icons.person, color: Colors.teal, size: 22)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    _userName.isEmpty ? 'Today\'s Shield' : 'Hey, $_userName! 👋',
                    style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  ),
                  Text('Stay hydrated. Stay protected.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ]),
              ]),
              // ── SETTINGS GEAR (top-right of home header) ──
              IconButton(
                icon: Icon(Icons.settings_outlined, color: Colors.grey.shade600),
                tooltip: 'Settings',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ]),

            const SizedBox(height: 28),

            // ── SHIELD RING (slightly smaller) ──
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final animProgress = _animation.value;
                final animColor = _shieldColor(animProgress);
                return SizedBox(height: 220, width: 220,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox(height: 220, width: 220,
                        child: CircularProgressIndicator(
                            value: 1, strokeWidth: 16,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                animColor.withValues(alpha: 0.12)))),
                    SizedBox(height: 220, width: 220,
                        child: CircularProgressIndicator(
                            value: animProgress, strokeWidth: 16,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(animColor))),
                    Container(height: 162, width: 162,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [Color(0xFFF7F9FB), Color(0xFFE0E5EC)]),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24, spreadRadius: 2,
                            offset: const Offset(0, 14))],
                      ),
                      child: Stack(alignment: Alignment.center, children: [
                        Icon(Icons.shield, size: 90, color: Colors.grey.shade400),
                        Positioned(top: 44, child: Container(width: 60, height: 28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.65),
                                    Colors.white.withValues(alpha: 0.0)
                                  ]),
                            ))),
                        _tealDropIcon(),
                      ]),
                    ),
                  ]),
                );
              },
            ),

            const SizedBox(height: 20),

            // ── OZ DISPLAY ──
            RichText(textAlign: TextAlign.center, text: TextSpan(children: [
              TextSpan(text: waterOz.toStringAsFixed(0),
                  style: TextStyle(fontSize: 42,
                      fontWeight: FontWeight.bold, color: activeColor)),
              TextSpan(text: ' / ${goalOz.toInt()} oz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,
                      color: Colors.grey.shade500)),
            ])),
            const SizedBox(height: 4),
            Text(_motivationalText(waterProgress), textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),

            if (waterOz < goalOz) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${remaining.toStringAsFixed(0)} oz remaining',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                border: Border.all(color: oxColor.withValues(alpha: 0.25), width: 1.5),
                boxShadow: [
                  BoxShadow(color: oxColor.withValues(alpha: 0.08),
                      blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card header
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
                          child: Icon(Icons.science_outlined, color: oxColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text('Daily Oxalate',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800)),
                      ]),
                      // mg badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: oxColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: RichText(text: TextSpan(children: [
                          TextSpan(text: oxalateMg.toStringAsFixed(1),
                              style: TextStyle(fontSize: 18,
                                  fontWeight: FontWeight.bold, color: oxColor)),
                          TextSpan(text: ' / ${goalMg.toInt()} mg',
                              style: TextStyle(fontSize: 12,
                                  color: Colors.grey.shade500)),
                        ])),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress bar
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

                  // Status message
                  Text(_oxalateStatus(oxalateMg),
                      style: TextStyle(fontSize: 13,
                          color: Colors.grey.shade600, height: 1.4)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── WATER BUTTONS ──
            const Align(alignment: Alignment.centerLeft,
                child: Text('Log Water Intake',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
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
      ),
    );
  }
}