// lib/core/models/metadata_model.dart

/// Models for Knowledge Base metadata.

/// Represents the complete Knowledge Base metadata response.
class KnowledgeBaseMetadata {
  final List<MetadataQuestion> questions;

  KnowledgeBaseMetadata({required this.questions});

  factory KnowledgeBaseMetadata.fromJson(Map<String, dynamic> json) {
    List<MetadataQuestion> questions = [];

    final questionsData = json['questions'];
    if (questionsData is List) {
      questions = questionsData
          .map((q) => MetadataQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    }

    return KnowledgeBaseMetadata(questions: questions);
  }
}

/// Represents a question with its options from the metadata.
class MetadataQuestion {
  final String code;
  final String label;
  final List<MetadataOption> options;

  MetadataQuestion({
    required this.code,
    required this.label,
    required this.options,
  });

  factory MetadataQuestion.fromJson(Map<String, dynamic> json) {
    List<MetadataOption> options = [];

    final optionsData = json['options'];
    if (optionsData is List) {
      options = optionsData
          .map((o) => MetadataOption.fromJson(o as Map<String, dynamic>))
          .toList();
    } else if (optionsData is Map<String, dynamic>) {
      // If options is a map of val → label
      optionsData.forEach((val, label) {
        options.add(MetadataOption(
          val: val,
          label: label.toString(),
        ));
      });
    }

    return MetadataQuestion(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      options: options,
    );
  }
}

/// Represents an option with both val (to send to backend) and label (to show user).
class MetadataOption {
  final String val; // The value to send to the backend (e.g., "type:0-1")
  final String
      label; // The label to display to the user (e.g., "Skin rashes WITHOUT fever")

  MetadataOption({
    required this.val,
    required this.label,
  });

  factory MetadataOption.fromJson(Map<String, dynamic> json) {
    return MetadataOption(
      val: json['val'] as String? ?? json['value'] as String? ?? '',
      label: json['label'] as String? ?? json['text'] as String? ?? '',
    );
  }
}

/// Represents a confirmation question for symptom verification.
/// Returned by GET /api/Metadata/confirmation/{diseaseName}
class ConfirmationQuestion {
  final String code;
  final String text;

  ConfirmationQuestion({
    required this.code,
    required this.text,
  });

  factory ConfirmationQuestion.fromJson(Map<String, dynamic> json) {
    return ConfirmationQuestion(
      code: json['questionCode'] as String? ?? json['code'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

/// Response from GET /api/Metadata/confirmation/{diseaseName}
class ConfirmationQuestionsResponse {
  final List<ConfirmationQuestion> questions;

  ConfirmationQuestionsResponse({required this.questions});

  factory ConfirmationQuestionsResponse.fromJson(dynamic json) {
    List<ConfirmationQuestion> questions = [];

    if (json is List) {
      // Direct array response
      questions = json
          .map((q) => ConfirmationQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    } else if (json is Map<String, dynamic>) {
      // Object wrapper with 'questions' field
      if (json['questions'] is List) {
        questions = (json['questions'] as List)
            .map(
                (q) => ConfirmationQuestion.fromJson(q as Map<String, dynamic>))
            .toList();
      } else {
        // Try to parse the map entries as questions
        json.entries.forEach((entry) {
          if (entry.value is Map) {
            questions.add(ConfirmationQuestion.fromJson(
                entry.value as Map<String, dynamic>));
          } else {
            questions.add(ConfirmationQuestion(
              code: entry.key,
              text: entry.value.toString(),
            ));
          }
        });
      }
    }

    return ConfirmationQuestionsResponse(questions: questions);
  }
}
