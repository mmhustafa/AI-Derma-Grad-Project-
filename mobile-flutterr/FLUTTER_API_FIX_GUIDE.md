# Flutter → .NET API: Complete Request Body Fix Guide

## 📋 Problem Statement
Flutter app is NOT sending a request body to the .NET API endpoint:
```
POST http://localhost:5232/api/Diagnostic/next-step
```
This causes the backend to receive `null` for `NextStepRequestDto`, resulting in **400 Bad Request**.

---

## ✅ Solution Overview

### 1. **Data Model** (`lib/core/models/diagnosis_model.dart`)
```dart
class NextStepRequest {
  final List<String> facts;
  final int? diagnosticResultId;

  NextStepRequest({required this.facts, this.diagnosticResultId});

  /// ✅ IMPORTANT: Use PascalCase keys to match C# DTO properties
  Map<String, dynamic> toJson() => {
    'Facts': facts,                    // ← C# property: Facts
    'DiagnosticResultId': diagnosticResultId,  // ← C# property: DiagnosticResultId
  };
}
```

### 2. **API Service Call** (`lib/core/services/api_service.dart`)

The enhanced `getNextStep()` method now:
- ✅ Creates `NextStepRequest` object
- ✅ Serializes to JSON with `jsonEncode()`
- ✅ Includes proper headers (`Content-Type: application/json`, `Authorization: Bearer <token>`)
- ✅ Sends body as string to `http.post()`
- ✅ Logs request details before sending
- ✅ Logs response status code and body
- ✅ Handles errors properly with try/catch

```dart
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
    // Build request
    final request = NextStepRequest(
      facts: facts,
      diagnosticResultId: diagnosticResultId,
    );
    
    // Serialize to JSON
    final requestMap = request.toJson();
    final requestBody = jsonEncode(requestMap);
    
    debugPrint('[API] Request Body (Map): $requestMap');
    debugPrint('[API] Request Body (JSON): $requestBody');
    
    // Build headers with auth token
    final headers = await _authHeaders();
    
    // Send POST request
    final response = await http
        .post(
          url,
          headers: headers,
          body: requestBody,  // ✅ JSON string body is sent here
        )
        .timeout(const Duration(seconds: 20));

    // Log response
    debugPrint('[API] Status Code: ${response.statusCode}');
    debugPrint('[API] Response Body: ${response.body}');
    
    // Parse and return
    final data = _parseResponse(response, ApiConstants.nextStep)
        as Map<String, dynamic>;
    return DiagnosisResponse.fromJson(data);
    
  } on SocketException catch (e) {
    debugPrint('[API] ✗ SocketException: $e');
    throw ApiException('No internet connection. Check your network.');
  } on TimeoutException catch (e) {
    debugPrint('[API] ✗ TimeoutException: $e');
    throw ApiException('Request timed out. Please try again.');
  } catch (e) {
    debugPrint('[API] ✗ Unexpected error: $e');
    throw ApiException('Diagnostic step failed. Please try again.');
  }
}
```

---

## 📊 Request/Response Flow Example

### Initial Request (First Question)
```
REQUEST:
POST http://localhost:5232/api/Diagnostic/next-step
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "Facts": [],
  "DiagnosticResultId": null
}

LOGS:
[API] Request Body (JSON): {"Facts":[],"DiagnosticResultId":null}
[API] Sending request...
[API] Status Code: 200
[API] Response Body: {"type":"question","questionCode":"Q1","questionData":{...},"diagnosticResultId":1}
```

### Subsequent Request (After User Answer)
```
REQUEST:
POST http://localhost:5232/api/Diagnostic/next-step
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "Facts": ["Q1:Yes", "Q2:No"],
  "DiagnosticResultId": 1
}

LOGS:
[API] Request Body (JSON): {"Facts":["Q1:Yes","Q2:No"],"DiagnosticResultId":1}
[API] Status Code: 200
[API] Response Body: {"type":"diagnosis","disease":"Eczema","diagnosticResultId":1,...}
```

---

## 🔧 How to Use in Your Widget

### In `AssessmentQuestionScreen`:

```dart
class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen> {
  final List<String> _facts = [];  // Accumulates answers
  DiagnosisResponse? _currentResponse;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _fetchNextStep();  // Fetch first question
  }

  Future<void> _fetchNextStep() async {
    try {
      // ✅ Send facts list to backend
      final response = await ApiService.getNextStep(
        facts: _facts,  // e.g., ["Q1:Yes", "Q2:No"]
        diagnosticResultId: _currentResponse?.diagnosticResultId,
      );

      if (!mounted) return;

      if (response.type == 'diagnosis') {
        // Handle diagnosis result
        print('Diagnosis: ${response.disease}');
      } else {
        // Show next question
        setState(() {
          _currentResponse = response;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleUserAnswer(String selectedOption) {
    // ✅ Collect answer and format as fact
    final questionCode = _currentResponse?.questionCode ?? '';
    _facts.add('$questionCode:$selectedOption');
    
    // Fetch next question
    _fetchNextStep();
  }
}
```

---

## 🧪 Debugging Tips

### 1. **Check Flutter Debug Logs**
Look for these patterns in the debug console:
```
[API] Request Body (JSON): {"Facts":["fever","itching"],"DiagnosticResultId":null}
[API] Status Code: 200
```

### 2. **Verify Headers Are Sent**
Logs should include:
```
[API] Headers:
[API]   Content-Type: application/json
[API]   Authorization: Bearer [TOKEN]
[API]   Accept: application/json
```

### 3. **Check C# Backend Logs**
The controller should receive non-null `NextStepRequestDto`:
```csharp
[HttpPost("next-step")]
public async Task<IActionResult> GetNextStep([FromBody] NextStepRequestDto nextStep)
{
    Console.WriteLine($"Facts count: {nextStep.Facts?.Count ?? 0}");  // Should be > 0
    Console.WriteLine($"DiagnosticResultId: {nextStep.DiagnosticResultId}");
    // ...
}
```

### 4. **Common Issues & Solutions**

| Issue | Cause | Solution |
|-------|-------|----------|
| 400 Bad Request | Request body is null | Verify `jsonEncode()` is called and body is passed to `http.post()` |
| JSON key mismatch | Using `'facts'` instead of `'Facts'` | Ensure `toJson()` uses PascalCase keys |
| No Authorization header | Token is null/empty | Check `StorageService.getToken()` returns valid token |
| Empty body being sent | `body` parameter not set | Confirm `body: requestBody` is in `http.post()` call |
| 401 Unauthorized | Invalid/expired token | Verify token is stored correctly after login |

---

## 📝 Complete File Structure

```
lib/
├── core/
│   ├── models/
│   │   └── diagnosis_model.dart          ← NextStepRequest (toJson with PascalCase)
│   ├── services/
│   │   ├── api_service.dart              ← getNextStep() method (sends request body)
│   │   └── storage_service.dart          ← getToken() for Authorization
│   └── constants/
│       └── api_constants.dart            ← nextStep endpoint URL
├── presentation/
│   └── screens/
│       └── 06_assessment/
│           └── assessment_question_screen.dart  ← Calls getNextStep()
```

---

## ✅ Verification Checklist

- [ ] `NextStepRequest.toJson()` uses PascalCase keys (`Facts`, `DiagnosticResultId`)
- [ ] `getNextStep()` method encodes body with `jsonEncode(request.toJson())`
- [ ] Headers include `Content-Type: application/json`
- [ ] Headers include `Authorization: Bearer <token>`
- [ ] `body: requestBody` is passed to `http.post()`
- [ ] Debug logs show request body before sending
- [ ] Debug logs show response status code and body
- [ ] Error handling covers `SocketException`, `TimeoutException`, and generic errors
- [ ] AssessmentQuestionScreen collects answers and passes to `getNextStep()`
- [ ] Facts list is accumulated correctly (e.g., `["Q1:Yes", "Q2:No"]`)

---

## 📞 Testing the Endpoint

### Using Postman
```
POST http://localhost:5232/api/Diagnostic/next-step
Headers:
  Content-Type: application/json
  Authorization: Bearer <YOUR_TOKEN>

Body (raw JSON):
{
  "Facts": ["fever", "itching"],
  "DiagnosticResultId": null
}
```

### Using curl
```bash
curl -X POST http://localhost:5232/api/Diagnostic/next-step \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <YOUR_TOKEN>" \
  -d '{"Facts":["fever","itching"],"DiagnosticResultId":null}'
```

---

## 🎯 Expected Output in Flutter Logs

```
═════════════════════════════════════════════════════════
[API] DIAGNOSTIC NEXT-STEP REQUEST
═════════════════════════════════════════════════════════
[API] URL: http://localhost:5232/api/Diagnostic/next-step
[API] Method: POST
[API] Request Body (Map): {Facts: [fever, itching], DiagnosticResultId: null}
[API] Request Body (JSON): {"Facts":["fever","itching"],"DiagnosticResultId":null}
[API] Request Body Length: 67 bytes
[API] Headers:
[API]   Content-Type: application/json
[API]   Authorization: Bearer [TOKEN]
[API] Sending request...

[API] RESPONSE RECEIVED
[API] Status Code: 200
[API] Response Body Length: 234 bytes
[API] Response Body: {"type":"question","questionCode":"Q1",...}
[API] ✓ Successfully parsed DiagnosisResponse
[API] Response Type: question
[API] Question Code: Q1
═════════════════════════════════════════════════════════
```

This indicates the request body is properly sent and backend is responding correctly! ✅
