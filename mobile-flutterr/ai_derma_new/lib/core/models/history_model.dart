// lib/core/models/history_model.dart

/// Models for history list and diagnostic detail views.

// ─── History List Item ────────────────────────────────────────────────────────

class DiagnosticHistoryItem {
  final int id;
  final String? diseaseName;
  final String? sourceType;
  final double? confidenceScore;
  final String? createdAt;

  DiagnosticHistoryItem({
    required this.id,
    this.diseaseName,
    this.sourceType,
    this.confidenceScore,
    this.createdAt,
  });

  factory DiagnosticHistoryItem.fromJson(Map<String, dynamic> json) {
    // The backend may nest disease info — handle both flat and nested shapes.
    final diseaseNested = json['disease'] as Map<String, dynamic>?;
    return DiagnosticHistoryItem(
      id: json['id'] as int? ?? 0,
      diseaseName: diseaseNested?['diseaseName'] as String? ??
          json['diseaseName'] as String?,
      sourceType: json['sourceType'] as String?,
      confidenceScore: json['confidenceScore'] != null
          ? (json['confidenceScore'] as num).toDouble()
          : null,
      createdAt: json['createdAt'] as String? ??
          json['date'] as String?,
    );
  }
}

// ─── Symptom Answer ───────────────────────────────────────────────────────────

class SymptomAnswer {
  final int id;
  final String questionText;
  final String userAnswer;

  SymptomAnswer({
    required this.id,
    required this.questionText,
    required this.userAnswer,
  });

  factory SymptomAnswer.fromJson(Map<String, dynamic> json) {
    return SymptomAnswer(
      id: json['id'] as int? ?? 0,
      questionText: json['questionText'] as String? ?? '',
      userAnswer: json['userAnswer'] as String? ?? '',
    );
  }
}

// ─── Diagnostic Detail ────────────────────────────────────────────────────────

class DiagnosticDetail {
  final int id;
  final String? diseaseName;
  final String? sourceType;
  final double? confidenceScore;
  final String? createdAt;
  final List<SymptomAnswer> symptomAnswers;

  DiagnosticDetail({
    required this.id,
    this.diseaseName,
    this.sourceType,
    this.confidenceScore,
    this.createdAt,
    required this.symptomAnswers,
  });

  factory DiagnosticDetail.fromJson(Map<String, dynamic> json) {
    final diseaseNested = json['disease'] as Map<String, dynamic>?;
    final rawAnswers = json['symptomAnswers'] as List<dynamic>? ?? [];
    return DiagnosticDetail(
      id: json['id'] as int? ?? 0,
      diseaseName: diseaseNested?['diseaseName'] as String? ??
          json['diseaseName'] as String?,
      sourceType: json['sourceType'] as String?,
      confidenceScore: json['confidenceScore'] != null
          ? (json['confidenceScore'] as num).toDouble()
          : null,
      createdAt: json['createdAt'] as String? ?? json['date'] as String?,
      symptomAnswers: rawAnswers
          .map((e) => SymptomAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
