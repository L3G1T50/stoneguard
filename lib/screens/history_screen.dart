import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const GradientScaffold(
      title: 'Stone History',
      body: Center(child: Text('History coming soon')),
    );
  }
}
