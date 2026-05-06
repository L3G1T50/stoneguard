import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'Education',
      body: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_outlined, size: 64, color: AppColors.teal),
              const SizedBox(height: 16),
              Text('Education Hub', style: AppTextStyles.screenTitleOf(context)),
              const SizedBox(height: 8),
              Text(
                'Articles and guides about kidney stone prevention are coming soon.',
                style: AppTextStyles.bodyOf(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
