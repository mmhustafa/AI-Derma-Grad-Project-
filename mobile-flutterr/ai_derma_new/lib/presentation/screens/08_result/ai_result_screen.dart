import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:al_derma/config/theme/app_colors.dart';
import 'package:al_derma/config/theme/app_text_styles.dart';
import 'package:al_derma/config/routes/app_router.dart';
import 'package:al_derma/core/widgets/glass_header.dart';

class AIResultScreen extends StatelessWidget {
  const AIResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassHeader(title: 'AI Analysis', onBackPressed: () => context.go(AppRouter.home)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            FadeInDown(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: 0.92,
                        strokeWidth: 12,
                        backgroundColor: AppColors.outlineVariant.withOpacity(0.2),
                        color: AppColors.primary,
                      ),
                    ),
                    Column(
                      children: [
                        Text('92%', style: AppTextStyles.headlineMedium.copyWith(fontSize: 40, color: AppColors.primary)),
                        Text('Confidence', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    Text('Detected Condition:', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    Text('Melanoma', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.error)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Our AI engine has detected signs highly consistent with Melanoma. This is a clinical screening, not a final diagnosis.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(AppRouter.assessmentDetails),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push(AppRouter.chat),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Ask Assistant', style: TextStyle(color: Colors.white)),
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
}