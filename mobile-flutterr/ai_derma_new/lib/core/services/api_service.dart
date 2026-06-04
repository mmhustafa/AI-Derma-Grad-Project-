// lib/core/services/api_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
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

  /// Resolves the correct [MediaType] from a filename extension.
  ///
  /// This is critical for multipart uploads: ASP.NET Core reads
  /// [IFormFile.ContentType] and forwards it to the AI model. If the
  /// content-type is missing or 'application/octet-stream', the Python
  /// FastAPI model cannot recognise the file as an image and returns a 500.
  static MediaType _mediaTypeFromFilename(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'heic':
      case 'heif':
        return MediaType('image', 'heic');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
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

  /// Predicts disease from an uploaded image using AI model.
  /// Sends image as multipart/form-data.
  ///
  /// [imageFile] - Image file from image_picker (cross-platform)
  ///
  /// Returns [ImagePredictionResponse] containing disease name, confidence,
  /// diagnosticResultId, and top 3 predictions.
  ///
  /// NOTE: The multipart field name MUST be 'Image' (capital I) to match the
  /// backend DTO: `public IFormFile Image { get; set; }` in ImageDiagnosisRequestDto.
  static Future<ImagePredictionResponse> predictImage(dynamic imageFile) async {
    final url = _uri(ApiConstants.predictImage);

    debugPrint('\n═════════════════════════════════════════════════════════');
    debugPrint('[API] IMAGE PREDICTION REQUEST');
    debugPrint('═════════════════════════════════════════════════════════');
    debugPrint('[API] Endpoint URL: $url');
    debugPrint('[API] Method: POST (multipart/form-data)');

    try {
      // ─── Read Image Bytes ──────────────────────────────────────────────────

      late final List<int> imageBytes;
      late final String imageFilename;

      if (imageFile is XFile) {
        imageBytes = await imageFile.readAsBytes();
        imageFilename = imageFile.name.isNotEmpty ? imageFile.name : 'image.jpg';
      } else if (imageFile is File) {
        imageBytes = await imageFile.readAsBytes();
        imageFilename = imageFile.path.split('/').last;
      } else {
        debugPrint('[API] ✗ Invalid image file type: ${imageFile.runtimeType}');
        throw ApiException('Invalid image file format.');
      }

      debugPrint('[API] Image file name  : $imageFilename');
      debugPrint('[API] Image byte size  : ${imageBytes.length} bytes');

      // ─── Build Multipart Request ───────────────────────────────────────────

      final request = http.MultipartRequest('POST', url);

      // IMPORTANT: Field name must be 'Image' (capital I) to match the backend
      // DTO property: `public IFormFile Image { get; set; }`
      const String multipartFieldName = 'Image';

      // Resolve MIME type from extension so ASP.NET Core sets the correct
      // IFormFile.ContentType. Without this it defaults to
      // 'application/octet-stream', which causes the FastAPI model to return
      // a 500 because it cannot identify the file as an image.
      final MediaType imageMediaType = _mediaTypeFromFilename(imageFilename);
      final String multipartContentType =
          '${imageMediaType.type}/${imageMediaType.subtype}';

      debugPrint('[API] Multipart field name : $multipartFieldName');
      debugPrint('[API] Multipart filename   : $imageFilename');
      debugPrint('[API] Multipart content-type: $multipartContentType');

      request.files.add(
        http.MultipartFile.fromBytes(
          multipartFieldName, // ← 'Image' — matches backend IFormFile property
          imageBytes,
          filename: imageFilename,
          contentType: imageMediaType, // ← critical: tells ASP.NET the MIME type
        ),
      );

      // ─── Auth Header ───────────────────────────────────────────────────────

      final token = await StorageService.getToken();
      final hasToken = token != null && token.isNotEmpty;
      if (hasToken) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('[API] Authorization header : ${hasToken ? 'Bearer [TOKEN]' : 'none (no token)'}');

      // ─── Log Full Request Payload Summary ──────────────────────────────────

      debugPrint('[API] Request payload keys:');
      debugPrint('[API]   files → [${request.files.map((f) => '"${f.field}"').join(', ')}]');
      debugPrint('[API]   fields → ${request.fields.isEmpty ? '(none)' : request.fields.keys.toList()}');
      debugPrint('[API] Sending request...');

      // ─── Send Request ──────────────────────────────────────────────────────

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));

      // ─── Parse Response ────────────────────────────────────────────────────

      final responseBody = await streamedResponse.stream.bytesToString();

      debugPrint('\n[API] RESPONSE RECEIVED');
      debugPrint('[API] Status Code  : ${streamedResponse.statusCode}');
      debugPrint('[API] Response Body: $responseBody');

      final httpResponse =
          http.Response(responseBody, streamedResponse.statusCode);
      final data = _parseResponse(httpResponse, ApiConstants.predictImage)
          as Map<String, dynamic>;

      final predictionResponse = ImagePredictionResponse.fromJson(data);

      debugPrint('[API] ✓ Image prediction successful');
      debugPrint('[API] Disease    : ${predictionResponse.disease}');
      debugPrint('[API] Confidence : ${predictionResponse.confidence}');
      debugPrint('[API] Result ID  : ${predictionResponse.diagnosticResultId}');
      debugPrint('═════════════════════════════════════════════════════════\n');

      return predictionResponse;
    } on ApiException catch (e) {
      debugPrint('[API] ✗ ApiException: ${e.message}');
      debugPrint('═════════════════════════════════════════════════════════\n');
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (predictImage): $e');
      debugPrint('[API] Error: No internet connection or network unreachable');
      debugPrint('═════════════════════════════════════════════════════════\n');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (predictImage): $e');
      debugPrint('[API] Error: Request took longer than 30 seconds');
      debugPrint('═════════════════════════════════════════════════════════\n');
      throw ApiException('Image analysis timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (predictImage): $e');
      debugPrint('[API] Error type : ${e.runtimeType}');
      debugPrint('[API] Stack trace: ${StackTrace.current}');
      debugPrint('═════════════════════════════════════════════════════════\n');
      throw ApiException('Failed to analyze image. Please try again.');
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

  /// Fetches confirmation questions for a specific disease diagnosis.
  /// Used for symptom verification after image-based prediction.
  static Future<ConfirmationQuestionsResponse> getConfirmationQuestions(
      String diseaseName) async {
    final endpoint = ApiConstants.confirmationQuestions(diseaseName);
    debugPrint('[API] → GET $endpoint');

    try {
      final headers = await _authHeaders();
      final response = await http
          .get(_uri(endpoint), headers: headers)
          .timeout(const Duration(seconds: 800));

      final data = _parseResponse(response, endpoint);
      debugPrint('[API] ✓ Confirmation questions loaded');
      return ConfirmationQuestionsResponse.fromJson(data);
    } on ApiException {
      rethrow;
    } on SocketException catch (e) {
      debugPrint('[API] ✗ SocketException (confirmationQuestions): $e');
      throw ApiException('No internet connection. Check your network.');
    } on TimeoutException catch (e) {
      debugPrint('[API] ✗ TimeoutException (confirmationQuestions): $e');
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('[API] ✗ Unexpected error (confirmationQuestions): $e');
      throw ApiException('Failed to load confirmation questions.');
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
