// lib/main.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();



  // ── Portrait-only orientation ────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar styling ────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Google Fonts — safe offline loading ──────────────────────────────────────
  // On web: fonts are bundled separately, runtime fetching is not needed.
  // On mobile: pre-cache but NEVER crash if there is no internet.
  //   GoogleFonts falls back to the system font automatically.
  if (!kIsWeb) {
    await _preloadFonts();
  }

  runApp(const AlDermaApp());
}

/// Attempts to pre-cache Manrope + Inter.
/// Times out after 4 s so a poor network never blocks startup.
/// Any error (SocketException, TimeoutException) is silently swallowed —
/// Flutter uses the system font as a safe fallback.
Future<void> _preloadFonts() async {
  try {
    await Future.wait([
      GoogleFonts.pendingFonts([
        GoogleFonts.manrope(),
        GoogleFonts.inter(),
      ]),
    ]).timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        debugPrint('[Fonts] Pre-load timed out — using system font fallback.');
        return [];
      },
    );
    debugPrint('[Fonts] Pre-loaded successfully.');
  } catch (e) {
    // SocketException, HttpException, etc. — safe to ignore.
    debugPrint('[Fonts] Pre-load skipped (no internet or font error): $e');
  }
}