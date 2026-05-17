// setup_screen.dart
//
// SecurePrefs has no setBool — store bool as string 'true'/'false'.
import 'package:flutter/material.dart';
import '../secure_prefs.dart';
import '../app_logger.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  static const Color _teal  = Color(0xFF1A8A9A);
  static const Color _dark  = Color(0xFF1A2530);
  static const Color _muted = Color(0xFF607D8B);

  final _nameCtrl = TextEditingController();
  bool _saving    = false;

  Future<void> _pickAvatar() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Avatar upload coming soon!')),
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      final sp = SecurePrefs.instance;
      await sp.setString('user_name', _nameCtrl.text.trim());
      // SecurePrefs has no setBool — store as string
      await sp.setString('onboarding_complete', 'true');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e, st) {
      AppLogger.error('SetupScreen', 'finish failed', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Setup failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined,
                    color: _teal, size: 30),
              ),
              const SizedBox(height: 24),
              const Text('Welcome to StoneGuard',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _dark)),
              const SizedBox(height: 8),
              const Text("Let's personalise your experience.",
                  style: TextStyle(fontSize: 14, color: _muted)),
              const SizedBox(height: 32),
              const Text('What should we call you?',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _dark)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle:
                      const TextStyle(color: Color(0xFFB0BEC5)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _teal, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickAvatar,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: _teal.withValues(alpha: 0.12),
                      child: const Icon(Icons.person_outline,
                          color: _teal, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add a profile photo',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _dark)),
                        Text('Optional · coming soon',
                            style: TextStyle(
                                fontSize: 11,
                                color: _muted.withValues(alpha: 0.7))),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Get Started',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
