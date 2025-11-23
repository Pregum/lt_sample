import 'package:equatable/equatable.dart';

enum SuggestionType {
  onboarding,
  search,
  completion,
  recommendation,
  errorResolution,
  nextAction,
}

/// AI が生成した提案・サジェストを表すモデル
class AISuggestion extends Equatable {
  final String id;
  final SuggestionType type;
  final String title;
  final String description;
  final double confidence; // 0.0 - 1.0
  final List<String> keywords;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const AISuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.confidence = 0.8,
    this.keywords = const [],
    required this.createdAt,
    this.metadata,
  });

  factory AISuggestion.onboarding({
    required String title,
    required String description,
  }) {
    return AISuggestion(
      id: 'suggest_${DateTime.now().millisecondsSinceEpoch}',
      type: SuggestionType.onboarding,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  factory AISuggestion.search({
    required String keyword,
    required String description,
  }) {
    return AISuggestion(
      id: 'suggest_${DateTime.now().millisecondsSinceEpoch}',
      type: SuggestionType.search,
      title: keyword,
      description: description,
      keywords: [keyword],
      createdAt: DateTime.now(),
    );
  }

  factory AISuggestion.recommendation({
    required String title,
    required String description,
    double confidence = 0.8,
  }) {
    return AISuggestion(
      id: 'suggest_${DateTime.now().millisecondsSinceEpoch}',
      type: SuggestionType.recommendation,
      title: title,
      description: description,
      confidence: confidence,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        confidence,
        keywords,
        createdAt,
        metadata,
      ];
}

/// AIチャットメッセージ
class AIChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  const AIChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isTyping = false,
  });

  factory AIChatMessage.user(String content) {
    return AIChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory AIChatMessage.assistant(String content, {bool isTyping = false}) {
    return AIChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      isTyping: isTyping,
    );
  }

  @override
  List<Object?> get props => [id, content, isUser, timestamp, isTyping];
}
