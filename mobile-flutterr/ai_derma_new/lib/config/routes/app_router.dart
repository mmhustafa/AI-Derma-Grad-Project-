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

/// مدير التنقل الرئيسي للتطبيق
/// يستخدم GoRouter للتنقل بين الصفحات
class AppRouter {
  AppRouter._(); // منع إنشاء كائن

  // ============================================================
  // ROUTE NAMES (أسماء المسارات)
  // ============================================================

  /// الصفحة الرئيسية (Home)
  static const String home = '/';

  /// صفحة تسجيل الدخول
  static const String login = '/login';

  /// صفحة إنشاء حساب
  static const String register = '/register';

  /// صفحة طلب الأذونات
  static const String permission = '/permission';

  /// صفحة رفع الصورة
  static const String upload = '/upload';

  /// صفحة التحليل (Loading)
  static const String analyzing = '/analyzing';

  /// صفحة السؤال الأول في التقييم
  static const String assessment = '/assessment';

  /// صفحة السؤال الأخير في التقييم
  static const String assessmentLast = '/assessment-last';

  /// صفحة السجل (History)
  static const String history = '/history';

  /// صفحة تفاصيل التقييم
  static const String assessmentDetails = '/assessment-details';

  /// صفحة نتيجة الذكاء الاصطناعي
  static const String aiResult = '/ai-result';

  /// صفحة المحادثة مع المساعد
  static const String chat = '/chat';

  // ============================================================
  // ROUTER CONFIGURATION
  // ============================================================

  /// كائن الـ Router الرئيسي
  static final GoRouter router = GoRouter(
    // الصفحة الأولى عند فتح التطبيق
    initialLocation: home,

    // تفعيل الـ Debug Logs
    debugLogDiagnostics: true,

    // معالج الأخطاء
    errorBuilder: (context, state) => ErrorScreen(error: state.error.toString()),

    // قائمة المسارات
    routes: [
      // ========== صفحة Home ==========
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),

      // ========== صفحات المصادقة ==========
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

      // ========== صفحة الأذونات ==========
      GoRoute(
        path: permission,
        name: 'permission',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const PermissionScreen(),
        ),
      ),

      // ========== صفحة رفع الصورة ==========
      GoRoute(
        path: upload,
        name: 'upload',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const UploadImageScreen(),
        ),
      ),

      // ========== صفحة التحليل ==========
      GoRoute(
        path: analyzing,
        name: 'analyzing',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const AnalyzingScreen(),
        ),
      ),

      // ========== صفحات التقييم ==========
      GoRoute(
        path: assessment,
        name: 'assessment',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          child: const AssessmentQuestionScreen(),
        ),
      ),

      GoRoute(
        path: assessmentLast,
        name: 'assessmentLast',
        pageBuilder: (context, state) => _buildPageWithSlideTransition(
          context: context,
          state: state,
          child: const AssessmentLastQuestionScreen(),
        ),
      ),

      // ========== صفحة السجل ==========
      GoRoute(
        path: history,
        name: 'history',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HistoryScreen(),
        ),
      ),

      // ========== صفحات النتائج ==========
      GoRoute(
        path: assessmentDetails,
        name: 'assessmentDetails',
        pageBuilder: (context, state) => _buildPageWithSlideUpTransition(
          context: context,
          state: state,
          child: const AssessmentDetailsScreen(),
        ),
      ),

      GoRoute(
        path: aiResult,
        name: 'aiResult',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: const AIResultScreen(),
        ),
      ),

      // ========== صفحة المحادثة ==========
      GoRoute(
        path: chat,
        name: 'chat',
        pageBuilder: (context, state) => _buildPageWithSlideUpTransition(
          context: context,
          state: state,
          child: const ClinicalChatScreen(),
        ),
      ),
    ],
  );

  // ============================================================
  // PAGE TRANSITIONS (أنواع الانتقالات)
  // ============================================================

  /// انتقال افتراضي (Fade)
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

  /// انتقال Fade
  static Page _buildPageWithFadeTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// انتقال Slide من اليمين لليسار
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

  /// انتقال Slide من أسفل لأعلى
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

  /// انتقال Scale مع Fade
  static Page _buildPageWithScaleTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;
        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}



// ============================================================
// ERROR SCREEN (صفحة الأخطاء)
// ============================================================

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Go to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
// lib/config/routes/app_router.dart

import 'package:go_router/go_router.dart';
import '../../presentation/screens/01_home/home_screen.dart';
import '../../presentation/screens/02_auth/login_screen.dart';
import '../../presentation/screens/02_auth/register_screen.dart';
import '../../presentation/screens/03_onboarding/permission_screen.dart';
import '../../presentation/screens/04_upload/upload_image_screen.dart';
import '../../presentation/screens/05_analyzing/analyzing_screen.dart';
import '../../presentation/screens/06_assessment/assessment_question_screen.dart';
import '../../presentation/screens/06_assessment/assessment_last_question_screen.dart';
import '../../presentation/screens/07_history/history_screen.dart';
import '../../presentation/screens/08_result/assessment_details_screen.dart';
import '../../presentation/screens/08_result/ai_result_screen.dart';
import '../../presentation/screens/09_chat/clinical_chat_screen.dart';

class AppRouter {
  AppRouter._();

  // Routes
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String permission = '/permission';
  static const String upload = '/upload';
  static const String analyzing = '/analyzing';
  static const String assessment = '/assessment';
  static const String assessmentLast = '/assessment-last';
  static const String history = '/history';
  static const String assessmentDetails = '/assessment-details';
  static const String aiResult = '/ai-result';
  static const String chat = '/chat';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: permission,
        builder: (context, state) => const PermissionScreen(),
      ),
      GoRoute(
        path: upload,
        builder: (context, state) => const UploadImageScreen(),
      ),
      GoRoute(
        path: analyzing,
        builder: (context, state) => const AnalyzingScreen(),
      ),
      GoRoute(
        path: assessment,
        builder: (context, state) => const AssessmentQuestionScreen(),
      ),
      GoRoute(
        path: assessmentLast,
        builder: (context, state) => const AssessmentLastQuestionScreen(),
      ),
      GoRoute(
        path: history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: assessmentDetails,
        builder: (context, state) => const AssessmentDetailsScreen(),
      ),
      GoRoute(
        path: aiResult,
        builder: (context, state) => const AIResultScreen(),
      ),
      GoRoute(
        path: chat,
        builder: (context, state) => const ClinicalChatScreen(),
      ),
    ],
  );
}

 */