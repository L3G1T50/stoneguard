// ─── SETUP (ONBOARDING) SCREEN ─────────────────────────────────
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
  double _waterGoal = 80;   // default oz – matches Settings default
  double _oxalateGoal = 200; // default mg – matches Settings default

  @override
  void initState() {
    super.initState();
    _loadExistingDefaults();
  }

  Future<void> _loadExistingDefaults() async {
    final prefs = await SharedPreferences.getInstance();
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
    await prefs.setBool('seen_onboarding', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Welcome to StoneGuard 🛡️',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Let’s set up a few basics to help protect you from kidney stones.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Name
              const Text(
                'Your Name (optional)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Water goal
              const Text(
                'Daily Water Goal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('More water helps protect your kidneys.',
                      style: TextStyle(fontSize: 12)),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_waterGoal.toInt()} oz',
                      style: const TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _waterGoal,
                min: 32,
                max: 160,
                divisions: 16,
                activeColor: Colors.teal,
                inactiveColor: Colors.teal.withValues(alpha: 0.15),
                onChanged: (v) => setState(() => _waterGoal = v.roundToDouble()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('32 oz',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                  Text('160 oz',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),

              const SizedBox(height: 24),

              // Oxalate limit
              const Text(
                'Daily Oxalate Limit',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Keeping oxalate in a safe range may help reduce stone risk.\n'
                          'Follow your doctor’s specific advice.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B1FA2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_oxalateGoal.toInt()} mg',
                      style: const TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _oxalateGoal,
                min: 50,
                max: 500,
                divisions: 18,
                activeColor: const Color(0xFF7B1FA2),
                inactiveColor:
                const Color(0xFF7B1FA2).withValues(alpha: 0.15),
                onChanged: (v) =>
                    setState(() => _oxalateGoal = v.roundToDouble()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('50 mg',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                  Text('500 mg',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue to StoneGuard',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'You can always change these later in Settings.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}