import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  double _waterGoal = 80;
  double _oxalateGoal = 200;

  static const Color teal = Color(0xFF0097A7);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color textDark = Color(0xFF263238);
  static const Color softBg = Color(0xFFF9FBFC);

  @override
  void initState() {
    super.initState();
    _loadExistingDefaults();
  }

  Future<void> _loadExistingDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _waterGoal = prefs.getDouble('goal_water') ?? 80;
      _oxalateGoal = prefs.getDouble('goal_oxalate') ?? 200;
    });
  }

  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setDouble('goal_water', _waterGoal);
    await prefs.setDouble('goal_oxalate', _oxalateGoal);
    await prefs.setBool('has_seen_onboarding', true);
    await prefs.setBool('has_completed_setup', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MyHomePage()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildValuePill({
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: textDark,
      ),
    );
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
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: teal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Step 2 of 2',
                        style: TextStyle(
                          color: teal,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 108,
                      width: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF7F9FB),
                            Color(0xFFE5EDF1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            size: 68,
                            color: Colors.grey.shade400,
                          ),
                          const Icon(
                            Icons.tune_rounded,
                            size: 28,
                            color: teal,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Set up your StoneGuard goals',
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
                      'Choose simple starting goals for water and oxalate. You can change them anytime later in Settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Your Name (optional)'),
                    const SizedBox(height: 6),
                    Text(
                      'This helps personalize your experience and doctor report.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter your first name',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: teal,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

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
                              height: 1.45,
                            ),
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
                        Text(
                          '32 oz',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          '160 oz',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

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
                              height: 1.45,
                            ),
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
                        Text(
                          '50 mg',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          '500 mg',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.10),
                  ),
                ),
                child: Text(
                  'These are starting goals only. StoneGuard is a self-tracking tool and does not replace medical advice.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue to StoneGuard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Your goals can always be updated later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}