import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navBg,
        elevation: 0,
        title: const Text('History', style: AppTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 72, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('No history yet', style: AppTextStyles.itemTitle),
            SizedBox(height: 8),
            Text(
              'Your logged entries will appear here.',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}