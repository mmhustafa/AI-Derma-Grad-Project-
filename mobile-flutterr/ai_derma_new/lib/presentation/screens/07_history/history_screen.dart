// lib/presentation/screens/07_history/history_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/routes/app_router.dart';
import '../../../core/widgets/glass_header.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentNavIndex = 1;
  String _selectedFilter = 'all';

  List<DiagnosticHistoryItem> _historyItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await ApiService.getHistory();
      if (mounted) {
        setState(() {
          _historyItems = items;
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
          _errorMessage = 'Failed to load history.';
          _isLoading = false;
        });
      }
    }
  }

  List<DiagnosticHistoryItem> get _filteredItems {
    if (_selectedFilter == 'all') return _historyItems;
    return _historyItems
        .where((item) =>
            (item.sourceType ?? '').toLowerCase() ==
            _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GlassHeader(
        title: 'History',
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        // Stats Bar
        FadeInDown(child: _buildStatsBar()),

        // Filter Tabs
        FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: _buildFilterTabs(),
        ),

        // List
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: _buildHistoryCard(_filteredItems[index]),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildStatsBar(loading: true),
        _buildFilterTabs(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: 4,
            itemBuilder: (_, __) => _buildShimmerCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 72,
                color: AppColors.outlineVariant.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadHistory,
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

  // ─── Stats Bar ──────────────────────────────────────────────────────────────

  Widget _buildStatsBar({bool loading = false}) {
    final total = _historyItems.length;
    final uniqueDiseases =
        _historyItems.map((e) => e.diseaseName).toSet().length;
    final avgConf = _historyItems
            .where((e) => e.confidenceScore != null)
            .isEmpty
        ? 0.0
        : _historyItems
                .where((e) => e.confidenceScore != null)
                .map((e) => e.confidenceScore!)
                .reduce((a, b) => a + b) /
            _historyItems
                .where((e) => e.confidenceScore != null)
                .length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: loading ? '—' : '$total',
            label: 'Total Scans',
            color: AppColors.primary,
          ),
          Container(width: 1, height: 40,
              color: AppColors.outlineVariant.withOpacity(0.3)),
          _buildStatItem(
            value: loading ? '—' : '$uniqueDiseases',
            label: 'Conditions',
            color: AppColors.secondary,
          ),
          Container(width: 1, height: 40,
              color: AppColors.outlineVariant.withOpacity(0.3)),
          _buildStatItem(
            value: loading || avgConf == 0
                ? '—'
                : '${(avgConf * 100).toStringAsFixed(0)}%',
            label: 'Avg. Conf.',
            color: AppColors.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall
              .copyWith(color: color, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  // ─── Filter Tabs ─────────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          _buildFilterTab('all', 'All'),
          _buildFilterTab('Expert System', 'AI'),
          _buildFilterTab('Image', 'Image'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ─── History Card ─────────────────────────────────────────────────────────────

  Widget _buildHistoryCard(DiagnosticHistoryItem item) {
    final sourceType = item.sourceType ?? 'Unknown';
    final isAI = sourceType.toLowerCase().contains('expert');
    final conf = item.confidenceScore;

    // Colour based on source type
    Color cardColor = isAI ? AppColors.primary : AppColors.secondary;
    IconData cardIcon =
        isAI ? Icons.quiz_rounded : Icons.biotech_rounded;

    // Parse date
    String dateLabel = '';
    if (item.createdAt != null) {
      try {
        final dt = DateTime.parse(item.createdAt!);
        dateLabel = DateFormat('MMM d, hh:mm a').format(dt);
      } catch (_) {
        dateLabel = item.createdAt!;
      }
    }

    return GestureDetector(
      onTap: () => context.push(
        AppRouter.assessmentDetails,
        extra: {
          'diagnosticResultId': item.id,
          'disease': item.diseaseName ?? '',
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(cardIcon, color: cardColor, size: 28),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.diseaseName ?? 'Unknown Condition',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (dateLabel.isNotEmpty)
                        Text(
                          dateLabel,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.outlineVariant),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (conf != null)
                        _buildChip(
                          '${(conf * 100).toStringAsFixed(0)}%',
                          AppColors.primary,
                        ),
                      if (conf != null) const SizedBox(width: 8),
                      _buildChip(
                        sourceType,
                        cardColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.outlineVariant, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─── Shimmer Card ─────────────────────────────────────────────────────────────

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 160,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Container(height: 10, width: 100,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 80,
                color: AppColors.outlineVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No history found',
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.outlineVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Your diagnosis history will appear here',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.outlineVariant.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}