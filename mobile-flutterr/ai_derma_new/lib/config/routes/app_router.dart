// lib/config/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/01_home/home_screen.dart';
import '../../presentation/screens/02_auth/login_screen.dart';
import '../../presentation/screens/02_auth/register_screen.dart';
import '../../presentation/screens/03_onboarding/permission_screen.dart';
import '../../presentation/screens/04_upload/01_04_upload.dart';
import '../../presentation/screens/04_upload/upload_image_screen.dart';
import '../../presentation/screens/05_analyzing/analyzing_screen.dart';
import '../../presentation/screens/06_assessment/assessment_question_screen.dart';
import '../../presentation/screens/06_assessment/assessment_last_question_screen.dart';
import '../../presentation/screens/07_history/history_screen.dart';
import '../../presentation/screens/08_result/assessment_details_screen.dart';
import '../../presentation/screens/08_result/ai_result_screen.dart';
import '../../presentation/screens/09_chat/clinical_chat_screen.dart';
import '../../core/services/storage_service.dart';

/// Main navigation manager using GoRouter.
/// Implements an auth guard: if no JWT token is stored, redirect to /login.
class AppRouter {
  AppRouter._();

  // ─── Route Paths ──────────────────────────────────────────────────────────────

  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String permission = '/permission';
  static const String upload = '/upload';
  static const String analyzing = '/analyzing';
  static const String assessment = '/assessment';
  static const String assessmentLast = '/assessment-last'; // deprecated stub
  static const String history = '/history';
  static const String assessmentDetails = '/assessment-details';
  static const String aiResult = '/ai-result';
  static const String chat = '/chat';

  // ─── Router ───────────────────────────────────────────────────────────────────

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) =>
        ErrorScreen(error: state.error.toString()),

    // ── Auth Guard ──────────────────────────────────────────────────────────────
    redirect: (context, state) async {
      final isLoggedIn = await StorageService.isLoggedIn();
      final goingToLogin = state.matchedLocation == login ||
          state.matchedLocation == register;

      // Not logged in and not heading to auth screens → force to login
      if (!isLoggedIn && !goingToLogin) return login;

      // Already logged in and going to login → send to home
      if (isLoggedIn && state.matchedLocation == login) return home;

      return null; // No redirect needed
    },

    routes: [
      // ── Home ──────────────────────────────────────────────────────────────────
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────────
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),

      GoRoute(
        path: register,
        name: 'register',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),

      // ── Permission ────────────────────────────────────────────────────────────
      GoRoute(
        path: permission,
        name: 'permission',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const PermissionScreen(),
        ),
      ),

      // ── Upload ────────────────────────────────────────────────────────────────
      GoRoute(
        path: upload,
        name: 'upload',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const UploadImageScreen(),
        ),
      ),

      // ── Analyzing ─────────────────────────────────────────────────────────────
      GoRoute(
        path: analyzing,
        name: 'analyzing',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const AnalyzingScreen(),
        ),
      ),

      // ── Assessment (dynamic Q&A loop) ─────────────────────────────────────────
      GoRoute(
        path: assessment,
        name: 'assessment',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          child: const AssessmentQuestionScreen(),
        ),
      ),

      // Deprecated stub — kept to avoid broken references during transition
      GoRoute(
        path: assessmentLast,
        name: 'assessmentLast',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          // ignore: deprecated_member_use
          child: const AssessmentLastQuestionScreen(),
        ),
      ),

      // ── History ───────────────────────────────────────────────────────────────
      GoRoute(
        path: history,
        name: 'history',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HistoryScreen(),
        ),
      ),

      // ── Assessment Details (result screen) ────────────────────────────────────
      GoRoute(
        path: assessmentDetails,
        name: 'assessmentDetails',
        pageBuilder: (context, state) {
          // Receive data from GoRouter extra map
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideUpTransition(
            context: context,
            state: state,
            child: AssessmentDetailsScreen(
              diagnosticResultId: extra?['diagnosticResultId'] as int?,
              disease: extra?['disease'] as String?,
            ),
          );
        },
      ),

      // ── AI Result ─────────────────────────────────────────────────────────────
      GoRoute(
        path: aiResult,
        name: 'aiResult',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const AIResultScreen(),
        ),
      ),

      // ── Chat ──────────────────────────────────────────────────────────────────
      GoRoute(
        path: chat,
        name: 'chat',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return _buildPageWithSlideUpTransition(
            context: context,
            state: state,
            child: ClinicalChatScreen(
              condition: extra?['condition'] as String?,
            ),
          );
        },
      ),
    ],
  );

  // ─── Page Transitions ─────────────────────────────────────────────────────────

  static Page _buildPageWithDefaultTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Page _buildPageWithFadeTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static Page _buildPageWithSlideTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static Page _buildPageWithSlideUpTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}

// ─── Error Screen ─────────────────────────────────────────────────────────────

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Go to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}