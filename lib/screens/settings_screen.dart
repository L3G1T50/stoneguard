// settings_screen.dart
//
// SecurePrefs has no getBool/setBool.
// Booleans are stored as the strings 'true' / 'false' via getString/setString.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../consent_manager.dart';
import '../secure_prefs.dart';
import '../app_logger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _teal    = Color(0xFF1A8A9A);
  static const Color _dark    = Color(0xFF1A2530);
  static const Color _muted   = Color(0xFF607D8B);
  static const Color _bgColor = Color(0xFFF4F8FA);
  static const Color _danger  = Color(0xFFD32F2F);

  String _userName      = '';
  double _oxalateGoal   = 200;
  double _waterGoal     = 80;
  bool   _notifications = true;
  bool   _loading       = true;

  final _nameCtrl    = TextEditingController();
  final _oxalateCtrl = TextEditingController();
  final _waterCtrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sp = SecurePrefs.instance;
      final name  = await sp.getString ('user_name',        defaultValue: '');
      final ox    = await sp.getDouble ('goal_oxalate',     defaultValue: 200.0);
      final wat   = await sp.getDouble ('goal_water',       defaultValue: 80.0);
      // Booleans stored as string 'true'/'false'
      final notifStr = await sp.getString('notifications_on', defaultValue: 'true');
      setState(() {
        _userName      = name;
        _oxalateGoal   = ox;
        _waterGoal     = wat;
        _notifications = notifStr == 'true';
        _nameCtrl.text    = name;
        _oxalateCtrl.text = ox.toStringAsFixed(0);
        _waterCtrl.text   = wat.toStringAsFixed(0);
        _loading          = false;
      });
    } catch (e, st) {
      AppLogger.error('SettingsScreen', 'load failed', e, st);
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      final sp = SecurePrefs.instance;
      await sp.setString('user_name',
          _nameCtrl.text.trim());
      await sp.setDouble('goal_oxalate',
          double.tryParse(_oxalateCtrl.text) ?? 200);
      await sp.setDouble('goal_water',
          double.tryParse(_waterCtrl.text) ?? 80);
      // Store bool as string
      await sp.setString('notifications_on',
          _notifications ? 'true' : 'false');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved ✔')),
      );
    } catch (e, st) {
      AppLogger.error('SettingsScreen', 'save failed', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  Future<void> _pickAvatar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Avatar upload coming soon!')),
    );
  }

  Future<void> _resetConsent() async {
    await ConsentManager.instance.resetConsent();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Ad consent reset. Restart the app to see the consent form again.')),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _oxalateCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          backgroundColor: _bgColor,
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: _dark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings',
            style: TextStyle(
                color: Color(0xFF1A2530),
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    color: _teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Profile'),
              _card(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor:
                                _teal.withValues(alpha: 0.15),
                            child: const Icon(Icons.person_outline,
                                color: _teal, size: 36),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _teal,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _inputField(
                        label: 'Your Name',
                        controller: _nameCtrl,
                        hint: 'e.g. Alex'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Daily Goals'),
              _card(
                child: Column(
                  children: [
                    _inputField(
                        label: 'Oxalate Goal (mg/day)',
                        controller: _oxalateCtrl,
                        hint: '200',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                    const SizedBox(height: 14),
                    _inputField(
                        label: 'Water Goal (oz/day)',
                        controller: _waterCtrl,
                        hint: '80',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Notifications'),
              _card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Reminders',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _dark)),
                        SizedBox(height: 2),
                        Text('Hydration & log reminders',
                            style: TextStyle(
                                fontSize: 11, color: _muted)),
                      ],
                    ),
                    Switch.adaptive(
                      value: _notifications,
                      // Use activeThumbColor to avoid deprecated activeColor
                      activeThumbColor: _teal,
                      activeTrackColor: _teal.withValues(alpha: 0.4),
                      onChanged: (v) =>
                          setState(() => _notifications = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Privacy & Ads'),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ad Personalisation',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _dark)),
                        Text(
                          ConsentManager.instance.canShowAds
                              ? 'Granted'
                              : 'Not granted',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                ConsentManager.instance.canShowAds
                                    ? const Color(0xFF2E7D32)
                                    : _danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _resetConsent,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _danger,
                        side: const BorderSide(color: _danger),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reset Ad Consent',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _dark)),
      );

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: child,
      );

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _muted)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFFB0BEC5)),
              filled: true,
              fillColor: const Color(0xFFF4F8FA),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: _teal, width: 1.5),
              ),
            ),
          ),
        ],
      );
}
