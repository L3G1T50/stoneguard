import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'home_shield_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController  = TextEditingController();
  double _waterGoal    = 80;
  double _oxalateGoal  = 200;
  String? _avatarPath;
  String _stoneType = 'Unknown / Not diagnosed';

  static const Color teal     = Color(0xFF0097A7);
  static const Color purple   = Color(0xFF7B1FA2);
  static const Color textDark = Color(0xFF263238);
  static const Color softBg   = Color(0xFFF9FBFC);

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
    _loadExistingDefaults();
  }

  Future<void> _loadExistingDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text = prefs.getString('user_name')    ?? '';
      _ageController.text  = (prefs.getInt('user_age') ?? 0) == 0
          ? '' : '${prefs.getInt('user_age')}' ;
      _waterGoal    = prefs.getDouble('goal_water')    ?? 80;
      _oxalateGoal  = prefs.getDouble('goal_oxalate')  ?? 200;
      _avatarPath   = prefs.getString('avatar_path');
      _stoneType    = prefs.getString('stone_type') ?? 'Unknown / Not diagnosed';
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _avatarPath = picked.path);
    }
  }

  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name',    _nameController.text.trim());
    await prefs.setDouble('goal_water',   _waterGoal);
    await prefs.setDouble('goal_oxalate', _oxalateGoal);
    await prefs.setString('stone_type',   _stoneType);
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    await prefs.setInt('user_age', age);
    if (_avatarPath != null) {
      await prefs.setString('avatar_path', _avatarPath!);
    }
    await prefs.setBool('has_seen_onboarding', true);
    await prefs.setBool('has_completed_setup',  true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShieldScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Widget _buildValuePill({required String text, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
      child: Text(text,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 15, color: textDark));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Step 2 of 2',
                          style: TextStyle(
                              color: teal, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(height: 18),

                    // ── Avatar picker ───────────────────────────────────
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 108,
                            width: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: _avatarPath == null
                                  ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFF7F9FB), Color(0xFFE5EDF1)],
                              )
                                  : null,
                              color: _avatarPath != null ? Colors.transparent : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _avatarPath != null
                                  ? Image.file(
                                File(_avatarPath!),
                                fit: BoxFit.cover,
                                width: 108,
                                height: 108,
                              )
                                  : Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.shield_rounded,
                                      size: 68,
                                      color: Colors.grey.shade400),
                                  const Icon(Icons.person_outline_rounded,
                                      size: 32, color: teal),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: teal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      _avatarPath != null ? 'Tap to change photo' : 'Tap to add a photo',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Set up your StoneGuard profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tell us a little about yourself and choose your starting goals. You can change everything anytime in Settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey.shade600, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Profile + Goals card ────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Name ──
                    _buildSectionTitle('Your Name (optional)'),
                    const SizedBox(height: 6),
                    Text(
                      'Personalises your experience and doctor reports.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter your first name',
                        prefixIcon: const Icon(Icons.person_outline, color: teal),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Age ──
                    _buildSectionTitle('Your Age (optional)'),
                    const SizedBox(height: 6),
                    Text(
                      'Helps contextualise your health data in doctor reports.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'e.g. 35',
                        prefixIcon: const Icon(Icons.cake_outlined, color: teal),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Stone Type ──
                    _buildSectionTitle('Kidney Stone Type (optional)'),
                    const SizedBox(height: 6),
                    Text(
                      'Used to tailor tips and your doctor report. Select the type your doctor identified, or choose Unknown.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _stoneType,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: teal),
                          items: _stoneTypes
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t,
                                        style: const TextStyle(fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _stoneType = v);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 20),

                    // ── Water Goal ──
                    _buildSectionTitle('Daily Water Goal'),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Good hydration supports kidney health and may help lower stone risk.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.45),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildValuePill(
                          text: '${_waterGoal.toInt()} oz',
                          color: teal,
                          bgColor: teal.withValues(alpha: 0.10),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 9),
                        overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 18),
                      ),
                      child: Slider(
                        value: _waterGoal,
                        min: 32,
                        max: 160,
                        divisions: 16,
                        activeColor: teal,
                        inactiveColor: teal.withValues(alpha: 0.15),
                        onChanged: (v) =>
                            setState(() => _waterGoal = v.roundToDouble()),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('32 oz',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                        Text('160 oz',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ── Oxalate Goal ──
                    _buildSectionTitle('Daily Oxalate Limit'),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'This is a starting limit. If your doctor gave you a different goal, follow their advice.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.45),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildValuePill(
                          text: '${_oxalateGoal.toInt()} mg',
                          color: purple,
                          bgColor: purple.withValues(alpha: 0.10),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 9),
                        overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 18),
                      ),
                      child: Slider(
                        value: _oxalateGoal,
                        min: 50,
                        max: 500,
                        divisions: 18,
                        activeColor: purple,
                        inactiveColor: purple.withValues(alpha: 0.15),
                        onChanged: (v) =>
                            setState(() => _oxalateGoal = v.roundToDouble()),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('50 mg',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                        Text('500 mg',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Disclaimer ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
                ),
                child: Text(
                  'These are starting goals only. StoneGuard is a self-tracking tool and does not replace medical advice.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700, height: 1.45),
                ),
              ),

              const SizedBox(height: 24),

              // ── Continue button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _completeSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Continue to StoneGuard',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Your profile and goals can always be updated later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
