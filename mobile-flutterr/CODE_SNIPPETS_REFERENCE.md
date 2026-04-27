# Flutter API Request Body - Code Snippets Reference

## 1️⃣ Data Model (`lib/core/models/diagnosis_model.dart`)

```dart
class NextStepRequest {
  final List<String> facts;
  final int? diagnosticResultId;

  NextStepRequest({
    required this.facts,
    this.diagnosticResultId,
  });

  /// Serializes with PascalCase keys matching C# DTO
  Map<String, dynamic> toJson() => {
    'Facts': facts,
    'DiagnosticResultId': diagnosticResultId,
  };
}
```

---

## 2️⃣ API Service Call (`lib/core/services/api_service.dart`)

### Headers Setup
```dart
static Future<Map<String, String>> _authHeaders() async {
  final token = await StorageService.getToken();
  return {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
    if (token != null && token.isNotEmpty)
      HttpHeaders.authorizationHeader: 'Bearer $token',
  };
}
```

### Main Request Method
```dart
/// Send POST request with JSON body to backend
static Future<DiagnosisResponse> getNextStep({
  required List<String> facts,
  int? diagnosticResultId,
}) async {
  final url = _uri(ApiConstants.nextStep);
  
  debugPrint('\n═════════════════════════════════════════════════════════');
  debugPrint('[API] DIAGNOSTIC NEXT-STEP REQUEST');
  debugPrint('═════════════════════════════════════════════════════════');
  
  try {
    // 1. Create request object
    final request = NextStepRequest(
      facts: facts,
      diagnosticResultId: diagnosticResultId,
    );
    
    // 2. Serialize to JSON
    final requestBody = jsonEncode(request.toJson());
    
    debugPrint('[API] URL: $url');
    debugPrint('[API] Method: POST');
    debugPrint('[API] Request Body (JSON): $requestBody');
    
    // 3. Get headers with auth token
    final headers = await _authHeaders();
    
    debugPrint('[API] Headers:');
    headers.forEach((key, value) {
      final displayValue = key == 'Authorization' ? 'Bearer [TOKEN]' : value;
      debugPrint('[API]   $key: $displayValue');
    });
    
    // 4. Send POST request ✅ WITH BODY
    debugPrint('[API] Sending request...');
    final response = await http
        .post(
          url,
          headers: headers,
          body: requestBody,  // ✅ THIS IS THE KEY: JSON body as string
        )
        .timeout(const Duration(seconds: 20));
    
    // 5. Log response
    debugPrint('\n[API] RESPONSE RECEIVED');
    debugPrint('[API] Status Code: ${response.statusCode}');
    debugPrint('[API] Response Body: ${response.body}');
    
    // 6. Parse and return
    final data = _parseResponse(response, ApiConstants.nextStep)
        as Map<String, dynamic>;
    
    final diagResponse = DiagnosisResponse.fromJson(data);
    
    debugPrint('[API] ✓ Successfully parsed response');
    debugPrint('[API] Response Type: ${diagResponse.type}');
    debugPrint('═════════════════════════════════════════════════════════\n');
    
    return diagResponse;
    
  } on SocketException catch (e) {
    debugPrint('[API] ✗ SocketException: $e');
    debugPrint('═════════════════════════════════════════════════════════\n');
    throw ApiException('No internet connection. Check your network.');
  } on TimeoutException catch (e) {
    debugPrint('[API] ✗ TimeoutException: $e');
    debugPrint('═════════════════════════════════════════════════════════\n');
    throw ApiException('Request timed out. Please try again.');
  } catch (e) {
    debugPrint('[API] ✗ Unexpected error: $e');
    debugPrint('═════════════════════════════════════════════════════════\n');
    throw ApiException('Diagnostic step failed. Please try again.');
  }
}
```

---

## 3️⃣ Widget Usage (`lib/presentation/screens/06_assessment/assessment_question_screen.dart`)

### State Management
```dart
class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen> {
  final List<String> _facts = [];  // ✅ Accumulates answers
  DiagnosisResponse? _currentResponse;
  String? _selectedAnswer;
  
  @override
  void initState() {
    super.initState();
    _fetchNextStep();  // Load first question
  }
}
```

### Fetch Next Step
```dart
Future<void> _fetchNextStep() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // ✅ Send accumulated facts to backend
    final response = await ApiService.getNextStep(
      facts: _facts,  // e.g., ["Q1:Yes", "Q2:No"]
      diagnosticResultId: _currentResponse?.diagnosticResultId,
    );

    if (!mounted) return;

    if (response.type == 'diagnosis') {
      // Handle diagnosis
      await _handleDiagnosis(response);
    } else {
      // Show next question
      setState(() {
        _currentResponse = response;
        _isLoading = false;
      });
    }
  } on ApiException catch (e) {
    if (mounted) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }
}
```

### Handle User Answer
```dart
void _handleNext() {
  if (_selectedAnswer == null) {
    // Show validation error
    return;
  }

  final response = _currentResponse!;
  final questionCode = response.questionCode ?? '';
  
  // ✅ Append answer as fact in format: "QuestionCode:Answer"
  _facts.add('$questionCode:$_selectedAnswer');
  
  // Store for later batch save
  _answeredQuestions.add(_AnsweredQuestion(
    questionText: response.questionData?.text ?? questionCode,
    answer: _selectedAnswer!,
  ));

  // Fetch next question
  _fetchNextStep();
}
```

---

## 4️⃣ Constants (`lib/core/constants/api_constants.dart`)

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:5232';
  static const String nextStep = '/api/Diagnostic/next-step';
}
```

---

## 5️⃣ Storage Service (`lib/core/services/storage_service.dart`)

```dart
class StorageService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
}
```

---

## ✅ Complete Request Example

### Initial Request
```
POST /api/Diagnostic/next-step HTTP/1.1
Host: localhost:5232
Content-Type: application/json
Accept: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Length: 37

{"Facts":[],"DiagnosticResultId":null}
```

### Subsequent Request
```
POST /api/Diagnostic/next-step HTTP/1.1
Host: localhost:5232
Content-Type: application/json
Accept: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Length: 67

{"Facts":["Q1:Yes","Q2:No","Q3:Severe"],"DiagnosticResultId":1}
```

### Expected Response
```json
{
  "type": "diagnosis",
  "disease": "Eczema",
  "diagnosticResultId": 1,
  "confidence": 0.95
}
```

---

## 🧪 Testing with Postman

```javascript
// Pre-request Script (set token variable)
const token = pm.globals.get('auth_token');
pm.request.headers.add({
  key: 'Authorization',
  value: `Bearer ${token}`
});

// Body (raw JSON)
{
  "Facts": [
    "fever",
    "itching"
  ],
  "DiagnosticResultId": null
}
```

---

## ⚡ Quick Copy-Paste Fix

If your current `getNextStep()` is NOT sending body, replace the entire method with the code in section **2️⃣ API Service Call** above.

Key change:
```dart
// ❌ OLD (no body)
final response = await http.post(url, headers: headers);

// ✅ NEW (with body)
final response = await http.post(url, headers: headers, body: requestBody);
```

---

## 🔗 Imports Required

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
```

---

## 📝 Debug Log Output (What You Should See)

```
═════════════════════════════════════════════════════════
[API] DIAGNOSTIC NEXT-STEP REQUEST
═════════════════════════════════════════════════════════
[API] URL: http://localhost:5232/api/Diagnostic/next-step
[API] Method: POST
[API] Request Body (JSON): {"Facts":["Q1:Yes"],"DiagnosticResultId":1}
[API] Request Body Length: 53 bytes
[API] Headers:
[API]   Content-Type: application/json
[API]   Accept: application/json
[API]   Authorization: Bearer [TOKEN]
[API] Sending request...

[API] RESPONSE RECEIVED
[API] Status Code: 200
[API] Response Body: {"type":"question","questionCode":"Q2",...}
[API] ✓ Successfully parsed DiagnosisResponse
[API] Response Type: question
[API] Question Code: Q2
═════════════════════════════════════════════════════════
```

✅ If you see this output, the request body is being sent correctly!
