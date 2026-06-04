// lib/presentation/screens/06_assessment/image_confirmation_screen.dart
//
// Screen for confirming symptoms after image-based AI diagnosis.
// Identical to React's ConfirmationQuestionsPage, but for image-based flow.
//
// Flow:
//   1. Load confirmation questions for the detected disease
//   2. Display Yes/No buttons for each question
//   3. User answers all questions (or clicks No to stop early)
//   4. Navigate to result screen with userConfirmedSymptoms flag

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/routes/app_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/metadata_model.dart';
import '../../../core/widgets/glass_header.dart';

class ImageConfirmationScreen extends StatefulWidget {
  final String disease;
  final double confidence;
  final int diagnosticResultId;
  final List top3;
  final dynamic
      imageFile; // Accept File or XFile for cross-platform compatibility

  const ImageConfirmationScreen({
    super.key,
    required this.disease,
    required this.confidence,
    required this.diagnosticResultId,
    this.top3 = const [],
    this.imageFile,
  });

  @override
  State<ImageConfirmationScreen> createState() =>
      _ImageConfirmationScreenState();
}

class _ImageConfirmationScreenState extends State<ImageConfirmationScreen> {
  List<ConfirmationQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isNavigating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfirmationQuestions();
  }

  Future<void> _loadConfirmationQuestions() async {
    try {
      final response =
          await ApiService.getConfirmationQuestions(widget.disease);
      if (!mounted) return;

      setState(() {
        _questions = response.questions;
        _isLoading = false;
        if (_questions.isEmpty) {
          _errorMessage = 'No confirmation questions available.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleYes() async {
    if (_currentQuestionIndex + 1 < _questions.length) {
      // Move to next question
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // All questions answered YES — user confirmed symptoms
      await _navigateToResult(userConfirmedSymptoms: true);
    }
  }

  Future<void> _handleNo() async {
    // User clicked NO — symptoms not confirmed
    await _navigateToResult(userConfirmedSymptoms: false);
  }

  Future<void> _navigateToResult({required bool userConfirmedSymptoms}) async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      if (!mounted) return;

      context.push(
        AppRouter.aiResult,
        extra: {
          'disease': widget.disease,
          'confidence': widget.confidence,
          'diagnosticResultId': widget.diagnosticResultId,
          'top3': widget.top3,
          'source': 'ai',
          'userConfirmedSymptoms': userConfirmedSymptoms,
          'imageFile': widget.imageFile,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isNavigating = false;
        _errorMessage = 'Failed to navigate: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GlassHeader(
        title: 'Confirm Symptoms',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading confirmation questions...',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Error state
    if (_errorMessage != null || _questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'No confirmation questions available',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.home),
              child: const Text('Go Back Home'),
            ),
          ],
        ),
      );
    }

    // Questions state
    final currentQuestion = _questions[_currentQuestionIndex];
    final progressPercent =
        ((_currentQuestionIndex + 1) / _questions.length) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // Header
          FadeInDown(
            child: Column(
              children: [
                Text(
                  'Symptom Verification',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Confirm Your Symptoms',
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please answer the following questions to confirm the diagnosis for ${widget.disease}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Confidence Display
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'AI Confidence',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(widget.confidence * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: widget.confidence,
                    backgroundColor: AppColors.outlineVariant.withOpacity(0.2),
                    color: AppColors.primary,
                    minHeight: 4,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Progress Bar
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      style: AppTextStyles.labelMedium,
                    ),
                    Text(
                      '${progressPercent.toStringAsFixed(0)}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _currentQuestionIndex / _questions.length,
                  backgroundColor: AppColors.outlineVariant.withOpacity(0.2),
                  color: AppColors.primary,
                  minHeight: 6,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Question Card
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    currentQuestion.text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Yes/No Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isNavigating ? null : _handleNo,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: AppColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'No',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isNavigating ? null : _handleYes,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isNavigating
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Yes',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
