import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:al_derma/config/theme/app_colors.dart';
import 'package:al_derma/config/theme/app_text_styles.dart';
import 'package:al_derma/config/routes/app_router.dart';
import 'package:al_derma/core/widgets/glass_header.dart';
import 'package:al_derma/core/services/api_service.dart';
import 'package:al_derma/core/models/diagnosis_model.dart';
import 'package:al_derma/core/models/chat_model.dart';

class AIResultScreen extends StatefulWidget {
  final String disease;
  final double confidence;
  final int diagnosticResultId;
  final List top3;
  final dynamic imageFile; // Accept File or XFile for cross-platform compatibility
  final bool? userConfirmedSymptoms;
  final String source; // 'ai' or 'expert'

  const AIResultScreen({
    super.key,
    required this.disease,
    required this.confidence,
    required this.diagnosticResultId,
    this.top3 = const [],
    this.imageFile,
    this.userConfirmedSymptoms,
    this.source = 'ai',
  });

  @override
  State<AIResultScreen> createState() => _AIResultScreenState();
}

class _AIResultScreenState extends State<AIResultScreen>
    with SingleTickerProviderStateMixin {
  DiseaseDetails? _diseaseDetails;
  bool _isLoadingDetails = true;
  String? _errorMessage;

  late AnimationController _barController;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();

    // Animate the confidence progress bar on entry
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _barAnimation = Tween<double>(begin: 0.0, end: widget.confidence).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic),
    );
    _barController.forward();

    _loadDiseaseDetails();
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  Future<void> _loadDiseaseDetails() async {
    try {
      final details = await ApiService.getDiseaseDetails(widget.disease);
      if (!mounted) return;
      setState(() {
        _diseaseDetails = details;
        _isLoadingDetails = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoadingDetails = false;
      });
    }
  }

  // ─── Confidence helpers ──────────────────────────────────────────────────────
  Color get _confidenceColor {
    if (widget.confidence >= 0.85) return AppColors.tertiary;
    if (widget.confidence >= 0.65) return AppColors.warning;
    return AppColors.error;
  }

  Color get _confidenceTrackColor {
    if (widget.confidence >= 0.85) return AppColors.tertiary.withOpacity(0.15);
    if (widget.confidence >= 0.65) return AppColors.warning.withOpacity(0.15);
    return AppColors.error.withOpacity(0.15);
  }

  String get _confidenceLabel {
    if (widget.confidence >= 0.85) return 'High Confidence';
    if (widget.confidence >= 0.65) return 'Moderate Confidence';
    return 'Low Confidence';
  }

  // ─── Open Chat Bottom Sheet ──────────────────────────────────────────────────
  void _openChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetCtx) => _ChatBottomSheet(condition: widget.disease),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GlassHeader(
        title: 'Analysis Result',
        onBackPressed: () => context.go(AppRouter.home),
      ),
      // ── Floating Chat Button ──────────────────────────────────────────────────
      floatingActionButton: _buildChatFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Uploaded Image ──────────────────────────────────────────────
            if (widget.imageFile != null) ...[
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: _buildImageCard(),
              ),
              const SizedBox(height: 20),
            ],

            // ── 2. Confidence Progress Bar (PROMINENT) ─────────────────────────
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 80),
              child: _buildConfidenceBar(),
            ),

            const SizedBox(height: 16),

            // ── 3. Diagnosis Card ──────────────────────────────────────────────
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 160),
              child: _buildDiagnosisCard(),
            ),

            const SizedBox(height: 16),

            // ── 4. Warning Banner ──────────────────────────────────────────────
            if (widget.userConfirmedSymptoms == false) ...[
              FadeInUp(
                delay: const Duration(milliseconds: 220),
                child: _buildWarningBanner(),
              ),
              const SizedBox(height: 16),
            ],

            // ── 5. Recommendations ─────────────────────────────────────────────
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 280),
              child: _buildRecommendationsSection(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // FLOATING CHAT BUTTON
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildChatFAB() {
    return FloatingActionButton(
      onPressed: _openChatSheet,
      backgroundColor: AppColors.primary,
      elevation: 6,
      tooltip: 'Ask Chat',
      child: const Icon(
        Icons.chat_bubble_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 1 · Uploaded Image Card
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildImageCard() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWidget(),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.45),
                    ],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
            ),
            // Label
            Positioned(
              bottom: 14,
              left: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image_search_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Analyzed Image',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (widget.imageFile == null) return const SizedBox();

    if (widget.imageFile is XFile) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: (widget.imageFile as XFile).readAsBytes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return _imagePlaceholder();
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          },
        );
      } else {
        return Image.file(
          File((widget.imageFile as XFile).path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _imagePlaceholder(),
        );
      }
    } else if (widget.imageFile is File) {
      return Image.file(
        widget.imageFile as File,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          size: 48,
          color: AppColors.outlineVariant,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 2 · Confidence Progress Bar  (PROMINENT — shown first)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildConfidenceBar() {
    final pct = (widget.confidence * 100).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: _confidenceColor.withOpacity(0.18),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _confidenceColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: _confidenceColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Confidence Score',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _confidenceLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _confidenceColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.disease,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Big percentage display
              AnimatedBuilder(
                animation: _barAnimation,
                builder: (context, _) {
                  final animPct =
                      (_barAnimation.value * 100).toStringAsFixed(1);
                  return Text(
                    '$animPct%',
                    style: AppTextStyles.numberLarge.copyWith(
                      color: _confidenceColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Animated bar ────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: _confidenceTrackColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: _barAnimation.value.clamp(0.0, 1.0),
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _confidenceColor.withOpacity(0.7),
                            _confidenceColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: _confidenceColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // ── Scale ticks ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['0%', '25%', '50%', '75%', '100%']
                .map(
                  (label) => Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.outline.withOpacity(0.7),
                      letterSpacing: 0,
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // ── Status note ─────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                widget.confidence >= 0.90
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                size: 16,
                color: _confidenceColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.confidence >= 0.90
                      ? 'High Confidence Prediction — sufficient for clinical screening.'
                      : 'Moderate/Low confidence — further evaluation may be recommended.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ── Boost Confidence banner + button ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Want to increase your confidence level even further? Answer a few additional confirmation questions.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      AppRouter.imageConfirmation,
                      extra: {
                        'disease': widget.disease,
                        'confidence': widget.confidence,
                        'diagnosticResultId': widget.diagnosticResultId,
                        'top3': widget.top3,
                        'imageFile': widget.imageFile,
                      },
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.fact_check_rounded, size: 17),
                    label: Text(
                      'Answer Confirmation Questions',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 3 · Diagnosis Card
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildDiagnosisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.biotech_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'About ${widget.disease}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              // Source badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.source == 'expert' ? 'Expert System' : 'Verified AI',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Disease name
          Text(
            widget.disease,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          if (widget.userConfirmedSymptoms == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 13,
                    color: AppColors.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Symptoms Confirmed',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Description
          Text(
            _diseaseDetails?.description ??
                'Our AI engine has detected signs highly consistent with ${widget.disease}. '
                    'This is a clinical screening tool, not a final diagnosis.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 4 · Warning Banner
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'User answers do not fully match the AI prediction. Further clinical evaluation may be required.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SECTION 5 · Recommendations
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRecommendationsSection() {
    if (_isLoadingDetails) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_diseaseDetails == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.tertiary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Recommendations',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Severity pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: AppColors.tertiaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'Severity: ${_diseaseDetails!.severityLevel}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),

          // Care instruction items
          ..._buildCareInstructions(_diseaseDetails!.careInstructions),
        ],
      ),
    );
  }

  List<Widget> _buildCareInstructions(String instructions) {
    final items = instructions
        .split('.')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return items.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Numbered circle
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 1, right: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${entry.key + 1}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tapping this now opens the chat bottom sheet
                  GestureDetector(
                    onTap: _openChatSheet,
                    child: Text(
                      'Review this guidance with a clinician if needed.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHAT BOTTOM SHEET  —  full embedded chat UI, no navigation
// ═══════════════════════════════════════════════════════════════════════════════

class _ChatBottomSheet extends StatefulWidget {
  final String? condition;
  const _ChatBottomSheet({this.condition});

  @override
  State<_ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<_ChatBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  String? _sessionId;
  bool _isTyping = false;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── API calls ───────────────────────────────────────────────────────────────

  Future<void> _initChat() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });
    try {
      final welcome = await ApiService.getChatWelcome();
      if (!mounted) return;
      setState(() {
        _sessionId = welcome.sessionId;
        _messages.add(_ChatMessage(
          text: welcome.reply,
          isUser: false,
          time: DateTime.now(),
        ));
        _isInitializing = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isInitializing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not connect to the AI assistant.';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sessionId == null) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isUser: true,
        time: DateTime.now(),
      ));
      _isTyping = true;
      _errorMessage = null;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final request = ChatRequest(
        sessionId: _sessionId!,
        message: text,
        condition: widget.condition ?? '',
      );
      final response = await ApiService.sendChatMessage(request);
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: response.reply,
            isUser: false,
            time: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Sorry, I could not process your request. ${e.message}',
            isUser: false,
            time: DateTime.now(),
            isError: true,
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'An unexpected error occurred. Please try again.',
            isUser: false,
            time: DateTime.now(),
            isError: true,
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Drag handle ───────────────────────────────────────────────────
          _buildDragHandle(),

          // ── Sheet header ──────────────────────────────────────────────────
          _buildSheetHeader(context),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: _isInitializing
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : (_errorMessage != null && _messages.isEmpty)
                    ? _buildInitError()
                    : Column(
                        children: [
                          Expanded(child: _buildMessagesList()),
                          if (_isTyping) _buildTypingIndicator(),
                          _buildInputArea(context),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.outlineVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Title & status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinical Assistant',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _sessionId != null
                            ? AppColors.tertiary
                            : AppColors.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _sessionId != null ? 'Connected' : 'Connecting...',
                      style: AppTextStyles.caption.copyWith(
                        color: _sessionId != null
                            ? AppColors.tertiary
                            : AppColors.outline,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.outline,
            iconSize: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildInitError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AppColors.outlineVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _initChat,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reconnect'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      itemCount: _messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'Today, ${DateFormat('MMM d').format(DateTime.now())}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.outline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }
        final msg = _messages[index - 1];
        return FadeInUp(
          delay: Duration(milliseconds: 40 * index),
          child: msg.isUser ? _buildUserBubble(msg) : _buildAIBubble(msg),
        );
      },
    );
  }

  Widget _buildAIBubble(_ChatMessage msg) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            decoration: BoxDecoration(
              color: msg.isError
                  ? AppColors.error.withOpacity(0.08)
                  : AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: msg.isError
                  ? Border.all(color: AppColors.error.withOpacity(0.2))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: msg.isError ? AppColors.error : AppColors.onSurface,
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Text(
              '${DateFormat('hh:mm a').format(msg.time)} · AI Assistant',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.outline, letterSpacing: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBubble(_ChatMessage msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryContainer, AppColors.primary],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26006874),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 14),
            child: Text(
              DateFormat('hh:mm a').format(msg.time),
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.outline, letterSpacing: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, _) {
                  final delay = i * 0.2;
                  final v = ((value - delay) * 2).clamp(0.0, 1.0);
                  return Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    child: Transform.translate(
                      offset: Offset(0, -4 * (1 - (v - 0.5).abs() * 2)),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withOpacity(0.4 + v * 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask about your condition...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.outline.withOpacity(0.7),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.onSurface),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: _sessionId != null && !_isTyping,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: (_sessionId != null && !_isTyping) ? _sendMessage : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: (_sessionId != null && !_isTyping)
                    ? AppColors.primaryGradient
                    : null,
                color: (_sessionId == null || _isTyping)
                    ? AppColors.surfaceContainerHigh
                    : null,
                shape: BoxShape.circle,
                boxShadow: (_sessionId != null && !_isTyping)
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.send_rounded,
                color: (_sessionId != null && !_isTyping)
                    ? Colors.white
                    : AppColors.outlineVariant,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat Message Model ───────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isError;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isError = false,
  });
}
