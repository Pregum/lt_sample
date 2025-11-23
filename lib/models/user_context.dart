import 'package:equatable/equatable.dart';

/// ユーザーのコンテキスト情報を保持するモデル
/// AI機能のパーソナライゼーションに使用
class UserContext extends Equatable {
  final String userId;
  final List<String> interests;
  final String experienceLevel; // beginner, intermediate, advanced
  final List<String> recentActions;
  final Map<String, int> featureUsageCount;
  final DateTime lastActiveAt;
  final String preferredLanguage;
  final bool isFirstTimeUser;

  const UserContext({
    required this.userId,
    this.interests = const [],
    this.experienceLevel = 'beginner',
    this.recentActions = const [],
    this.featureUsageCount = const {},
    required this.lastActiveAt,
    this.preferredLanguage = 'ja',
    this.isFirstTimeUser = true,
  });

  factory UserContext.initial(String userId) {
    return UserContext(
      userId: userId,
      lastActiveAt: DateTime.now(),
      isFirstTimeUser: true,
    );
  }

  UserContext copyWith({
    String? userId,
    List<String>? interests,
    String? experienceLevel,
    List<String>? recentActions,
    Map<String, int>? featureUsageCount,
    DateTime? lastActiveAt,
    String? preferredLanguage,
    bool? isFirstTimeUser,
  }) {
    return UserContext(
      userId: userId ?? this.userId,
      interests: interests ?? this.interests,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      recentActions: recentActions ?? this.recentActions,
      featureUsageCount: featureUsageCount ?? this.featureUsageCount,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        interests,
        experienceLevel,
        recentActions,
        featureUsageCount,
        lastActiveAt,
        preferredLanguage,
        isFirstTimeUser,
      ];
}
