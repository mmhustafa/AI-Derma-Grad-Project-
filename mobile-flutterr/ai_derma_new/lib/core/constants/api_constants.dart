// lib/core/constants/api_constants.dart

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for all API-related constants.
///
/// ── Environment Guide ──────────────────────────────────────────────────────────
///
///  Platform         │ Base URL to use
/// ──────────────────┼────────────────────────────────────────────────────────────
///  Android Emulator │ http://10.0.2.2:5232          (loopback alias)
///  Physical Device  │ http://<YOUR_LAN_IP>:5232     (e.g. 192.168.1.2)
///  Flutter Web      │ http://localhost:5232          (same machine, no CORS issue)
///  iOS Simulator    │ http://localhost:5232
///
/// HOW TO FIND YOUR LAN IP (Windows):
///   Open CMD → type `ipconfig`
///   Look for "IPv4 Address" under your Wi-Fi adapter.
///
/// ── CHANGE THIS WHEN SWITCHING ENVIRONMENT ─────────────────────────────────────
class ApiConstants {
  ApiConstants._();

  // ─── Base URL ──────────────────────────────────────────────────────────────────
  //
  // Set _lanIp to your PC's actual Wi-Fi IPv4 address.
  // Run `ipconfig` in CMD and look for "IPv4 Address" under Wi-Fi adapter.
  static const String _lanIp = '192.168.1.2'; // ← UPDATE THIS
  static const int _port = 5232;

  /// The base URL used for all API requests.
  /// Automatically selects the correct address per platform.
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter web runs in the browser on the same machine as the backend.
      return 'http://localhost:$_port';
    }
    // For physical Android device on same Wi-Fi: use LAN IP.
    // For Android emulator: use 10.0.2.2 (maps to host localhost).
    //
    // ⚠ If testing on emulator, replace _lanIp with '10.0.2.2' below:
    return 'http://$_lanIp:$_port';
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────────
  static const String login = '/api/Auth/Login';
  static const String register = '/api/Auth/Register';

  // ─── Diagnostic ────────────────────────────────────────────────────────────────
  static const String nextStep = '/api/Diagnostic/next-step';
  static const String diseaseDetails = '/api/Diagnostic/disease-details';
  static const String saveAnswers = '/api/Diagnostic/save-answers';

  // ─── History ───────────────────────────────────────────────────────────────────
  static const String historyList = '/api/History/diagnostics';
  static String historyDetail(int id) => '/api/History/diagnostic/$id';

  // ─── Chat ──────────────────────────────────────────────────────────────────────
  static const String chatWelcome = '/api/Chat/welcome';
  static const String chat = '/api/Chat';

  // ─── Metadata ──────────────────────────────────────────────────────────────────
  static const String knowledgeBase = '/api/Metadata/knowledge-base';
  static String confirmationQuestions(String disease) =>
      '/api/Metadata/confirmation/$disease';
}
