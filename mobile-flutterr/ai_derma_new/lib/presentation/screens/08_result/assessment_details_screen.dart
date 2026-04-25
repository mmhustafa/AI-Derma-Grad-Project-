import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:al_derma/config/theme/app_colors.dart';
import 'package:al_derma/config/theme/app_text_styles.dart';
import 'package:al_derma/core/widgets/glass_header.dart';

class AssessmentDetailsScreen extends StatelessWidget {
  const AssessmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GlassHeader(
        title: 'Clinical Details',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: _buildHeaderCard(),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text('Key Characteristics', style: AppTextStyles.titleLarge),
            ),
            const SizedBox(height: 16),
            _buildInfoList([
              'Asymmetrical shape or irregular borders.',
              'Varying colors within the same spot.',
              'Diameter larger than 6mm.',
              'Evolution in size, shape, or elevation.',
            ]),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildActionSection(),
            ),
            const SizedBox(height: 40),
            Center(
              child: Opacity(
                opacity: 0.5,
                child: Text('AL-DERMA CLINICAL PROTOCOL V1.0',
                    style: AppTextStyles.caption.copyWith(letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('CONDITION SUMMARY',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text('Melanoma',
              style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            'The most serious type of skin cancer, developing in the cells (melanocytes) that produce melanin.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoList(List<String> items) {
    return Column(
      children: items.map((item) => FadeInUp(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface)),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildActionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text('RECOMMENDED ACTION',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You should book an appointment with a board-certified dermatologist for a physical biopsy within the next 7 days.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}