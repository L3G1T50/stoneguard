import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class HistoryProgressScreen extends StatelessWidget {
  const HistoryProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final surfaceCol = isDark ? AppColors.darkSurface     : AppColors.surface;
    final borderCol  = isDark ? AppColors.darkBorder      : AppColors.border;
    final textPri    = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textMut    = isDark ? AppColors.darkTextSecond  : AppColors.textSecond;

    return GradientScaffold(
      title: 'Progress History',
      body: ListView(
        padding: AppSpacing.pagePadding.copyWith(top: 20, bottom: 32),
        children: [
          _SectionCard(
            isDark: isDark,
            surfaceCol: surfaceCol,
            borderCol: borderCol,
            textPri: textPri,
            textMut: textMut,
            title: 'Stone-Free Streak',
            icon: Icons.local_fire_department_outlined,
            iconColor: AppColors.warning,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Text('0', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppColors.warning)),
                    Text('days stone-free', style: TextStyle(fontSize: 14, color: textMut)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            isDark: isDark,
            surfaceCol: surfaceCol,
            borderCol: borderCol,
            textPri: textPri,
            textMut: textMut,
            title: 'Hydration Compliance',
            icon: Icons.water_drop_outlined,
            iconColor: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Log your daily water intake on the Home screen to see your 30-day compliance trend here.',
                style: TextStyle(fontSize: 13, height: 1.5, color: textMut),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            isDark: isDark,
            surfaceCol: surfaceCol,
            borderCol: borderCol,
            textPri: textPri,
            textMut: textMut,
            title: 'Pain Journal Summary',
            icon: Icons.bar_chart_outlined,
            iconColor: AppColors.oxalate,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Add journal entries to see average pain, highest pain day, and monthly trends.',
                style: TextStyle(fontSize: 13, height: 1.5, color: textMut),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final Color surfaceCol;
  final Color borderCol;
  final Color textPri;
  final Color textMut;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.isDark,
    required this.surfaceCol,
    required this.borderCol,
    required this.textPri,
    required this.textMut,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceCol,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPri)),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
