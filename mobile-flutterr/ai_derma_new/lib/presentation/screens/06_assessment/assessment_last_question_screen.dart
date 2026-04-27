// lib/presentation/screens/06_assessment/assessment_last_question_screen.dart
//
// ⚠️ DEPRECATED — This screen is no longer used.
// The full diagnostic flow is now handled dynamically by AssessmentQuestionScreen.
// This file is kept only as a redirect stub to avoid compile errors during migration.
// It can be safely deleted once app_router.dart no longer references it.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_router.dart';

@Deprecated('Use AssessmentQuestionScreen instead')
class AssessmentLastQuestionScreen extends StatelessWidget {
  const AssessmentLastQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Immediately redirect to the dynamic assessment screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(AppRouter.assessment);
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}