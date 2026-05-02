// ─── SETTINGS SCREEN ────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../screens/about_screen.dart';
import '../main.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _waterGoal = 80;
  double _oxalateGoal = 200;
  String _userName = '';
  String _avatarPath = '';
  bool _notificationsEnabled = false;
  bool _isPremium = false;
  int _reminderInterval = 2;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterGoal = prefs.getDouble('goal_water') ?? 80;
      _oxalateGoal = prefs.getDouble('goal_oxalate') ?? 200;
      _userName = prefs.getString('user_name') ?? '';
      _avatarPath = prefs.getString('avatar_path') ?? '';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _reminderInterval = prefs.getInt('reminder_interval') ?? 2;
      _isPremium = prefs.getBool('is_premium') ?? false;
    });
  }

  Future<void> _openPaywall() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    if (!mounted) return;
    if (result == true) {
      await _loadSettings();
    }
  }

  Future<void> _saveWaterGoal(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goal_water', value);
    setState(() => _waterGoal = value);
  }

  Future<void> _saveOxalateGoal(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goal_oxalate', value);
    setState(() => _oxalateGoal = value);
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Your Name',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Enter your first name',
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.person_outline, color: Colors.teal),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', result);
      setState(() => _userName = result);
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data?',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'This will permanently delete all your water logs, oxalate logs, food logs, and favorites. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      // Save premium status before clearing so it survives the data wipe
      final wasPremium = _isPremium;
      await prefs.clear();
      await prefs.setBool('seen_onboarding', true);
      await prefs.setBool('is_premium', wasPremium);
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All data cleared successfully'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Text(title,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
              letterSpacing: 1.1)),
    );
  }

  Widget _settingsCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, Color color, String title, String subtitle,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 300,
    );
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', picked.path);
      setState(() {
        _avatarPath = picked.path;
      });
    }
  }

  Future<void> scheduleWaterReminders(int intervalHours) async {
    await flutterLocalNotificationsPlugin.cancelAll();
    if (intervalHours == 0) return;
    final List<String> messages = [
      '💧 Time to hydrate! Your kidneys will thank you.',
      '🫙 Drink some water! Stay ahead of kidney stones.',
      '💦 Hydration check! Have you hit your water goal today?',
      '🌊 Your kidneys need water — take a sip now!',
      '⏰ Water reminder! Small sips add up to big protection.',
    ];
    for (int i = 0; i < 24; i += intervalHours) {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        i,
        0,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        'StoneGuard 🛡️',
        messages[i % messages.length],
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminders',
            'Water Reminders',
            channelDescription:
            'Reminds you to drink water throughout the day',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // ─── STONEGUARD PLUS CARD ─────────────────────────────────────
  Widget _plusCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _isPremium
            ? const LinearGradient(
          colors: [Color(0xFF1A8A9A), Color(0xFF0D6B78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFFEAF6F8), Color(0xFFD4EEF3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A8A9A)
                .withValues(alpha: _isPremium ? 0.30 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _isPremium ? null : _openPaywall,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isPremium
                        ? Colors.white.withValues(alpha: 0.20)
                        : const Color(0xFF1A8A9A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 26,
                    color: _isPremium
                        ? Colors.white
                        : const Color(0xFF1A8A9A),
                  ),
                ),
                const SizedBox(width: 16),
                // Text column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPremium
                            ? 'StoneGuard Plus — Active'
                            : 'Upgrade to StoneGuard Plus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _isPremium
                              ? Colors.white
                              : const Color(0xFF0D6B78),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _isPremium
                            ? 'You have full access to all premium features.'
                            : 'Doctor reports, full history & ad-free experience.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: _isPremium
                              ? Colors.white.withValues(alpha: 0.85)
                              : const Color(0xFF4A9BAA),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Trailing: badge if active, button if not
                if (_isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Active ✓',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A8A9A),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'See Plans',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── HEADER ──
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Settings',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ),

              // ── PROFILE ──
              _settingsCard(
                child: GestureDetector(
                  onTap: _editName,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.teal.shade100,
                          backgroundImage: _avatarPath.isNotEmpty
                              ? FileImage(File(_avatarPath))
                              : null,
                          child: _avatarPath.isEmpty
                              ? const Icon(Icons.person,
                              color: Colors.teal, size: 28)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName.isEmpty
                                  ? 'Add Your Name'
                                  : _userName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            Text(
                              _userName.isEmpty
                                  ? 'Tap to personalize your experience'
                                  : 'Tap avatar to change photo',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                ),
              ),

              // ── STONEGUARD PLUS ──
              _sectionHeader('STONEGUARD PLUS'),
              _plusCard(),

              // ── NOTIFICATIONS ──
              _sectionHeader('NOTIFICATIONS'),
              _settingsCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: Colors.blue, size: 20),
                          ),
                          const SizedBox(width: 14),
                          const Text('Water Reminders',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ]),
                        Switch(
                          value: _notificationsEnabled,
                          activeThumbColor: Colors.teal,
                          onChanged: (val) async {
                            final prefs =
                            await SharedPreferences.getInstance();
                            await prefs.setBool(
                                'notifications_enabled', val);
                            setState(() => _notificationsEnabled = val);
                            if (val) {
                              scheduleWaterReminders(_reminderInterval);
                            } else {
                              flutterLocalNotificationsPlugin.cancelAll();
                            }
                          },
                        ),
                      ],
                    ),
                    if (_notificationsEnabled) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Remind me every',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                          DropdownButton<int>(
                            value: _reminderInterval,
                            underline: const SizedBox(),
                            items: [1, 2, 3, 4, 6]
                                .map((h) => DropdownMenuItem(
                              value: h,
                              child: Text(
                                  '$h hour${h > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.w600)),
                            ))
                                .toList(),
                            onChanged: (val) async {
                              if (val == null) return;
                              final prefs =
                              await SharedPreferences.getInstance();
                              await prefs.setInt('reminder_interval', val);
                              setState(() => _reminderInterval = val);
                              scheduleWaterReminders(val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── DAILY GOALS ──
              _sectionHeader('DAILY GOALS'),
              _settingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Water Goal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.water_drop,
                              color: Colors.teal, size: 20),
                          const SizedBox(width: 8),
                          const Text('Water Goal',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${_waterGoal.toInt()} oz',
                              style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Slider(
                      value: _waterGoal,
                      min: 32,
                      max: 160,
                      divisions: 16,
                      activeColor: Colors.teal,
                      inactiveColor:
                      Colors.teal.withValues(alpha: 0.15),
                      onChanged: (v) => _saveWaterGoal(v.roundToDouble()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('32 oz',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400)),
                        Text('160 oz',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400)),
                      ],
                    ),
                    const Divider(height: 32),
                    // Oxalate Goal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.science_outlined,
                              color: Color(0xFF7B1FA2), size: 20),
                          const SizedBox(width: 8),
                          const Text('Oxalate Limit',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B1FA2)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${_oxalateGoal.toInt()} mg',
                              style: const TextStyle(
                                  color: Color(0xFF7B1FA2),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Slider(
                      value: _oxalateGoal,
                      min: 50,
                      max: 500,
                      divisions: 18,
                      activeColor: const Color(0xFF7B1FA2),
                      inactiveColor: const Color(0xFF7B1FA2)
                          .withValues(alpha: 0.15),
                      onChanged: (v) =>
                          _saveOxalateGoal(v.roundToDouble()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('50 mg',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400)),
                        Text('500 mg',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── ABOUT ──
              _sectionHeader('ABOUT'),
              _settingsCard(
                child: Column(
                  children: [
                    _infoRow(
                      Icons.info_outline,
                      Colors.teal,
                      'About StoneGuard',
                      'Version 1.0.0',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 24),
                    _infoRow(
                      Icons.medical_information_outlined,
                      Colors.orange,
                      'Medical Disclaimer',
                      'This app is not medical advice',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(20)),
                            title: const Text('Medical Disclaimer',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            content: const Text(
                              'StoneGuard is intended for informational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment.\n\nAlways consult your physician or a qualified healthcare provider regarding your kidney stone condition and dietary needs.',
                              style: TextStyle(height: 1.5),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12)),
                                ),
                                child: const Text('I Understand'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── DANGER ZONE ──
              _sectionHeader('DANGER ZONE'),
              _settingsCard(
                child: _infoRow(
                  Icons.delete_forever_outlined,
                  Colors.redAccent,
                  'Clear All Data',
                  'Permanently delete all logs and favorites',
                  onTap: _clearAllData,
                ),
              ),

              const SizedBox(height: 32),

              // ── APP VERSION ──
              Center(
                child: Text('StoneGuard v1.0.0',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}