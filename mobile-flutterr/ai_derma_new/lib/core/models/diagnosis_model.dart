// lib/core/models/diagnosis_model.dart

/// Models for the diagnostic flow, disease details, and saving answers.

// ─── Next-Step Request ────────────────────────────────────────────────────────

class NextStepRequest {
  final List<String> facts;
  final int? diagnosticResultId;

  NextStepRequest({required this.facts, this.diagnosticResultId});

  /// Serializes to JSON with lowercase field names as required by the backend.
  /// Backend expects: facts (list of option.val), diagnosticResultId
  Map<String, dynamic> toJson() => {
        'facts': facts,
        'diagnosticResultId': diagnosticResultId,
      };
}

// ─── Next-Step Response ───────────────────────────────────────────────────────

/// Returned by POST /api/Diagnostic/next-step.
/// [type] is either "question" or "diagnosis".
class DiagnosisResponse {
  final String type;

  // Present when type == "question"
  final String? questionCode;
  final QuestionData? questionData;

  // Present when type == "diagnosis"
  final String? disease;
  final double confidence;

  // Always present once a DiagnosticResult row is created
  final int diagnosticResultId;

  DiagnosisResponse({
    required this.type,
    this.questionCode,
    this.questionData,
    this.disease,
    this.confidence = 0,
    required this.diagnosticResultId,
  });

  factory DiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisResponse(
      type: json['type'] as String,
      questionCode: json['questionCode'] as String?,
      questionData: json['questionData'] != null
          ? QuestionData.fromJson(json['questionData'] as Map<String, dynamic>)
          : null,
      disease: json['disease'] as String?,
      confidence: (json['confidence'] ?? 0).toDouble(),
      diagnosticResultId: json['diagnosticResultId'] as int? ?? 0,
    );
  }
}

/// Represents the question metadata returned from the knowledge-base.
class QuestionData {
  final String text;
  final List<QuestionOption> options;

  QuestionData({required this.text, required this.options});

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    List<QuestionOption> opts = [];

    if (rawOptions is List) {
      // options is a list of strings or objects
      for (final o in rawOptions) {
        if (o is String) {
          opts.add(QuestionOption(value: o, label: o));
        } else if (o is Map<String, dynamic>) {
          opts.add(QuestionOption.fromJson(o));
        }
      }
    } else if (rawOptions is Map<String, dynamic>) {
      // options is a map of value → label
      rawOptions.forEach((key, value) {
        opts.add(QuestionOption(value: key, label: value.toString()));
      });
    }

    // Fallback: if no options parsed, provide Yes/No defaults
    if (opts.isEmpty) {
      opts = [
        QuestionOption(value: 'yes', label: 'Yes'),
        QuestionOption(value: 'no', label: 'No'),
      ];
    }

    return QuestionData(
      text: (json['text'] ?? json['question'] ?? '') as String,
      options: opts,
    );
  }
}

class QuestionOption {
  final String value;
  final String label;

  QuestionOption({required this.value, required this.label});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    // Backend sends 'val' (not 'value') in the response
    final rawValue = json['val']?.toString() ?? json['value']?.toString() ?? '';
    final rawLabel = json['label']?.toString() ??
        json['text']?.toString() ??
        json['name']?.toString() ??
        '';
    return QuestionOption(
      // If the API sends no 'val'/'value', use the label as the value.
      // This prevents empty-string values that cause duplicate widget keys.
      value: rawValue.isNotEmpty ? rawValue : rawLabel,
      label: rawLabel.isNotEmpty ? rawLabel : rawValue,
    );
  }

  /// Stable identity string used for keying and selection comparison.
  /// Never empty — falls back to label, then 'unknown'.
  String get id =>
      value.isNotEmpty ? value : (label.isNotEmpty ? label : 'unknown');
}

// ─── Disease Details ──────────────────────────────────────────────────────────

class DiseaseDetails {
  final String diseaseName;
  final String description;
  final String severityLevel;
  final String careInstructions;

  DiseaseDetails({
    required this.diseaseName,
    required this.description,
    required this.severityLevel,
    required this.careInstructions,
  });

  factory DiseaseDetails.fromJson(Map<String, dynamic> json) {
    return DiseaseDetails(
      diseaseName: json['diseaseName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      severityLevel: json['severityLevel'] as String? ?? '',
      careInstructions: json['careInstructions'] as String? ?? '',
    );
  }
}

// ─── Save Answers ─────────────────────────────────────────────────────────────

class SaveAnswerItem {
  final String questionText;
  final String answer;

  SaveAnswerItem({required this.questionText, required this.answer});

  Map<String, dynamic> toJson() => {
        'questionText': questionText,
        'answer': answer,
      };
}

class SaveAnswersRequest {
  final int diagnosticResultId;
  final List<SaveAnswerItem> answers;

  SaveAnswersRequest({
    required this.diagnosticResultId,
    required this.answers,
  });

  Map<String, dynamic> toJson() => {
        'diagnosticResultId': diagnosticResultId,
        'answers': answers.map((a) => a.toJson()).toList(),
      };
}
