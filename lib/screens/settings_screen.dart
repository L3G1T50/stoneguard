// ─── SETTINGS SCREEN ────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import '../screens/about_screen.dart';
import '../main.dart';
import 'paywall_screen.dart';
import '../theme/app_theme.dart';

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
    if (result == true) await _loadSettings();
  }

  Future<void> _saveWaterGoal(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('goal_water', v);
    setState(() => _waterGoal = v);
  }

  Future<void> _saveOxalateGoal(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('goal_oxalate', v);
    setState(() => _oxalateGoal = v);
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your first name',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.teal),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      final p = await SharedPreferences.getInstance();
      await p.setString('user_name', result);
      setState(() => _userName = result);
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will permanently delete all water logs, oxalate logs, food logs, and favourites. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final wasPremium = _isPremium;
      await prefs.clear();
      await prefs.setBool('seen_onboarding', true);
      await prefs.setBool('is_premium', wasPremium);
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 300);
    if (picked != null) {
      final p = await SharedPreferences.getInstance();
      await p.setString('avatar_path', picked.path);
      setState(() => _avatarPath = picked.path);
    }
  }

  // ─── EXPORT FOR DOCTOR ─────────────────────────────────────────────────────
  Future<void> _exportForDoctor() async {
    if (!_isPremium) {
      _openPaywall();
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    // Gather water logs
    final waterKeys = prefs.getKeys().where((k) => k.startsWith('water_')).toList()..sort();
    final waterLines = waterKeys.map((k) {
      final date = k.replaceFirst('water_', '');
      final oz = prefs.getDouble(k) ?? 0;
      return '  $date: ${oz.toStringAsFixed(1)} oz';
    }).join('\n');

    // Gather oxalate logs
    final oxalateKeys = prefs.getKeys().where((k) => k.startsWith('oxalate_')).toList()..sort();
    final oxalateLines = oxalateKeys.map((k) {
      final date = k.replaceFirst('oxalate_', '');
      final mg = prefs.getDouble(k) ?? 0;
      return '  $date: ${mg.toStringAsFixed(1)} mg';
    }).join('\n');

    final name = _userName.isEmpty ? 'Patient' : _userName;
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

    final report = '''
StoneGuard — Doctor Export Report
Generated: $dateStr
Patient: $name

━━━━━━━━━━━━━━━━━━━━━━━
DAILY GOALS
━━━━━━━━━━━━━━━━━━━━━━━
Water Goal:    ${_waterGoal.toInt()} oz / day
Oxalate Limit: ${_oxalateGoal.toInt()} mg / day

━━━━━━━━━━━━━━━━━━━━━━━
WATER INTAKE LOG
━━━━━━━━━━━━━━━━━━━━━━━
${waterLines.isEmpty ? '  No data recorded yet.' : waterLines}

━━━━━━━━━━━━━━━━━━━━━━━
OXALATE INTAKE LOG
━━━━━━━━━━━━━━━━━━━━━━━
${oxalateLines.isEmpty ? '  No data recorded yet.' : oxalateLines}

━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━
This report is generated by StoneGuard and is for
informational purposes only. It is not a substitute
for professional medical advice.
''';

    await Share.share(report, subject: 'StoneGuard Report — $dateStr');
  }

  Future<void> scheduleWaterReminders(int intervalHours) async {
    await flutterLocalNotificationsPlugin.cancelAll();
    if (intervalHours == 0) return;
    final msgs = [
      '💧 Time to hydrate! Your kidneys will thank you.',
      '🧙 Drink some water! Stay ahead of kidney stones.',
      '💦 Hydration check! Have you hit your water goal today?',
      '🌊 Your kidneys need water — take a sip now!',
      '⏰ Water reminder! Small sips add up to big protection.',
    ];
    for (int i = 0; i < 24; i += intervalHours) {
      final now = tz.TZDateTime.now(tz.local);
      var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, i, 0);
      if (t.isBefore(now)) t = t.add(const Duration(days: 1));
      await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        'StoneGuard 🛡️',
        msgs[i % msgs.length],
        t,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminders', 'Water Reminders',
            channelDescription: 'Reminds you to drink water throughout the day',
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

  // ─── PLUS CARD ──────────────────────────────────────────────────────────────────────────
  Widget _plusCard() {
    return AppCard(
      onTap: _isPremium ? null : _openPaywall,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      color: _isPremium ? AppColors.tealDark : AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _isPremium
                  ? Colors.white.withValues(alpha: 0.18)
                  : AppColors.tealLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 24,
              color: _isPremium ? Colors.white : AppColors.teal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPremium
                      ? 'StoneGuard Plus — Active'
                      : 'Upgrade to StoneGuard Plus',
                  style: AppTextStyles.itemTitle.copyWith(
                    color: _isPremium ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _isPremium
                      ? 'You have full access to all premium features.'
                      : 'Doctor reports, full history & ad-free experience.',
                  style: AppTextStyles.body.copyWith(
                    color: _isPremium
                        ? Colors.white.withValues(alpha: 0.80)
                        : AppColors.textSecond,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isPremium)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Active ✓',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('See Plans',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
        ],
      ),
    );
  }

  // ─── ROW ITEM ──────────────────────────────────────────────────────────────────────
  Widget _row(IconData icon, Color color, String title, String sub,
      {VoidCallback? onTap, Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AppIconBadge(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.itemTitle),
                if (sub.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(sub, style: AppTextStyles.body),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing
          else if (onTap != null)
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }

  // ─── VALUE BADGE ───────────────────────────────────────────────────────────────────────
  Widget _valueBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding.add(
              const EdgeInsets.only(bottom: 32)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── TITLE ──
              const AppScreenTitle('Settings'),

              // ── PROFILE ──
              const SizedBox(height: 16),
              AppCard(
                onTap: _editName,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.tealLight,
                        backgroundImage: _avatarPath.isNotEmpty
                            ? FileImage(File(_avatarPath))
                            : null,
                        child: _avatarPath.isEmpty
                            ? const Icon(Icons.person,
                                color: AppColors.teal, size: 28)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName.isEmpty ? 'Add Your Name' : _userName,
                            style: AppTextStyles.itemTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userName.isEmpty
                                ? 'Tap to personalise your experience'
                                : 'Tap avatar to change photo',
                            style: AppTextStyles.body,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textHint, size: 20),
                  ],
                ),
              ),

              // ── STONEGUARD PLUS ──
              const AppSectionHeader('StoneGuard Plus'),
              _plusCard(),

              // ── EXPORT FOR DOCTOR ──
              const AppSectionHeader('Export'),
              AppCard(
                child: _row(
                  Icons.picture_as_pdf_outlined,
                  AppColors.teal,
                  'Export for Doctor',
                  _isPremium
                      ? 'Share your logs as a text report'
                      : 'StoneGuard Plus required',
                  onTap: _exportForDoctor,
                  trailing: _isPremium
                      ? const Icon(Icons.chevron_right,
                          color: AppColors.textHint, size: 20)
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('Plus',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.teal)),
                        ),
                ),
              ),

              // ── NOTIFICATIONS ──
              const AppSectionHeader('Notifications'),
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const AppIconBadge(
                              icon: Icons.notifications_outlined,
                              color: Colors.blue),
                          const SizedBox(width: 14),
                          Text('Water Reminders',
                              style: AppTextStyles.itemTitle),
                        ]),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: (val) async {
                            final p = await SharedPreferences.getInstance();
                            await p.setBool('notifications_enabled', val);
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
                          Text('Remind me every',
                              style: AppTextStyles.body),
                          DropdownButton<int>(
                            value: _reminderInterval,
                            underline: const SizedBox(),
                            items: [1, 2, 3, 4, 6]
                                .map((h) => DropdownMenuItem(
                                      value: h,
                                      child: Text('$h hour${h > 1 ? 's' : ''}',
                                          style: AppTextStyles.itemTitle),
                                    ))
                                .toList(),
                            onChanged: (val) async {
                              if (val == null) return;
                              final p = await SharedPreferences.getInstance();
                              await p.setInt('reminder_interval', val);
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
              const AppSectionHeader('Daily Goals'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Water
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.water_drop,
                              color: AppColors.teal, size: 20),
                          const SizedBox(width: 8),
                          Text('Water Goal', style: AppTextStyles.itemTitle),
                        ]),
                        _valueBadge(
                            '${_waterGoal.toInt()} oz', AppColors.teal),
                      ],
                    ),
                    Slider(
                      value: _waterGoal,
                      min: 32,
                      max: 160,
                      divisions: 16,
                      onChanged: (v) => _saveWaterGoal(v.roundToDouble()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('32 oz', style: AppTextStyles.micro),
                        Text('160 oz', style: AppTextStyles.micro),
                      ],
                    ),
                    const Divider(height: 32),
                    // Oxalate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.science_outlined,
                              color: AppColors.oxalate, size: 20),
                          const SizedBox(width: 8),
                          Text('Oxalate Limit',
                              style: AppTextStyles.itemTitle),
                        ]),
                        _valueBadge(
                            '${_oxalateGoal.toInt()} mg', AppColors.oxalate),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.oxalate,
                        thumbColor: AppColors.oxalate,
                        inactiveTrackColor:
                            AppColors.oxalate.withValues(alpha: 0.18),
                        overlayColor:
                            AppColors.oxalate.withValues(alpha: 0.12),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _oxalateGoal,
                        min: 50,
                        max: 500,
                        divisions: 18,
                        onChanged: (v) =>
                            _saveOxalateGoal(v.roundToDouble()),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('50 mg', style: AppTextStyles.micro),
                        Text('500 mg', style: AppTextStyles.micro),
                      ],
                    ),
                  ],
                ),
              ),

              // ── ABOUT ──
              const AppSectionHeader('About'),
              AppCard(
                child: Column(
                  children: [
                    _row(
                      Icons.info_outline,
                      AppColors.teal,
                      'About StoneGuard',
                      'Version 1.0.0',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AboutScreen()),
                      ),
                    ),
                    const Divider(height: 24),
                    _row(
                      Icons.medical_information_outlined,
                      AppColors.warning,
                      'Medical Disclaimer',
                      'This app is not medical advice',
                      onTap: () => showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Medical Disclaimer'),
                          content: const Text(
                            'StoneGuard is intended for informational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment.\n\nAlways consult your physician or a qualified healthcare provider regarding your kidney stone condition and dietary needs.',
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('I Understand'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── DANGER ZONE ──
              const AppSectionHeader('Danger Zone'),
              AppCard(
                child: _row(
                  Icons.delete_forever_outlined,
                  AppColors.danger,
                  'Clear All Data',
                  'Permanently delete all logs and favourites',
                  onTap: _clearAllData,
                ),
              ),

              const SizedBox(height: 32),
              Center(
                child: Text('StoneGuard v1.0.0',
                    style: AppTextStyles.micro),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
