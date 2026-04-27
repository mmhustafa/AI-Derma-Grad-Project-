// lib/presentation/screens/06_assessment/assessment_question_screen.dart
//
// This screen drives the ENTIRE dynamic diagnostic Q&A loop.
// It replaces both the old assessment_question_screen and assessment_last_question_screen.
//
// Flow:
//   1. initState  → call POST /api/Diagnostic/next-step with facts = []
//   2. If response.type == "question" → render question + options
//   3. On answer selected + "Next" tapped  → append fact, call API again
//   4. If response.type == "diagnosis"   → save answers, navigate to result

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/routes/app_router.dart';
import '../../../core/widgets/glass_header.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/diagnosis_model.dart';
import '../../../core/models/metadata_model.dart';

class AssessmentQuestionScreen extends StatefulWidget {
  const AssessmentQuestionScreen({super.key});

  @override
  State<AssessmentQuestionScreen> createState() =>
      _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen> {
  // ─── State ────────────────────────────────────────────────────────────────────

  final List<String> _facts = [];
  final List<_AnsweredQuestion> _answeredQuestions = [];

  KnowledgeBaseMetadata? _metadata;
  DiagnosisResponse? _currentResponse;
  String? _selectedOptionVal; // Store option.val (what to send to backend)
  String? _selectedOptionLabel; // Store option.label (what user selected)
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  int _stepNumber = 0;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initializeFlow();
  }

  /// Initialize the diagnostic flow by first loading metadata, then fetching the first question.
  Future<void> _initializeFlow() async {
    try {
      // Fetch knowledge base metadata first
      final metadata = await ApiService.getKnowledgeBaseMetadata();
      setState(() {
        _metadata = metadata;
      });

      // Then fetch the first diagnostic step
      await _fetchNextStep();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // ─── API Calls ───────────────────────────────────────────────────────────────

  Future<void> _fetchNextStep() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedOptionVal = null;
      _selectedOptionLabel = null;
    });

    try {
      final response = await ApiService.getNextStep(
        facts: _facts,
        diagnosticResultId: _currentResponse?.diagnosticResultId,
      );

      if (!mounted) return;

      if (response.type == 'diagnosis') {
        // We have a result — save answers then navigate
        await _handleDiagnosis(response);
      } else {
        setState(() {
          _currentResponse = response;
          _stepNumber++;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDiagnosis(DiagnosisResponse response) async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      // Save all symptom answers to the backend
      if (_answeredQuestions.isNotEmpty) {
        final saveRequest = SaveAnswersRequest(
          diagnosticResultId: response.diagnosticResultId,
          answers: _answeredQuestions
              .map((q) => SaveAnswerItem(
                    questionText: q.questionText,
                    answer: q.answer,
                  ))
              .toList(),
        );
        await ApiService.saveAnswers(saveRequest);
      }

      if (mounted) {
        // Navigate to result screen — pass data via GoRouter extra
        context.go(
          AppRouter.assessmentDetails,
          extra: {
            'diagnosticResultId': response.diagnosticResultId,
            'disease': response.disease ?? 'Unknown',
          },
        );
      }
    } on ApiException catch (e) {
      // Even if save fails, still navigate to the result
      if (mounted) {
        context.go(
          AppRouter.assessmentDetails,
          extra: {
            'diagnosticResultId': response.diagnosticResultId,
            'disease': response.disease ?? 'Unknown',
          },
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleNext() {
    if (_selectedOptionVal == null || _selectedOptionLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an answer'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final response = _currentResponse!;
    final questionCode = response.questionCode ?? '';
    final questionText = response.questionData?.text ?? questionCode;

    // ✅ CRITICAL: Append the OPTION VAL (e.g., "type:0-1"), NOT the label
    _facts.add(_selectedOptionVal!);

    // Remember the label for display in save-answers call later
    _answeredQuestions.add(_AnsweredQuestion(
      questionText: questionText,
      answer: _selectedOptionLabel!,
    ));

    _fetchNextStep();
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GlassHeader(
        title: 'Symptom Assessment',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSaving) {
      return _buildSavingOverlay();
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final response = _currentResponse;
    if (response == null) return const SizedBox.shrink();

    final question = response.questionData;
    final options = question?.options ?? _defaultOptions();

    return Column(
      children: [
        // Progress Bar — no key needed, always present
        FadeInDown(child: _buildProgressBar()),

        // Question Content
        // AnimatedSwitcher replaces the entire question+options subtree
        // cleanly when _stepNumber changes, avoiding any key collision
        // between the outgoing and incoming question's option widgets.
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            // Key the switcher child on step so it knows when to swap
            child: SingleChildScrollView(
              key: ValueKey<int>(_stepNumber),
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step badge
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: _buildStepBadge(),
                  ),
                  const SizedBox(height: 32),

                  // Question Text
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      question?.text.isNotEmpty == true
                          ? question!.text
                          : response.questionCode ?? 'Please answer:',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 26,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ─── Answer Options ──────────────────────────────────────
                  // _OptionsGroup is a dedicated widget so Flutter can
                  // compare its key and fully dispose the old subtree
                  // before mounting the new one — zero risk of duplicate keys.
                  _OptionsGroup(
                    // Composite key = step + questionCode.
                    // This is globally unique for the entire screen lifetime.
                    questionKey:
                        '${_stepNumber}_${response.questionCode ?? "q"}',
                    options: options,
                    selectedOptionVal: _selectedOptionVal,
                    onSelectOption: (val, label) {
                      setState(() {
                        _selectedOptionVal = val;
                        _selectedOptionLabel = label;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Actions
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: _buildBottomActions(),
        ),
      ],
    );
  }

  // ─── Sub-widgets ─────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Loading question...',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Processing your diagnosis...',
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 72, color: AppColors.outlineVariant.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _fetchNextStep,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $_stepNumber',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              Text(
                '${_facts.length} answered',
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
            child: LinearProgressIndicator(
              value: _stepNumber > 1 ? (_facts.length / _stepNumber) : 0,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryContainer.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.help_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP $_stepNumber',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Symptom Identification',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _stepNumber <= 1
                    ? () => Navigator.pop(context)
                    : null, // Can't go back once flow starts
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999)),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback options when the API doesn't return options.
  List<QuestionOption> _defaultOptions() => [
        QuestionOption(value: 'yes', label: 'Yes'),
        QuestionOption(value: 'no', label: 'No'),
      ];
}

// ─── _OptionsGroup ────────────────────────────────────────────────────────────
//
// Owns the full list of answer-option tiles for ONE question.
//
// KEY STRATEGY:
//   The parent AnimatedSwitcher uses ValueKey<int>(_stepNumber) on its child,
//   so the entire subtree (including this widget) is fully unmounted and
//   remounted on every question change.
//
//   Inside _OptionsGroup, each Padding uses:
//     ValueKey('${questionKey}_${option.value}')
//   where questionKey = '${stepNumber}_${questionCode}'.
//
//   This composite key is GLOBALLY UNIQUE across the entire screen lifetime,
//   even when every question returns options with the same values ('yes'/'no').
//   Flutter never sees two widgets with the same key in the same tree frame.

class _OptionsGroup extends StatelessWidget {
  final String questionKey;
  final List<QuestionOption> options;
  final String? selectedOptionVal; // option.val (what to send to backend)
  final Function(String val, String label)
      onSelectOption; // Callback with both val and label

  const _OptionsGroup({
    required this.questionKey,
    required this.options,
    required this.selectedOptionVal,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];

        // ── CRITICAL FIX ──────────────────────────────────────────────────────────
        // Always include the LIST INDEX in the key.
        // If the API returns options with empty/missing 'value' fields
        // (e.g. the 'Main Menu' question), all options would get the same
        // key without the index, causing the duplicate-key Flutter error.
        //
        // Format: '${step}_${questionCode}_${index}_${optionValue}'
        // This is GLOBALLY UNIQUE regardless of what the API returns.
        final uniqueKey =
            ValueKey<String>('${questionKey}_${index}_${option.value}');

        // Use option.value as the selection identity.
        // This keeps selection logic working consistently.
        final selectionId = option.value.isNotEmpty ? option.value : '$index';

        return Padding(
          key: uniqueKey,
          padding: const EdgeInsets.only(bottom: 16),
          child: _AnswerOptionTile(
            option: option,
            isSelected: selectedOptionVal == selectionId,
            onTap: () => onSelectOption(selectionId, option.label),
          ),
        );
      }),
    );
  }
}

// ─── _AnswerOptionTile ────────────────────────────────────────────────────────
//
// A single answer option tile.
// Fully stateless — selection state lives in _AssessmentQuestionScreenState,
// passed down as [isSelected]. No mutable state here means no risk of stale
// selection carrying over between questions.

class _AnswerOptionTile extends StatelessWidget {
  final QuestionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.05)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary.withOpacity(0.4)
                : AppColors.outlineVariant.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                style: AppTextStyles.titleLarge.copyWith(
                  color: isSelected ? AppColors.secondary : AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _AnsweredQuestion ────────────────────────────────────────────────────────

class _AnsweredQuestion {
  final String questionText;
  final String answer;
  _AnsweredQuestion({required this.questionText, required this.answer});
}
