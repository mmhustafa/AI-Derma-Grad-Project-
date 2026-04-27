// lib/presentation/screens/01_home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/routes/app_router.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _username = '...';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await StorageService.getUsername();
    if (mounted && name != null) {
      setState(() => _username = name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInDown(
                child: _buildHeader(context),
              ),

              const SizedBox(height: 32),

              // Hero Card
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildHeroCard(),
              ),

              const SizedBox(height: 32),

              // Feature Cards
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildFeatureCards(),
              ),

              const SizedBox(height: 32),

              // Tips Section
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: _buildTipsSection(),
              ),

              const SizedBox(height: 32),

              // Recent Scans
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: _buildRecentScans(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          _handleNavigation(index);
        },
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
      // Already on home
        break;
      case 1:
        context.push(AppRouter.history);
        break;
      case 2:
        context.push(AppRouter.upload);
        break;
      case 3:
      // Profile - TODO
        break;
    }
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hello, $_username',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _username.isNotEmpty ? _username[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00658D), Color(0xFF006874)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start Diagnosis',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get a professional-grade skin assessment in seconds using our AI-powered clinical tool.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRouter.upload),
              icon: const Icon(Icons.camera_alt_rounded, size: 22),
              label: const Text('Continue with Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRouter.assessment),
              icon: const Icon(Icons.quiz_rounded, size: 22),
              label: const Text('Go to Symptom Questions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURE CARDS
  // ============================================================
  Widget _buildFeatureCards() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.history_rounded,
          title: 'History',
          subtitle: 'View your previous assessments',
          color: AppColors.primary,
          onTap: () => context.push(AppRouter.history),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.info_rounded,
          title: 'About & Instructions',
          subtitle: 'How to get the best results',
          color: AppColors.secondary,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.2),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIPS SECTION
  // ============================================================
  Widget _buildTipsSection() {
    return Column(
      children: [
        _buildTipCard(
          icon: Icons.lightbulb_rounded,
          title: 'Did you know?',
          description:
          'Early detection of skin irregularities increases successful treatment rates by over 90%.',
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          icon: Icons.spa_rounded,
          title: 'Skin Care Tip',
          description:
          'Broad-spectrum SPF 30+ should be applied even on cloudy days to prevent UVA damage.',
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT SCANS
  // ============================================================
  Widget _buildRecentScans() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 60,
            color: AppColors.outlineVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No scans yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.outlineVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by scanning your skin',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.outlineVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

