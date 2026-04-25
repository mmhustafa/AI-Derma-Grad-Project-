// lib/config/theme/app_colors.dart

import 'package:flutter/material.dart';

/// ألوان Al-Derma - Material Design 3 Color System
/// مستوحاة من التصميم الأصلي لـ Clinical Sanctuary
class AppColors {
  AppColors._(); // منع إنشاء كائن من الكلاس

  // ============================================================
  // PRIMARY COLORS (الألوان الأساسية)
  // ============================================================

  /// اللون الأساسي للتطبيق - أزرق طبي
  static const Color primary = Color(0xFF00658D);

  /// حاوية اللون الأساسي - أزرق فاتح
  static const Color primaryContainer = Color(0xFF00AEEF);

  /// اللون الأساسي الثابت
  static const Color primaryFixed = Color(0xFFC6E7FF);

  /// اللون الأساسي الثابت الداكن
  static const Color primaryFixedDim = Color(0xFF82CFFF);

  /// لون النص على الأساسي
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// لون النص على حاوية الأساسي
  static const Color onPrimaryContainer = Color(0xFF003E58);

  /// لون النص على الأساسي الثابت
  static const Color onPrimaryFixed = Color(0xFF001E2D);

  /// لون النص على متغير الأساسي الثابت
  static const Color onPrimaryFixedVariant = Color(0xFF004C6B);

  // ============================================================
  // SECONDARY COLORS (الألوان الثانوية)
  // ============================================================

  /// اللون الثانوي - أزرق مخضر
  static const Color secondary = Color(0xFF006874);

  /// حاوية الثانوي - سماوي
  static const Color secondaryContainer = Color(0xFF5CE9FE);

  /// الثانوي الثابت
  static const Color secondaryFixed = Color(0xFF98F0FF);

  /// الثانوي الثابت الداكن
  static const Color secondaryFixedDim = Color(0xFF45D8ED);

  /// لون النص على الثانوي
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// لون النص على حاوية الثانوي
  static const Color onSecondaryContainer = Color(0xFF006773);

  /// لون النص على الثانوي الثابت
  static const Color onSecondaryFixed = Color(0xFF001F24);

  /// لون النص على متغير الثانوي الثابت
  static const Color onSecondaryFixedVariant = Color(0xFF004F58);

  // ============================================================
  // TERTIARY COLORS (الألوان الثلاثية)
  // ============================================================

  /// اللون الثلاثي - أخضر صحي
  static const Color tertiary = Color(0xFF006E1C);

  /// حاوية الثلاثي
  static const Color tertiaryContainer = Color(0xFF54B757);

  /// الثلاثي الثابت
  static const Color tertiaryFixed = Color(0xFF94F990);

  /// الثلاثي الثابت الداكن
  static const Color tertiaryFixedDim = Color(0xFF78DC77);

  /// لون النص على الثلاثي
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// لون النص على حاوية الثلاثي
  static const Color onTertiaryContainer = Color(0xFF00430E);

  /// لون النص على الثلاثي الثابت
  static const Color onTertiaryFixed = Color(0xFF002204);

  /// لون النص على متغير الثلاثي الثابت
  static const Color onTertiaryFixedVariant = Color(0xFF005313);

  // ============================================================
  // SURFACE COLORS (ألوان السطح)
  // ============================================================

  /// السطح الأساسي - خلفية فاتحة
  static const Color surface = Color(0xFFF5FAFF);

  /// السطح الداكن
  static const Color surfaceDim = Color(0xFFD6DAE0);

  /// السطح الساطع
  static const Color surfaceBright = Color(0xFFF5FAFF);

  /// حاوية السطح الأدنى (الأكثر بياضاً)
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  /// حاوية السطح المنخفض
  static const Color surfaceContainerLow = Color(0xFFEFF4FA);

  /// حاوية السطح
  static const Color surfaceContainer = Color(0xFFEAEEF4);

  /// حاوية السطح العالي
  static const Color surfaceContainerHigh = Color(0xFFE4E9EE);

  /// حاوية السطح الأعلى
  static const Color surfaceContainerHighest = Color(0xFFDEE3E8);

  /// متغير السطح
  static const Color surfaceVariant = Color(0xFFDEE3E8);

  /// لون النص على السطح
  static const Color onSurface = Color(0xFF171C20);

  /// لون النص على متغير السطح
  static const Color onSurfaceVariant = Color(0xFF3E4850);

  // ============================================================
  // BACKGROUND COLORS (ألوان الخلفية)
  // ============================================================

  /// الخلفية الأساسية
  static const Color background = Color(0xFFF5FAFF);

  /// لون النص على الخلفية
  static const Color onBackground = Color(0xFF171C20);

  // ============================================================
  // ERROR COLORS (ألوان الأخطاء)
  // ============================================================

  /// لون الخطأ - أحمر
  static const Color error = Color(0xFFBA1A1A);

  /// حاوية الخطأ
  static const Color errorContainer = Color(0xFFFFDAD6);

  /// لون النص على الخطأ
  static const Color onError = Color(0xFFFFFFFF);

  /// لون النص على حاوية الخطأ
  static const Color onErrorContainer = Color(0xFF93000A);

  // ============================================================
  // OUTLINE COLORS (ألوان الحدود)
  // ============================================================

  /// الحدود الأساسية
  static const Color outline = Color(0xFF6E7881);

  /// متغير الحدود - أفتح
  static const Color outlineVariant = Color(0xFFBDC8D1);

  // ============================================================
  // INVERSE COLORS (الألوان العكسية - للـ Dark Mode)
  // ============================================================

  /// السطح العكسي
  static const Color inverseSurface = Color(0xFF2C3135);

  /// النص العكسي على السطح
  static const Color inverseOnSurface = Color(0xFFECF1F7);

  /// الأساسي العكسي
  static const Color inversePrimary = Color(0xFF82CFFF);

  // ============================================================
  // SURFACE TINT (صبغة السطح)
  // ============================================================

  /// صبغة السطح - تستخدم للتلوين الديناميكي
  static const Color surfaceTint = Color(0xFF00658D);

  // ============================================================
  // ADDITIONAL SEMANTIC COLORS (ألوان إضافية ذات معنى)
  // ============================================================

  /// لون النجاح
  static const Color success = Color(0xFF00B894);

  /// لون التحذير
  static const Color warning = Color(0xFFFDAA5E);

  /// لون المعلومات
  static const Color info = Color(0xFF40C4FF);

  // ============================================================
  // GRADIENTS (التدرجات)
  // ============================================================

  /// التدرج الأساسي للتطبيق
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// تدرج السطح
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceContainerLow],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// تدرج البطاقة (للـ Cards)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A35), Color(0xFF252547)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// تدرج Hero (للصفحة الرئيسية)
  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// تدرج النجاح
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// تدرج الخطأ
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // SHADOWS (الظلال)
  // ============================================================

  /// ظل خفيف للبطاقات
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// ظل متوسط للعناصر المرتفعة
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: primary.withOpacity(0.1),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  /// ظل قوي للعناصر العائمة
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primary.withOpacity(0.15),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];

  // ============================================================
  // HELPER METHODS (دوال مساعدة)
  // ============================================================

  /// الحصول على لون الخطورة حسب النسبة
  static Color getSeverityColor(double severity) {
    if (severity >= 0.8) return error;
    if (severity >= 0.5) return warning;
    return success;
  }

  /// الحصول على لون الثقة حسب النسبة
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return tertiary;
    if (confidence >= 0.6) return warning;
    return error;
  }

  /// الحصول على لون شفاف (مع opacity)
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}