// lib/core/services/api_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/auth_model.dart';
import '../models/chat_model.dart';
import '../models/diagnosis_model.dart';
import '../models/history_model.dart';
import '../models/metadata_model.dart';
import 'storage_service.dart';

/// Central API service.
/// Handles all HTTP communication with the ASP.NET backend.
///
/// All public methods:
///   - Use async/await
///   - Wrap logic in try/catch
///   - Throw [ApiException] with a human-readable message on failure
class ApiService {
  ApiService._();

  // ─── Helpers ────────────────────────────────────────────────────────────────

  static Uri _uri(String path, [Map<String, String>? queryParams]) {
    final base = Uri.parse(ApiConstants.baseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.port,
      path: path,
      queryParameters: queryParams,
    );
  }

  static Map<String, String> _jsonHeaders() => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      };

  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (token != null && token.isNotEmpty)
        HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  /// Parses an HTTP response. Throws [ApiException] for non-2xx responses.
  static dynamic _parseResponse(http.Response response, String endpoint) {
    debugPrint('[API] ← ${response.statusCode} $endpoint');
    final body = response.body;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }

    // Map common status codes to friendly messages
    String errorMessage;
    switch (response.statusCode) {
      case 400:
        errorMessage = _extractBodyMessage(body) ??
            'Invalid request. Please check your input.';
        break;
      case 401:
        errorMessage =
            'Invalid credentials. Please check your email and password.';
        break;
      case 403:
        errorMessage = 'Access denied. Please log in again.';
        break;
      case 404:
        errorMessage = 'Resource not found.';
        break;
      case 409:
        errorMessage =
            _extractBodyMessage(body) ?? 'This account already exists.';
        break;
      case 422:
        errorMessage =
            _extractBodyMessage(body) ?? 'Validation error. Check your input.';
        break;
      case 500:
      case 502:
      case 503:
        errorMessage = 'Server error. Please try again later.';
        break;
      default:
        errorMessage = _extractBodyMessage(body) ??
            'Request failed (${response.statusCode})';
    }

    debugPrint('[API] ✗ Error: $errorMessage (body: $body)');
    throw ApiException(errorMessage, response.statusCode);
  }

  /// Tries to pull a meaningful message out of an error response body.
  static String? _extractBodyMessage(String body) {
    if (body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is String && decoded.isNotEmpty) return decoded;
      if (decoded is Map) {
        return decoded['message']?.toString() ??
            decoded['title']?.toString() ??
            decoded['error']?.toString();
      }
    } catch (_) {
      return body.length < 200 ? body : null;
    }
    return null;
  }

  // ─── Auth ────────────────────────────────────────────────────────────────────

  /// Authenticates the user and returns a [LoginResponse] containing the JWT.
  /// Saves the token and username to [StorageService] automatically.
  static Future<LoginResponse> login(String email, String password) async {
    debugPrint('[API] → POST ${ApiConstants.login}');
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await http
          .post(
            _uri(ApiConstants.login),
            headers: _jsonHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 800));

      final data =
          _parseResponse(response, ApiConstants.login) as Map<String, dynamic>;
      final loginResponse = LoginResponse.fromJson(data);

      await StorageService.saveToken(loginResponse.token);
      await StorageService.saveUsername(email.split('@').first);
      debugPrint('[API] ✓ Login successful');
      return loginResponse;
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (login): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (login): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (login): $e');
      throw ApiException('Login failed. Please try again.');
    }
  }

  /// Registers a new user. Returns true on success.
  static Future<bool> register({
    required String userName,
    required String email,
    required String password,
    required int age,
    required String gender,
  }) async {
    debugPrint('[API] → POST ${ApiConstants.register}');
    try {
      final request = RegisterRequest(
        userName: userName,
        email: email,
        password: password,
        age: age,
        gender: gender,
      );
      final response = await http
          .post(
            _uri(ApiConstants.register),
            headers: _jsonHeaders(),
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 800));

      _parseResponse(response, ApiConstants.register);
      debugPrint('[API] ✓ Registration successful');
      return true;
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (register): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (register): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (register): $e');
      throw ApiException('Registration failed. Please try again.');
    }
  }

  // ─── Diagnostic ───────────────────────────────────────────────────────────────

  /// Calls POST /api/Diagnostic/next-step to get the next diagnostic step.
  ///
  /// [facts] - List of answers accumulated from user selections.
  ///           Format: ["Q1:Yes", "Q2:No", ...] or raw values ["fever", "itching"]
  /// [diagnosticResultId] - ID of the diagnostic session (set after first response)
  ///
  /// Returns [DiagnosisResponse] containing next question or final diagnosis.
  ///
  /// Example:
  /// ```dart
  /// final response = await ApiService.getNextStep(
  ///   facts: ["fever", "itching"],
  ///   diagnosticResultId: null,
  /// );
  /// ```
  static Future<DiagnosisResponse> getNextStep({
    required List<String> facts,
    int? diagnosticResultId,
  }) async {
    final url = _uri(ApiConstants.nextStep);

    debugPrint('\n═════════════════════════════════════════════════════════');
    debugPrint('[API] DIAGNOSTIC NEXT-STEP REQUEST');
    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('[API] URL: $url');
    debugPrint('[API] Method: POST');

    try {
      // ─── Build Request ─────────────────────────────────────────────────────

      final request = NextStepRequest(
        facts: facts,
        diagnosticResultId: diagnosticResultId,
      );

      // ─── Serialize to JSON ─────────────────────────────────────────────────

      final requestMap = request.toJson();
      final requestBody = jsonEncode(requestMap);

      debugPrint('[API] Request Body (Map): $requestMap');
      debugPrint('[API] Request Body (JSON): $requestBody');
      debugPrint('[API] Request Body Length: ${requestBody.length} bytes');

      // ─── Build Headers ────────────────────────────────────────────────────

      final headers = await _authHeaders();
      debugPrint('[API] Headers:');
      headers.forEach((key, value) {
        final displayValue = key == 'Authorization' ? 'Bearer [TOKEN]' : value;
        debugPrint('[API]   $key: $displayValue');
      });

      // ─── Send POST Request ─────────────────────────────────────────────────

      debugPrint('[API] Sending request...');
      final response = await http
          .post(
            url,
            headers: headers,
            body: requestBody, // ✅ JSON string body
          )
          .timeout(const Duration(seconds: 600));

      // ─── Parse Response ───────────────────────────────────────────────────

      debugPrint('\n[API] RESPONSE RECEIVED');
      debugPrint('[API] Status Code: ${response.statusCode}');
      debugPrint('[API] Response Body Length: ${response.body.length} bytes');
      debugPrint('[API] Response Body: ${response.body}');

      final data = _parseResponse(response, ApiConstants.nextStep)
          as Map<String, dynamic>;

      final diagnosisResponse = DiagnosisResponse.fromJson(data);

      debugPrint('[API] ✓ Successfully parsed DiagnosisResponse');
      debugPrint('[API] Response Type: ${diagnosisResponse.type}');
      if (diagnosisResponse.type == 'question') {
        debugPrint('[API] Question Code: ${diagnosisResponse.questionCode}');
      } else {
        debugPrint('[API] Disease: ${diagnosisResponse.disease}');
      }
      debugPrint('═════════════════════════════════════════════════════════\n');

      return diagnosisResponse;
    } on ApiException catch (e) {
      debugPrint('[API] ✗ ApiException: ${e.message}');
      debugPrint('═════════════════════════════════════════════════════════\n');
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException: $e');
      debugPrint('[API] Error: No internet connection or network unreachable');
      debugPrint('═════════════════════════════════════════════════════════\n');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException: $e');
      debugPrint('[API] Error: Request took longer than 20 seconds');
      debugPrint('═════════════════════════════════════════════════════════\n');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected Exception: $e');
      debugPrint('[API] Error Type: ${e.runtimeType}');
      debugPrint('═════════════════════════════════════════════════════════\n');
      throw ApiException('Diagnostic step failed. Please try again.');
    }
  }

  /// Fetches disease details by name for the result screen.
  static Future<DiseaseDetails> getDiseaseDetails(String diseaseName) async {
    debugPrint('[API] → GET ${ApiConstants.diseaseDetails}?name=$diseaseName');
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(
            _uri(ApiConstants.diseaseDetails, {'name': diseaseName}),
            headers: headers,
          )
          .timeout(const Duration(seconds: 800));

      final data = _parseResponse(response, ApiConstants.diseaseDetails)
          as Map<String, dynamic>;
      return DiseaseDetails.fromJson(data);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (diseaseDetails): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (diseaseDetails): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (diseaseDetails): $e');
      throw ApiException('Failed to load disease details.');
    }
  }

  /// Saves the user's symptom answers linked to a diagnostic result.
  static Future<bool> saveAnswers(SaveAnswersRequest request) async {
    debugPrint('[API] → POST ${ApiConstants.saveAnswers}');
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
            _uri(ApiConstants.saveAnswers),
            headers: headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 800));

      _parseResponse(response, ApiConstants.saveAnswers);
      debugPrint('[API] ✓ Answers saved successfully');
      return true;
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (saveAnswers): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (saveAnswers): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (saveAnswers): $e');
      throw ApiException('Failed to save answers.');
    }
  }

  // ─── History ──────────────────────────────────────────────────────────────────

  /// Returns the current user's diagnostic history.
  static Future<List<DiagnosticHistoryItem>> getHistory() async {
    debugPrint('[API] → GET ${ApiConstants.historyList}');
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(_uri(ApiConstants.historyList), headers: headers)
          .timeout(const Duration(seconds: 800));

      if (response.statusCode == 404) return [];

      final data =
          _parseResponse(response, ApiConstants.historyList) as List<dynamic>;
      return data
          .map((e) => DiagnosticHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (history): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (history): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (history): $e');
      throw ApiException('Failed to load history.');
    }
  }

  /// Returns the details of a single diagnostic result by its ID.
  static Future<DiagnosticDetail> getHistoryDetail(int resultId) async {
    debugPrint('[API] → GET ${ApiConstants.historyDetail(resultId)}');
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(
            _uri(ApiConstants.historyDetail(resultId)),
            headers: headers,
          )
          .timeout(const Duration(seconds: 800));

      final data =
          _parseResponse(response, ApiConstants.historyDetail(resultId))
              as Map<String, dynamic>;
      return DiagnosticDetail.fromJson(data);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (historyDetail): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (historyDetail): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (historyDetail): $e');
      throw ApiException('Failed to load diagnostic detail.');
    }
  }

  // ─── Metadata ──────────────────────────────────────────────────────────────────

  /// Fetches the Knowledge Base metadata containing questions and their options.
  /// Each option has a 'val' (to send to backend) and 'label' (to display to user).
  static Future<KnowledgeBaseMetadata> getKnowledgeBaseMetadata() async {
    debugPrint('[API] → GET ${ApiConstants.knowledgeBase}');
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(_uri(ApiConstants.knowledgeBase), headers: headers)
          .timeout(const Duration(seconds: 800));

      final data = _parseResponse(response, ApiConstants.knowledgeBase)
          as Map<String, dynamic>;
      debugPrint('[API] ✓ Knowledge Base metadata loaded');
      return KnowledgeBaseMetadata.fromJson(data);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (metadata): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (metadata): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (metadata): $e');
      throw ApiException('Failed to load knowledge base metadata.');
    }
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────────

  /// Fetches the welcome message and session ID for the chat screen.
  static Future<ChatWelcomeResponse> getChatWelcome() async {
    debugPrint('[API] → GET ${ApiConstants.chatWelcome}');
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(_uri(ApiConstants.chatWelcome), headers: headers)
          .timeout(const Duration(seconds: 800));

      final data = _parseResponse(response, ApiConstants.chatWelcome)
          as Map<String, dynamic>;
      return ChatWelcomeResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (chatWelcome): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (chatWelcome): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (chatWelcome): $e');
      throw ApiException('Failed to connect to chat.');
    }
  }

  /// Sends a user message and returns the AI reply.
  static Future<ChatResponse> sendChatMessage(ChatRequest request) async {
    debugPrint('[API] → POST ${ApiConstants.chat}');
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
            _uri(ApiConstants.chat),
            headers: headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 800));

      final data =
          _parseResponse(response, ApiConstants.chat) as Map<String, dynamic>;
      return ChatResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (chat): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (chat): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (chat): $e');
      throw ApiException('Chat request failed. Please try again.');
    }
  }
}

// ─── ApiException ─────────────────────────────────────────────────────────────

/// Thrown by [ApiService] methods when the backend returns an error
/// or the request fails. Contains a user-friendly [message].
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
