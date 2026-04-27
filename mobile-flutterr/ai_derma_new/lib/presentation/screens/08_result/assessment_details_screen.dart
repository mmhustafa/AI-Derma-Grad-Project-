// lib/presentation/screens/08_result/assessment_details_screen.dart
//
// Displays the full result of a diagnostic session.
// Receives: { diagnosticResultId: int, disease: String } via GoRouter extra.
// Fetches:
//   GET /api/History/diagnostic/{id}    → symptom answers + metadata
//   GET /api/Diagnostic/disease-details → description + severity + care

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:al_derma/config/theme/app_colors.dart';
import 'package:al_derma/config/theme/app_text_styles.dart';
import 'package:al_derma/core/widgets/glass_header.dart';
import 'package:al_derma/core/services/api_service.dart';
import 'package:al_derma/core/models/history_model.dart';
import 'package:al_derma/core/models/diagnosis_model.dart';
import 'package:al_derma/config/routes/app_router.dart';

class AssessmentDetailsScreen extends StatefulWidget {
  final int? diagnosticResultId;
  final String? disease;

  const AssessmentDetailsScreen({
    super.key,
    this.diagnosticResultId,
    this.disease,
  });

  @override
  State<AssessmentDetailsScreen> createState() =>
      _AssessmentDetailsScreenState();
}

class _AssessmentDetailsScreenState extends State<AssessmentDetailsScreen> {
  DiagnosticDetail? _detail;
  DiseaseDetails? _diseaseDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = <Future>[
        if (widget.diagnosticResultId != null)
          ApiService.getHistoryDetail(widget.diagnosticResultId!),
        if (widget.disease != null && widget.disease!.isNotEmpty)
          ApiService.getDiseaseDetails(widget.disease!),
      ];

      final results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          int idx = 0;
          if (widget.diagnosticResultId != null) {
            _detail = results[idx] as DiagnosticDetail;
            idx++;
          }
          if (widget.disease != null && widget.disease!.isNotEmpty) {
            _diseaseDetails = results[idx] as DiseaseDetails;
          }
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
          _errorMessage = 'Failed to load results.';
          _isLoading = false;
        });
      }
    }
  }

  String get _diseaseName =>
      _diseaseDetails?.diseaseName ??
      _detail?.diseaseName ??
      widget.disease ??
      'Unknown Condition';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GlassHeader(
        title: 'Clinical Details',
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRouter.chat),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            color: AppColors.primary,
            tooltip: 'Ask AI Assistant',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Loading clinical data…',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded,
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
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Condition Summary Banner ──────────────────────────
          FadeInDown(child: _buildHeaderCard()),

          if (_diseaseDetails != null) ...[
            const SizedBox(height: 24),

            // ── 2. About Condition Card ──────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 120),
              child: _buildAboutConditionCard(
                _diseaseDetails!.diseaseName,
                _diseaseDetails!.description,
              ),
            ),

            const SizedBox(height: 16),

            // ── 3. Severity Card ─────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildSeverityCard(_diseaseDetails!.severityLevel),
            ),

            const SizedBox(height: 24),

            // ── 4. Care Instructions Section ─────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 280),
              child: _buildCareInstructionsSection(
                _diseaseDetails!.careInstructions,
              ),
            ),
          ],

          if (_detail != null && _detail!.symptomAnswers.isNotEmpty) ...[
            const SizedBox(height: 24),

            // ── 5. Symptom Answers ───────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 360),
              child: _buildAnswersSection(_detail!.symptomAnswers),
            ),
          ],

          const SizedBox(height: 40),
          Center(
            child: Opacity(
              opacity: 0.35,
              child: Text(
                'AL-DERMA CLINICAL PROTOCOL V1.0',
                style: AppTextStyles.caption.copyWith(letterSpacing: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HEADER BANNER
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'CONDITION SUMMARY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _diseaseName,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              _headerStat(Icons.biotech_rounded, 'AI Diagnosis'),
              const SizedBox(width: 20),
              _headerStat(Icons.verified_rounded, 'Clinically Reviewed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.85), size: 15),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // ABOUT CONDITION CARD
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildAboutConditionCard(String diseaseName, String description) {
    if (description.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'About $diseaseName',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Description body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SEVERITY CARD
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildSeverityCard(String severity) {
    final _SeverityStyle style = _resolveSeverity(severity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: style.color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: style.color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: style.color.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Severity Level',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  style.label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: style.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  style.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Colored severity dot indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: style.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: style.color.withOpacity(0.45),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _SeverityStyle _resolveSeverity(String severity) {
    switch (severity.toLowerCase().trim()) {
      case 'high':
      case 'severe':
        return _SeverityStyle(
          color: AppColors.error,
          icon: Icons.warning_amber_rounded,
          label: 'Severe',
          description: 'Seek medical attention promptly.',
        );
      case 'medium':
      case 'moderate':
        return _SeverityStyle(
          color: AppColors.warning,
          icon: Icons.info_rounded,
          label: 'Moderate',
          description: 'Monitor symptoms and consult a clinician.',
        );
      default:
        return _SeverityStyle(
          color: AppColors.tertiary,
          icon: Icons.check_circle_outline_rounded,
          label: 'Mild',
          description: 'Manageable with routine self-care.',
        );
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CARE INSTRUCTIONS SECTION
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCareInstructionsSection(String careInstructions) {
    // Split on period, filter empties, trim whitespace
    final instructions = careInstructions
        .split('.')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (instructions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: AppColors.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Care Instructions',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Instruction cards
        ...List.generate(instructions.length, (index) {
          return FadeInUp(
            delay: Duration(milliseconds: 80 * index),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInstructionCard(index + 1, instructions[index]),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInstructionCard(int number, String instruction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numbered circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Review this guidance with a clinician if needed.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant.withOpacity(0.75),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SYMPTOM ANSWERS SECTION
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildAnswersSection(List<SymptomAnswer> answers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.quiz_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Your Symptom Answers',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...answers.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildAnswerCard(a),
            )),
      ],
    );
  }

  Widget _buildAnswerCard(SymptomAnswer a) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 15,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.questionText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  a.userAnswer.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Internal helper model ────────────────────────────────────────────────────

class _SeverityStyle {
  final Color color;
  final IconData icon;
  final String label;
  final String description;

  const _SeverityStyle({
    required this.color,
    required this.icon,
    required this.label,
    required this.description,
  });
}
