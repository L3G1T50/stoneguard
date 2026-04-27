import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About StoneGuard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shield,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'StoneGuard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Built by a survivor, for survivors.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              context,
              icon: Icons.person,
              title: 'My Story',
              content:
              'My journey with kidney stones began at just 10 years old — '
                  'a 10/10 pain emergency that landed me in the hospital in the middle of the night. '
                  'Over the years, I\'ve faced this battle 11 times and counting. '
                  'Each stone has reinforced how important it is to stay on top of hydration and diet every single day. '
                  'It\'s not just a health goal for me — it\'s a necessity.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              icon: Icons.lightbulb,
              title: 'Why I Built This App',
              content:
              'I tried other apps, but I couldn\'t find a single one built specifically for kidney stone sufferers. '
                  'It\'s hard to remember exactly what foods to eat or avoid every day, '
                  'and to stay consistent with drinking enough water. '
                  'That gap encouraged me to build something custom — '
                  'a one-of-a-kind kidney stone app that benefits not just myself, but everyone who deals with stones.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              icon: Icons.favorite,
              title: 'What StoneGuard Is For',
              content:
              'StoneGuard is designed to be simple enough to use every day, '
                  'while being powerful enough to give you the bigger picture. '
                  'It tracks your hydration, monitors your oxalate intake, and helps you understand '
                  'where you\'re doing well and where you can improve.\n\n'
                  'That real data can even help you have more informed conversations '
                  'with your doctor or specialist about your specific kidney stone situation. '
                  'Knowledge is prevention — and StoneGuard puts that knowledge in your hands.',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.format_quote,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '"Wondering if you\'re on track? With StoneGuard, you\'ll know for sure."',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required IconData icon,
        required String title,
        required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }
}