// lib/core/models/chat_model.dart

/// Models for the AI chat assistant feature.

class ChatRequest {
  final String sessionId;
  final String message;
  final String condition;

  ChatRequest({
    required this.sessionId,
    required this.message,
    this.condition = '',
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'message': message,
        'condition': condition,
      };
}

class ChatResponse {
  final String reply;

  ChatResponse({required this.reply});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      reply: json['reply'] as String? ?? '',
    );
  }
}

class ChatWelcomeResponse {
  final String sessionId;
  final String reply;

  ChatWelcomeResponse({required this.sessionId, required this.reply});

  factory ChatWelcomeResponse.fromJson(Map<String, dynamic> json) {
    return ChatWelcomeResponse(
      sessionId: json['sessionId'] as String? ?? '',
      reply: json['reply'] as String? ?? '',
    );
  }
}
