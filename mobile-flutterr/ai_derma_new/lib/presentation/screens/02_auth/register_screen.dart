import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:al_derma/config/theme/app_colors.dart';
import 'package:al_derma/config/theme/app_text_styles.dart';
import 'package:al_derma/config/routes/app_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              FadeInDown(
                child: Text('Create Account', style: AppTextStyles.headlineMedium),
              ),
              const SizedBox(height: 8),
              FadeInLeft(
                delay: const Duration(milliseconds: 200),
                child: Text('Start your professional skin assessment journey',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ),
              const SizedBox(height: 40),
              // Name Field
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _buildTextField(label: 'Full Name', icon: Icons.person_outline),
              ),
              const SizedBox(height: 20),
              // Email Field
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildTextField(label: 'Email Address', icon: Icons.email_outlined),
              ),
              const SizedBox(height: 20),
              // Password Field
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: _buildTextField(label: 'Password', icon: Icons.lock_outline, isPassword: true),
              ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRouter.home),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('Sign Up', style: AppTextStyles.titleLarge.copyWith(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text('Already have an account? Login',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
      ),
    );
  }
}