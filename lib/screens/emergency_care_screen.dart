import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCareScreen extends StatelessWidget {
  const EmergencyCareScreen({super.key});

  static const Color bgColor     = Color(0xFFF8F8F8);
  static const Color cardColor   = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFD0D0D8);
  static const Color textColor   = Color(0xFF2C2C2C);
  static const Color mutedColor  = Color(0xFF888888);
  static const Color accentTeal  = Color(0xFF1A8A9A);

  Future<void> _callEmergency() async {
    final uri = Uri(scheme: 'tel', path: '911');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Widget _sectionHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 4, height: 20,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(text,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _symptomRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, color: textColor, height: 1.5)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8E8EC),
        elevation: 0,
        centerTitle: true,
        title: const Text('Emergency Care',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── CALL 911 BANNER ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFE53935).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.emergency, color: Colors.white, size: 36),
                const SizedBox(height: 8),
                const Text('If you are in severe pain or\nhave a fever with stone symptoms',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.5)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone, size: 20),
                    label: const Text('Call 911 Now',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE53935),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _callEmergency,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── GO TO ER IMMEDIATELY ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('🚨  Go to the ER Immediately',
                    const Color(0xFFE53935)),
                _symptomRow('🌡️',
                    'Fever (above 101°F / 38.3°C) combined with flank or back pain — this may signal a kidney infection, which is a medical emergency.'),
                _symptomRow('🚫',
                    'Complete inability to urinate — could mean a full urinary blockage.'),
                _symptomRow('🤮',
                    'Persistent vomiting that prevents you from keeping fluids down.'),
                _symptomRow('💉',
                    'Heavy blood in urine (bright red or large clots).'),
                _symptomRow('😰',
                    'Excruciating, uncontrolled pain that peaks and won\'t subside — especially with sweating, nausea, or dizziness.'),
                _symptomRow('🫀',
                    'Rapid heartbeat, confusion, or chills alongside any of the above.'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── SEE DOCTOR SOON ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFFA726).withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('⚠️  See Your Doctor Soon',
                    const Color(0xFFFFA726)),
                _symptomRow('🩸',
                    'Trace blood in urine (pink or light red) without severe pain.'),
                _symptomRow('😣',
                    'Mild to moderate flank, back, or lower abdominal pain that comes and goes.'),
                _symptomRow('🔁',
                    'A new stone episode — even if manageable, your urologist should know.'),
                _symptomRow('💊',
                    'Pain that requires regular over-the-counter medication to manage.'),
                _symptomRow('📉',
                    'Noticeably reduced urine output over several days without an obvious reason.'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── GOOD SIGNS ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('✅  Signs You\'re Managing Well',
                    const Color(0xFF66BB6A)),
                _symptomRow('💧',
                    'Pale yellow urine throughout the day — you\'re well hydrated.'),
                _symptomRow('📉',
                    'Pain is mild and manageable with normal movement and fluids.'),
                _symptomRow('🚽',
                    'Urinating regularly (every 2–4 hours) without burning or blockage.'),
                _symptomRow('🌡️',
                    'No fever — temperature is normal.'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── DISCLAIMER ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: const Text(
              '⚠️ StoneGuard is a tracking and educational tool only. '
                  'It is not a medical device and does not provide medical advice. '
                  'Always follow the guidance of your physician or urologist. '
                  'When in doubt, seek emergency care immediately.',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}