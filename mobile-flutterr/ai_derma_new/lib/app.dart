import 'package:flutter/material.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';

class AlDermaApp extends StatelessWidget {
  const AlDermaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Al-Derma Clinical Assistant',
      debugShowCheckedModeBanner: false,

      // هنا بنربط ملفات الثيم والراوتر
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,

      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        // دي عشان حجم الخط يفضل متناسق
        final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.2);
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaleFactor: scale),
          child: child!,
        );
      },
    );
  }
}