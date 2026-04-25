// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// شلنا الـ provider مؤقتاً عشان ميعملش أيرور وهو فاضي
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // قفل الشاشة على الوضع العمودي
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تغيير لون الـ Status Bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // تحميل Google Fonts مسبقاً لتحسين الأداء
  await _loadFonts();

  // الحل هنا: هنشغل التطبيق مباشرة بدون MultiProvider
  // أول ما نبدأ نبرمج الـ Logic هنرجعه ونحط جواه الـ Providers بتاعتنا
  runApp(const AlDermaApp());
}

// ============================================================
// تحميل الخطوط مسبقاً
// ============================================================
Future<void> _loadFonts() async {
  try {
    await Future.wait([
      GoogleFonts.pendingFonts([
        GoogleFonts.manrope(),
        GoogleFonts.inter(),
      ]),
    ]);
  } catch (e) {
    debugPrint('Error loading fonts: $e');
  }
}