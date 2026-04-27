# AI-Derma Diagnostic Flow - Complete Reference Guide

## Problem Overview
The C# backend endpoint `[HttpPost("next-step")]` expects a `NextStepRequestDto` with **PascalCase** properties:
- `Facts` (List<string>)
- `DiagnosticResultId` (int?)

However, Flutter was sending **camelCase** JSON keys, causing deserialization to fail.

---

## Solution: Full Diagnostic Flow

### 1️⃣ Data Models (Flutter)
**File:** `lib/core/models/diagnosis_model.dart`

```dart
/// Request model for next-step endpoint
class NextStepRequest {
  final List<String> facts;
  final int? diagnosticResultId;

  NextStepRequest({required this.facts, this.diagnosticResultId});

  /// ✅ Serializes with PascalCase keys to match C# DTO
  Map<String, dynamic> toJson() => {
        'Facts': facts,                    // ← PascalCase (matches C# property)
        'DiagnosticResultId': diagnosticResultId,
      };
}

/// Response model from next-step endpoint
class DiagnosisResponse {
  final String type;              // "question" or "diagnosis"
  final String? questionCode;     // Present when type == "question"
  final QuestionData? questionData;
  final String? disease;          // Present when type == "diagnosis"
  final double confidence;
  final int diagnosticResultId;   // Created by backend, used in subsequent requests
  
  // ... fromJson factory method
}
```

---

### 2️⃣ API Service (Flutter)
**File:** `lib/core/services/api_service.dart`

```dart
/// Calls POST /api/Diagnostic/next-step
/// [facts] - List of "questionCode:answer" strings accumulated from user selections
/// [diagnosticResultId] - Set after first response from backend
static Future<DiagnosisResponse> getNextStep({
  required List<String> facts,
  int? diagnosticResultId,
}) async {
  debugPrint(
      '[API] → POST ${ApiConstants.nextStep} (facts: ${facts.length})');
  try {
    // Create request object
    final request = NextStepRequest(
      facts: facts,
      diagnosticResultId: diagnosticResultId,
    );
    
    // ✅ Serialize to JSON with PascalCase keys
    final requestBody = jsonEncode(request.toJson());
    debugPrint('[API] Request body: $requestBody');
    // Output: {"Facts":[],"DiagnosticResultId":null}

    final headers = await _authHeaders();
    
    // Send POST request with JSON body
    final response = await http
        .post(
          _uri(ApiConstants.nextStep),
          headers: headers,
          body: requestBody,  // ✅ JSON body is sent here
        )
        .timeout(const Duration(seconds: 20));

    // Parse response and return DiagnosisResponse
    final data = _parseResponse(response, ApiConstants.nextStep)
        as Map<String, dynamic>;
    return DiagnosisResponse.fromJson(data);
  } on ApiException {
    rethrow;
  } on SocketException catch (e) {
    debugPrint('[API] ✗ SocketException (nextStep): $e');
    throw ApiException('No internet connection. Check your network.');
  } on TimeoutException catch (e) {
    debugPrint('[API] ✗ TimeoutException (nextStep): $e');
    throw ApiException('Request timed out. Please try again.');
  } catch (e) {
    debugPrint('[API] ✗ Unexpected error (nextStep): $e');
    throw ApiException('Diagnostic step failed. Please try again.');
  }
}
```

---

### 3️⃣ Assessment Question Screen (Flutter)
**File:** `lib/presentation/screens/06_assessment/assessment_question_screen.dart`

```dart
class _AssessmentQuestionScreenState extends State<AssessmentQuestionScreen> {
  // ─── State Management ───────────────────────────────────────────────────
  
  final List<String> _facts = [];  // ✅ Accumulates facts: ["Q1:Yes", "Q2:No", ...]
  final List<_AnsweredQuestion> _answeredQuestions = [];  // For saving answers later
  
  DiagnosisResponse? _currentResponse;  // Current question from backend
  String? _selectedAnswer;              // User's current selection
  bool _isLoading = true;
  int _stepNumber = 0;

  // ─── Lifecycle ─────────────────────────────────────────────────────────
  
  @override
  void initState() {
    super.initState();
    _fetchNextStep();  // ✅ Initial call with empty facts list
  }

  // ─── API Calls ─────────────────────────────────────────────────────────

  /// Sends accumulated facts to backend and receives next question or diagnosis
  Future<void> _fetchNextStep() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedAnswer = null;
    });

    try {
      // ✅ Send current facts list and diagnostic result ID
      final response = await ApiService.getNextStep(
        facts: _facts,  // e.g., ["Q1:Yes", "Q2:No"]
        diagnosticResultId: _currentResponse?.diagnosticResultId,
      );

      if (!mounted) return;

      if (response.type == 'diagnosis') {
        // ✅ Expert system has reached a diagnosis
        await _handleDiagnosis(response);
      } else {
        // ✅ Backend returned a question
        setState(() {
          _currentResponse = response;  // Store for rendering
          _stepNumber++;
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

  /// Handles diagnosis result and navigates to result screen
  Future<void> _handleDiagnosis(DiagnosisResponse response) async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      // Save all collected answers to backend
      if (_answeredQuestions.isNotEmpty) {
        final saveRequest = SaveAnswersRequest(
          diagnosticResultId: response.diagnosticResultId,
          answers: _answeredQuestions
              .map((q) => SaveAnswerItem(
                    questionText: q.questionText,
                    answer: q.answer,
                  ))
              .toList(),
        );
        await ApiService.saveAnswers(saveRequest);
      }

      if (mounted) {
        context.go(
          AppRouter.assessmentDetails,
          extra: {
            'diagnosticResultId': response.diagnosticResultId,
            'disease': response.disease ?? 'Unknown',
          },
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// ✅ Collects user answer and appends to facts list
  void _handleNext() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select an answer')),
      );
      return;
    }

    final response = _currentResponse!;
    final questionCode = response.questionCode ?? '';
    final questionText = response.questionData?.text ?? questionCode;

    // ✅ Append fact in format: "questionCode:answer"
    // Example: "Q1:Yes", "Q2:No", "Q3:Severe"
    _facts.add('$questionCode:$_selectedAnswer');

    // Store for later batch save
    _answeredQuestions.add(_AnsweredQuestion(
      questionText: questionText,
      answer: _selectedAnswer!,
    ));

    // ✅ Fetch next question (or diagnosis if complete)
    _fetchNextStep();
  }

  @override
  Widget build(BuildContext context) {
    // Render question UI with options and Next button
    // ...
  }
}
```

---

## Complete Request/Response Flow

### Step 1: Initial Load
```
Flutter initState()
    ↓
_fetchNextStep() with facts=[], diagnosticResultId=null
    ↓
POST /api/Diagnostic/next-step
Body: {"Facts":[],"DiagnosticResultId":null}
    ↓
C# Backend: Returns Question 1
Response: {
  "type": "question",
  "questionCode": "Q1",
  "questionData": { "text": "Do you have a rash?", "options": [...] },
  "diagnosticResultId": 1
}
    ↓
Flutter: Store response and render Q1
```

### Step 2-N: User Selects Answer
```
User taps "Yes" on Q1
    ↓
_handleNext()
    ├─ _facts.add("Q1:Yes")
    └─ _fetchNextStep()
    ↓
POST /api/Diagnostic/next-step
Body: {"Facts":["Q1:Yes"],"DiagnosticResultId":1}
    ↓
C# Backend: FastAPI processes facts, returns Question 2
Response: {
  "type": "question",
  "questionCode": "Q2",
  "questionData": { "text": "How long have you had it?", "options": [...] },
  "diagnosticResultId": 1
}
    ↓
Flutter: Store response and render Q2
```

### Step N+1: Diagnosis Reached
```
User answers final question
    ↓
_handleNext()
    ├─ _facts.add("QN:SomeAnswer")
    └─ _fetchNextStep()
    ↓
POST /api/Diagnostic/next-step
Body: {"Facts":["Q1:Yes","Q2:No",...,"QN:SomeAnswer"],"DiagnosticResultId":1}
    ↓
C# Backend: FastAPI returns diagnosis
Response: {
  "type": "diagnosis",
  "disease": "Eczema",
  "diagnosticResultId": 1
}
    ↓
Flutter:
    ├─ Save answers via saveAnswers() endpoint
    ├─ Navigate to result screen
    └─ Display disease name and details
```

---

## Key Points ✅

| Aspect | Details |
|--------|---------|
| **JSON Serialization** | Use PascalCase keys: `Facts`, `DiagnosticResultId` |
| **Facts Format** | `"QuestionCode:Answer"` e.g., `"Q1:Yes"`, `"Q2:Severe"` |
| **Accumulation** | Facts list grows with each answer (e.g., `["Q1:Yes", "Q2:No"]`) |
| **DiagnosticResultId** | Set by backend on first response, passed in subsequent requests |
| **Error Handling** | Check debug logs: `[API] Request body: $requestBody` |

---

## Debugging Checklist

- [ ] Check Flutter debug logs for `[API] Request body:` to verify JSON structure
- [ ] Verify C# controller receives non-null `NextStepRequestDto`
- [ ] Ensure `Facts` is not null/empty on first request (empty list is OK)
- [ ] Confirm JSON keys are PascalCase in Flutter `toJson()` method
- [ ] Verify backend returns `diagnosticResultId` in response
