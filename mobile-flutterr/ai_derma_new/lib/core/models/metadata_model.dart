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
