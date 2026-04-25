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

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentNavIndex = 1;
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _historyItems = [
    {
      'disease': 'Melanoma',
      'date': DateTime(2024, 10, 26, 10, 30),
      'confidence': 0.92,
      'type': 'ai',
      'severity': 'high',
      'icon': Icons.biotech_rounded,
    },
    {
      'disease': 'Psoriasis',
      'date': DateTime(2024, 10, 24, 14, 15),
      'confidence': 0.85,
      'type': 'symptom',
      'severity': 'medium',
      'icon': Icons.quiz_rounded,
    },
    {
      'disease': 'Eczema',
      'date': DateTime(2024, 10, 20, 9, 45),
      'confidence': 0.85,
      'type': 'ai',
      'severity': 'medium',
      'icon': Icons.biotech_rounded,
    },
    {
      'disease': 'Acne Vulgarism',
      'date': DateTime(2024, 10, 15, 11, 20),
      'confidence': 0.78,
      'type': 'routine',
      'severity': 'low',
      'icon': Icons.medical_information_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == 'all') return _historyItems;
    return _historyItems
        .where((item) => item['type'] == _selectedFilter)
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
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          FadeInDown(
            child: _buildStatsBar(),
          ),

          // Filter Tabs
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: _buildFilterTabs(),
          ),

          // List
          Expanded(
            child: _filteredItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
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
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }

  // ============================================================
  // STATS BAR
  // ============================================================
  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.1),
        ),
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
            value: '${_historyItems.length}',
            label: 'Total Scans',
            color: AppColors.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.outlineVariant.withOpacity(0.3),
          ),
          _buildStatItem(
            value: '3',
            label: 'Conditions',
            color: AppColors.secondary,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.outlineVariant.withOpacity(0.3),
          ),
          _buildStatItem(
            value: '88%',
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
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTER TABS
  // ============================================================
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
          _buildFilterTab('ai', 'AI Result'),
          _buildFilterTab('symptom', 'Question'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String value, String label) {
    final isSelected = _selectedFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
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

  // ============================================================
  // HISTORY CARD
  // ============================================================
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    Color severityColor;
    switch (item['severity']) {
      case 'high':
        severityColor = AppColors.error;
        break;
      case 'medium':
        severityColor = AppColors.warning;
        break;
      default:
        severityColor = AppColors.tertiary;
    }

    return GestureDetector(
      onTap: () => context.push(AppRouter.assessmentDetails),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.1),
          ),
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
                color: severityColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item['icon'],
                color: severityColor,
                size: 28,
              ),
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
                          item['disease'],
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, hh:mm a').format(item['date']),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Confidence
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(item['confidence'] * 100).toInt()}%',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Type
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['severity'].toString().toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: severityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outlineVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================
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
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.outlineVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your diagnosis history will appear here',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.outlineVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}