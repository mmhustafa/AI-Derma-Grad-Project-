// lib/config/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// أنماط النصوص المستخدمة في التطبيق
/// تستخدم خطوط Manrope للعناوين و Inter للنصوص
class AppTextStyles {
  AppTextStyles._(); // منع إنشاء كائن

  // ============================================================
  // DISPLAY STYLES (أكبر العناوين)
  // ============================================================

  /// Display Large - للعناوين الضخمة جداً
  static TextStyle get displayLarge => GoogleFonts.manrope(
    fontSize: 57,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.25,
    height: 1.12,
  );

  /// Display Medium - للعناوين الكبيرة
  static TextStyle get displayMedium => GoogleFonts.manrope(
    fontSize: 45,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    height: 1.16,
  );

  /// Display Small - للعناوين المتوسطة الكبيرة
  static TextStyle get displaySmall => GoogleFonts.manrope(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.22,
  );

  // ============================================================
  // HEADLINE STYLES (العناوين الرئيسية)
  // ============================================================

  /// Headline Large - للعناوين الكبيرة في الصفحات
  static TextStyle get headlineLarge => GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.25,
  );

  /// Headline Medium - للعناوين المتوسطة
  static TextStyle get headlineMedium => GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.29,
  );

  /// Headline Small - للعناوين الصغيرة
  static TextStyle get headlineSmall => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.33,
  );

  // ============================================================
  // TITLE STYLES (عناوين الأقسام)
  // ============================================================

  /// Title Large - للعناوين الكبيرة في البطاقات
  static TextStyle get titleLarge => GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.27,
  );

  /// Title Medium - للعناوين المتوسطة
  static TextStyle get titleMedium => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  /// Title Small - للعناوين الصغيرة
  static TextStyle get titleSmall => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ============================================================
  // BODY STYLES (النصوص الأساسية)
  // ============================================================

  /// Body Large - للنصوص الكبيرة في المحتوى
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Body Medium - للنصوص المتوسطة (الأكثر استخداماً)
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Body Small - للنصوص الصغيرة
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ============================================================
  // LABEL STYLES (التسميات)
  // ============================================================

  /// Label Large - للأزرار والتسميات الكبيرة
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Label Medium - للتسميات المتوسطة
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  /// Label Small - للتسميات الصغيرة
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ============================================================
  // CUSTOM STYLES (أنماط مخصصة للتطبيق)
  // ============================================================

  /// Caption - للنصوص التوضيحية الصغيرة جداً
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.6,
  );

  /// Overline - للنصوص العلوية (مثل التصنيفات)
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
    textBaseline: TextBaseline.alphabetic,
  );

  /// Button - للأزرار
  static TextStyle get button => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.25,
  );

  /// Dialog Title - لعناوين الـ Dialogs
  static TextStyle get dialogTitle => GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.3,
  );

  /// App Bar Title - لعناوين الـ AppBar
  static TextStyle get appBarTitle => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.33,
  );

  /// Chip Label - للـ Chips
  static TextStyle get chipLabel => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.23,
  );

  /// Tag - للـ Tags والـ Badges
  static TextStyle get tag => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.6,
  );

  /// Quote - للاقتباسات
  static TextStyle get quote => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.6,
    fontStyle: FontStyle.italic,
  );

  /// Number Large - للأرقام الكبيرة (مثل النسب المئوية)
  static TextStyle get numberLarge => GoogleFonts.manrope(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.2,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  /// Number Medium - للأرقام المتوسطة
  static TextStyle get numberMedium => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.3,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  // ============================================================
  // HELPER METHODS (دوال مساعدة)
  // ============================================================

  /// تطبيق لون على النمط
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// تطبيق وزن على النمط
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// تطبيق حجم على النمط
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// إنشاء نمط gradient للنص
  static TextStyle withGradient(
      TextStyle style,
      Gradient gradient,
      Rect rect,
      ) {
    return style.copyWith(
      foreground: Paint()
        ..shader = gradient.createShader(rect),
    );
  }

  /// نص بظل
  static TextStyle withShadow(
      TextStyle style, {
        Color shadowColor = Colors.black,
        double blurRadius = 4.0,
        Offset offset = const Offset(0, 2),
      }) {
    return style.copyWith(
      shadows: [
        Shadow(
          color: shadowColor.withOpacity(0.25),
          blurRadius: blurRadius,
          offset: offset,
        ),
      ],
    );
  }

  /// نص تحته خط
  static TextStyle withUnderline(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.underline,
    );
  }

  /// نص به خط في المنتصف
  static TextStyle withLineThrough(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.lineThrough,
    );
  }
}