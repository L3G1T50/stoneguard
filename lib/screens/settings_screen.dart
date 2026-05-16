// ─── SETTINGS SCREEN ───────────────────────────────────────────────
//
// Fix 3: Route health-related fields through SecurePrefs (AES-256 encrypted)
//   Fields migrated OFF plain SharedPreferences:
//     • user_name      — now SecurePrefs.setString / getString
//     • avatar_path    — now SecurePrefs.setString / getString
//     • goal_water     — now SecurePrefs.setDouble / getDouble
//     • goal_oxalate   — now SecurePrefs.setDouble / getDouble
//     • stone_type     — now SecurePrefs.setString / getString
//     • user_age       — now SecurePrefs.setInt    / getInt
//
//   Non-health fields that remain in plain SharedPreferences (safe):
//     • dark_mode, notifications_enabled, reminder_interval, is_premium
//     • quiet_hours_*, has_seen_onboarding, has_completed_setup
//
// Fix 11: Privacy section with ad consent revocation and privacy policy link.
//
// Batch E: _loadSettings() parallelised with Future.wait().
//   Previously the 6 SecurePrefs reads + SharedPreferences.getInstance()
//   + ConsentManager.hasConsented() were all sequential awaits — 8 serial
//   async hops on every settings open. Now all 8 fire concurrently inside
//   a single Future.wait() call so the screen loads in roughly the time of
//   the slowest single read instead of the sum of all reads.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../screens/about_screen.dart';
import '../screens/doctor_view_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../consent_manager.dart';
import '../secure_prefs.dart'; // Fix 3: encrypted storage helper
import '../main.dart';
import 'paywall_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Health-related state — loaded from SecurePrefs
  double _waterGoal    = 80;
  double _oxalateGoal  = 200;
  String _userName     = '';
  String _avatarPath   = '';
  int    _userAge      = 0;
  String _stoneType    = 'Unknown / Not diagnosed';

  // Non-health state — loaded from plain SharedPreferences
  bool   _notificationsEnabled = false;
  bool   _isPremium    = false;
  int    _reminderInterval = 2;
  bool   _darkMode     = false;
  bool   _adsConsented = false;

  // Quiet Hours
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd   = const TimeOfDay(hour: 7,  minute: 0);

  static const List<String> _stoneTypes = [
    'Calcium Oxalate',
    'Calcium Phosphate',
    'Uric Acid',
    'Struvite',
    'Cystine',
    'Unknown / Not diagnosed',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Batch E: all 8 async reads fire concurrently via Future.wait().
  // Before: 8 sequential awaits (~8 async hops).
  // After:  1 Future.wait() — resolves in the time of the slowest single read.
  Future<void> _loadSettings() async {
    final secure = SecurePrefs.instance;

    final results = await Future.wait([
      // indices 0-5: SecurePrefs (encrypted health fields)
      secure.getString('user_name',    defaultValue: ''),
      secure.getString('avatar_path',  defaultValue: ''),
      secure.getDouble('goal_water',   defaultValue: 80.0),
      secure.getDouble('goal_oxalate', defaultValue: 200.0),
      secure.getString('stone_type',   defaultValue: 'Unknown / Not diagnosed'),
      secure.getInt('user_age',        defaultValue: 0),
      // index 6: plain SharedPreferences
      SharedPreferences.getInstance(),
      // index 7: consent flag
      ConsentManager.hasConsented(),
    ]);

    final userName    = results[0]  as String;
    final avatarPath  = results[1]  as String;
    final waterGoal   = results[2]  as double;
    final oxalateGoal = results[3]  as double;
    final stoneType   = results[4]  as String;
    final userAge     = results[5]  as int;
    final prefs       = results[6]  as SharedPreferences;
    final consented   = results[7]  as bool;

    setState(() {
      _userName             = userName;
      _avatarPath           = avatarPath;
      _waterGoal            = waterGoal;
      _oxalateGoal          = oxalateGoal;
      _stoneType            = stoneType;
      _userAge              = userAge;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _reminderInterval     = prefs.getInt('reminder_interval')      ?? 2;
      _isPremium            = prefs.getBool('is_premium')            ?? false;
      _quietHoursEnabled    = prefs.getBool('quiet_hours_enabled')   ?? false;
      _darkMode             = prefs.getBool('dark_mode')             ?? false;
      _adsConsented         = consented;
      _quietStart = TimeOfDay(
        hour:   prefs.getInt('quiet_start_hour')   ?? 22,
        minute: prefs.getInt('quiet_start_minute') ?? 0,
      );
      _quietEnd = TimeOfDay(
        hour:   prefs.getInt('quiet_end_hour')   ?? 7,
        minute: prefs.getInt('quiet_end_minute') ?? 0,
      );
    });
  }

  Future<void> _saveQuietTime({
    required bool enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('quiet_hours_enabled', enabled);
    if (start != null) {
      await p.setInt('quiet_start_hour',   start.hour);
      await p.setInt('quiet_start_minute', start.minute);
    }
    if (end != null) {
      await p.setInt('quiet_end_hour',   end.hour);
      await p.setInt('quiet_end_minute', end.minute);
    }
    setState(() {
      _quietHoursEnabled = enabled;
      if (start != null) _quietStart = start;
      if (end   != null) _quietEnd   = end;
    });
    if (_notificationsEnabled) await scheduleWaterReminders(_reminderInterval);
  }

  bool _isQuietHour(int hour) {
    if (!_quietHoursEnabled) return false;
    final s = _quietStart.hour;
    final e = _quietEnd.hour;
    if (s < e) return hour >= s && hour < e;
    return hour >= s || hour < e;
  }

  Future<void> _pickQuietTime({required bool isStart}) async {
    final initial = isStart ? _quietStart : _quietEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? 'Quiet time starts' : 'Quiet time ends',
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked == null) return;
    await _saveQuietTime(
      enabled: _quietHoursEnabled,
      start: isStart ? picked : null,
      end:   isStart ? null    : picked,
    );
  }

  Future<void> _toggleDarkMode(bool val) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark_mode', val);
    setState(() => _darkMode = val);
    themeNotifier.setMode(val ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _openPaywall() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    if (!mounted) return;
    if (result == true) await _loadSettings();
  }

  // ── Fix 3: Goals now written to SecurePrefs ──────────────────────────────
  Future<void> _saveWaterGoal(double v) async {
    await SecurePrefs.instance.setDouble('goal_water', v);
    setState(() => _waterGoal = v);
  }

  Future<void> _saveOxalateGoal(double v) async {
    await SecurePrefs.instance.setDouble('goal_oxalate', v);
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
      // Fix 3: user_name written to SecurePrefs, not plain SharedPreferences
      await SecurePrefs.instance.setString('user_name', result);
      setState(() => _userName = result);
    }
  }

  Future<void> _editAge() async {
    final controller = TextEditingController(
        text: _userAge == 0 ? '' : '$_userAge');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Age'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'e.g. 35',
            prefixIcon: Icon(Icons.cake_outlined, color: AppColors.teal),
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
      final age = int.tryParse(result) ?? 0;
      // Fix 3: user_age written to SecurePrefs
      await SecurePrefs.instance.setInt('user_age', age);
      setState(() => _userAge = age);
    }
  }

  Future<void> _editStoneType() async {
    String selected = _stoneType;
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Stone Type',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose the type identified by your doctor, or Unknown.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  ..._stoneTypes.map((type) {
                    final isSelected = selected == type;
                    return InkWell(
                      onTap: () {
                        setSheet(() => selected = type);
                        Navigator.pop(ctx, type);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.teal.withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.teal.withValues(alpha: 0.35)
                                : Colors.grey.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.teal
                                  : Colors.grey.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.teal
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      // Fix 3: stone_type written to SecurePrefs
      await SecurePrefs.instance.setString('stone_type', result);
      setState(() => _stoneType = result);
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
      // Clear plain prefs
      final prefs = await SharedPreferences.getInstance();
      final wasPremium = _isPremium;
      await prefs.clear();
      await prefs.setBool('seen_onboarding', true);
      await prefs.setBool('is_premium', wasPremium);

      // Fix 3: also clear health fields from SecurePrefs
      final secure = SecurePrefs.instance;
      await secure.remove('user_name');
      await secure.remove('avatar_path');
      await secure.remove('goal_water');
      await secure.remove('goal_oxalate');
      await secure.remove('stone_type');
      await secure.remove('user_age');

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
      // Fix 3: avatar_path written to SecurePrefs
      await SecurePrefs.instance.setString('avatar_path', picked.path);
      setState(() => _avatarPath = picked.path);
    }
  }

  Future<void> _revokeAdConsent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Ad Consent?'),
        content: const Text(
          'Ads will no longer be shown. You can re-enable them from this '
          'screen at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ConsentManager.revokeConsent();
      if (!mounted) return;
      setState(() => _adsConsented = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad consent revoked. Ads will not appear.')),
      );
    }
  }

  Future<void> scheduleWaterReminders(int intervalHours) async {
    await flutterLocalNotificationsPlugin.cancelAll();
    if (intervalHours == 0) return;
    final msgs = [
      '💧 Time to hydrate! Your kidneys will thank you.',
      '🫙 Drink some water! Stay ahead of kidney stones.',
      '💦 Hydration check! Have you hit your water goal today?',
      '🌊 Your kidneys need water — take a sip now!',
      '⏰ Water reminder! Small sips add up to big protection.',
    ];
    int notifId = 0;
    for (int i = 0; i < 24; i += intervalHours) {
      if (_isQuietHour(i)) continue;
      final now = tz.TZDateTime.now(tz.local);
      var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, i, 0);
      if (t.isBefore(now)) t = t.add(const Duration(days: 1));
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notifId++,
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

  // ─── UI helpers ────────────────────────────────────────────────────────────────
  Widget _plusCard() {
    return AppCard(
      onTap: _isPremium ? null : _openPaywall,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      color: _isPremium ? AppColors.tealDark : null,
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
                    color: _isPremium ? Colors.white : null,
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
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _row(IconData icon, Color color, String title, String sub,
      {VoidCallback? onTap}) {
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
          if (onTap != null)
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }

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

  Widget _timeBadge(TimeOfDay time, {required VoidCallback onTap}) {
    final hour   = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
        ),
        child: Text(
          '$hour:$minute $period',
          style: const TextStyle(
            color: AppColors.teal,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.pagePadding.add(
                const EdgeInsets.only(bottom: 32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── PROFILE ──
                const SizedBox(height: 4),
                AppCard(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _editName,
                        behavior: HitTestBehavior.opaque,
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
                      const Divider(height: 24),
                      _row(
                        Icons.cake_outlined,
                        AppColors.teal,
                        'Age',
                        _userAge == 0 ? 'Tap to set your age' : '$_userAge years old',
                        onTap: _editAge,
                      ),
                      const Divider(height: 24),
                      _row(
                        Icons.science_outlined,
                        const Color(0xFF7B1FA2),
                        'Stone Type',
                        _stoneType,
                        onTap: _editStoneType,
                      ),
                    ],
                  ),
                ),

                // ── STONEGUARD PLUS ──
                const AppSectionHeader('StoneGuard Plus'),
                _plusCard(),

                // ── TOOLS ──
                const AppSectionHeader('Tools'),
                AppCard(
                  child: _row(
                    Icons.medical_services_outlined,
                    AppColors.teal,
                    'Export to Doctor',
                    'Share your health report as PDF or text',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DoctorViewScreen()),
                    ),
                  ),
                ),

                // ── APPEARANCE ──
                const AppSectionHeader('Appearance'),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        AppIconBadge(
                          icon: _darkMode
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: _darkMode
                              ? const Color(0xFF5C6BC0)
                              : const Color(0xFFF9A825),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dark Mode', style: AppTextStyles.itemTitle),
                            Text(
                              _darkMode ? 'Dark theme active' : 'Light theme active',
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ]),
                      Switch(
                        value: _darkMode,
                        onChanged: _toggleDarkMode,
                      ),
                    ],
                  ),
                ),

                // ── NOTIFICATIONS ──
                const AppSectionHeader('Notifications'),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                await scheduleWaterReminders(_reminderInterval);
                              } else {
                                await flutterLocalNotificationsPlugin.cancelAll();
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
                                await scheduleWaterReminders(val);
                              },
                            ),
                          ],
                        ),

                        const Divider(height: 24),
                        Row(
                          children: [
                            const AppIconBadge(
                              icon: Icons.bedtime_outlined,
                              color: Color(0xFF3949AB),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quiet Hours',
                                      style: AppTextStyles.itemTitle),
                                  Text(
                                    'No reminders during this window',
                                    style: AppTextStyles.body,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _quietHoursEnabled,
                              onChanged: (val) =>
                                  _saveQuietTime(enabled: val),
                            ),
                          ],
                        ),

                        if (_quietHoursEnabled) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3949AB)
                                  .withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF3949AB)
                                    .withValues(alpha: 0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.bedtime_outlined,
                                        color: Color(0xFF3949AB), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'No reminders sent between:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF3949AB),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('From',
                                            style: AppTextStyles.micro),
                                        const SizedBox(height: 4),
                                        _timeBadge(
                                          _quietStart,
                                          onTap: () => _pickQuietTime(
                                              isStart: true),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Icon(Icons.arrow_forward,
                                          size: 16,
                                          color: AppColors.textHint),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Until',
                                            style: AppTextStyles.micro),
                                        const SizedBox(height: 4),
                                        _timeBadge(
                                          _quietEnd,
                                          onTap: () => _pickQuietTime(
                                              isStart: false),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '💡 Tap the times above to customise. Default: 10 PM – 7 AM',
                            style: AppTextStyles.micro
                                .copyWith(color: AppColors.textHint),
                          ),
                        ],
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

                // ── PRIVACY ──
                const AppSectionHeader('Privacy'),
                AppCard(
                  child: Column(
                    children: [
                      _row(
                        Icons.privacy_tip_outlined,
                        AppColors.teal,
                        'Privacy Policy',
                        'How your health data is stored and protected',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen()),
                        ),
                      ),
                      const Divider(height: 24),
                      _row(
                        Icons.ads_click_outlined,
                        _adsConsented
                            ? AppColors.teal
                            : AppColors.textHint,
                        'Ad Preferences',
                        _adsConsented
                            ? 'Personalised ads: On — tap to revoke'
                            : 'Ads declined — no ad tracking active',
                        onTap: _adsConsented ? _revokeAdConsent : null,
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
      ],
    );

    return GradientScaffold(
      title: 'Settings',
      body: body,
    );
  }
}
