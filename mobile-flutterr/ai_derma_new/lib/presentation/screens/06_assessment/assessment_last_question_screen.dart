// lib/presentation/screens/06_assessment/assessment_last_question_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/routes/app_router.dart';
import '../../../core/widgets/glass_header.dart';

class AssessmentLastQuestionScreen extends StatefulWidget {
  const AssessmentLastQuestionScreen({super.key});

  @override
  State<AssessmentLastQuestionScreen> createState() =>
      _AssessmentLastQuestionScreenState();
}

class _AssessmentLastQuestionScreenState
    extends State<AssessmentLastQuestionScreen> {
  String? _selectedAnswer;
  final int _currentStep = 8;
  final int _totalSteps = 8;

  void _handleSubmit() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to analyzing screen
    context.go(AppRouter.analyzing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GlassHeader(
        title: 'Symptom Assessment',
        onBackPressed: () => Navigator.pop(context),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryContainer.withOpacity(0.2),
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/100?img=1',
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar (100%)
          FadeInDown(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question $_currentStep of $_totalSteps',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '100% Complete',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: const LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation(AppColors.tertiary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Header
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.tertiary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.fact_check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FINAL STEP',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.tertiary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Almost done!',
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Question Text
                  FadeInLeft(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'How long have you had these symptoms?',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 28,
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Answer Options
                  ...[
                    _buildAnswerOption(
                      value: 'week',
                      title: 'Less than a week',
                      delay: 600,
                    ),
                    _buildAnswerOption(
                      value: '1-2weeks',
                      title: '1-2 weeks',
                      delay: 700,
                      isSelected: true, // Pre-selected for demo
                    ),
                    _buildAnswerOption(
                      value: '2-4weeks',
                      title: '2-4 weeks',
                      delay: 800,
                    ),
                    _buildAnswerOption(
                      value: 'month',
                      title: 'More than a month',
                      delay: 900,
                    ),
                  ].map((widget) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: widget,
                    );
                  }).toList(),

                  const SizedBox(height: 32),

                  // Medical Context
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.1),
                          width: 4,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEDICAL CONTEXT',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Persistent symptoms lasting longer than two weeks may require a different diagnostic pathway. Your history is securely encrypted.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          FadeInUp(
            delay: const Duration(milliseconds: 1100),
            child: _buildBottomActions(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANSWER OPTION
  // ============================================================
  Widget _buildAnswerOption({
    required String value,
    required String title,
    required int delay,
    bool isSelected = false,
  }) {
    if (_selectedAnswer == null && isSelected) {
      _selectedAnswer = value;
    }

    final selected = _selectedAnswer == value;

    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAnswer = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondary.withOpacity(0.05)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.secondary
                  : AppColors.outlineVariant.withOpacity(0.2),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? AppColors.secondary : AppColors.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? AppColors.secondary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.secondary
                        : AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTIONS
  // ============================================================
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Get Diagnosis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}