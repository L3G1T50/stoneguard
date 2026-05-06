import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import 'settings_screen.dart';

class EmergencyCareScreen extends StatelessWidget {
  const EmergencyCareScreen({super.key});

  // Colors resolved dynamically in build()

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? const Color(0xFF0F1419) : const Color(0xFFF8F8F8);
    final cardColor   = isDark ? const Color(0xFF1A2332) : const Color(0xFFFFFFFF);
    final borderColor = isDark ? const Color(0xFF2E4055) : const Color(0xFFD0D0D8);
    final textColor   = isDark ? const Color(0xFFE8EDF2) : const Color(0xFF2C2C2C);
    final mutedColor  = isDark ? const Color(0xFF8FA8BE) : const Color(0xFF888888);
    const accentTeal  = Color(0xFF1A8A9A);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2332) : const Color(0xFFE8E8EC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Emergency Care',
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _section(
            context,
            color: const Color(0xFFE53935),
            icon: Icons.warning_amber_rounded,
            title: 'Call 911 Immediately If:',
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            mutedColor: mutedColor,
            items: [
              '\u2022 Severe flank or back pain that is unbearable',
              '\u2022 High fever (above 101\u00B0F) with stone symptoms',
              '\u2022 Shaking, chills, or signs of sepsis',
              '\u2022 Complete inability to urinate',
              '\u2022 Vomiting so severe you cannot keep any fluids down',
            ],
          ),
          const SizedBox(height: 12),
          _section(
            context,
            color: const Color(0xFFE65100),
            icon: Icons.local_hospital_outlined,
            title: 'Go to the ER If:',
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            mutedColor: mutedColor,
            items: [
              '\u2022 Pain is severe and not controlled with OTC medication',
              '\u2022 Blood in urine with pain or fever',
              '\u2022 You have only one kidney and suspect a stone',
              '\u2022 Pain lasts more than 6 hours without relief',
              '\u2022 You are pregnant and experiencing stone symptoms',
            ],
          ),
          const SizedBox(height: 12),
          _section(
            context,
            color: accentTeal,
            icon: Icons.phone_outlined,
            title: 'Call Your Doctor If:',
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            mutedColor: mutedColor,
            items: [
              '\u2022 You have mild to moderate pain that is manageable',
              '\u2022 You have had stones before and recognize the symptoms',
              '\u2022 Blood in urine without fever or severe pain',
              '\u2022 You passed a stone and want it analyzed',
              '\u2022 Nausea with mild discomfort',
            ],
          ),
          const SizedBox(height: 12),
          _section(
            context,
            color: const Color(0xFF2E7D32),
            icon: Icons.home_outlined,
            title: 'You Can Wait and Monitor If:',
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            mutedColor: mutedColor,
            items: [
              '\u2022 Pain is mild and comes and goes',
              '\u2022 No fever, chills, or vomiting',
              '\u2022 You are able to drink fluids normally',
              '\u2022 You have passed stones before with similar symptoms',
              '\u2022 Pain responds to OTC pain relievers (ibuprofen/naproxen)',
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2332) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1A8A9A), size: 18),
                    const SizedBox(width: 8),
                    Text('Important Note',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textColor)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This guide is for general reference only. Always trust your instincts — '
                  'if something feels seriously wrong, seek medical attention immediately. '
                  'When in doubt, go to the ER.',
                  style: TextStyle(fontSize: 12, color: mutedColor, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color mutedColor,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(item,
                            style: TextStyle(
                                fontSize: 13.5,
                                color: textColor,
                                height: 1.45)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
