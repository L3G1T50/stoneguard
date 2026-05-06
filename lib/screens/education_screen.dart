import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const GradientScaffold(
      title: 'Education',
      body: Center(child: Text('Education coming soon')),
    );
  }
}
