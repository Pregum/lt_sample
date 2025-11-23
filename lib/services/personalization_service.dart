import '../models/user_context.dart';

/// ユーザーのパーソナライゼーション管理サービス
class PersonalizationService {
  static UserContext _currentContext = UserContext.initial('user_001');

  /// 現在のユーザーコンテキストを取得
  static UserContext getCurrentContext() {
    return _currentContext;
  }

  /// ユーザーコンテキストを更新
  static void updateContext(UserContext context) {
    _currentContext = context;
  }

  /// アクションを記録
  static void recordAction(String action) {
    final updatedActions = [
      ..._currentContext.recentActions.take(9),
      action,
    ];

    _currentContext = _currentContext.copyWith(
      recentActions: updatedActions,
      lastActiveAt: DateTime.now(),
    );
  }

  /// 機能の使用回数を記録
  static void recordFeatureUsage(String featureName) {
    final currentCount = _currentContext.featureUsageCount[featureName] ?? 0;
    final updatedCounts = Map<String, int>.from(_currentContext.featureUsageCount);
    updatedCounts[featureName] = currentCount + 1;

    _currentContext = _currentContext.copyWith(
      featureUsageCount: updatedCounts,
      lastActiveAt: DateTime.now(),
    );
  }

  /// 興味を追加
  static void addInterest(String interest) {
    if (!_currentContext.interests.contains(interest)) {
      _currentContext = _currentContext.copyWith(
        interests: [..._currentContext.interests, interest],
      );
    }
  }

  /// 経験レベルを更新
  static void updateExperienceLevel(String level) {
    _currentContext = _currentContext.copyWith(
      experienceLevel: level,
    );
  }

  /// 初回ユーザーフラグを解除
  static void markAsExperiencedUser() {
    _currentContext = _currentContext.copyWith(
      isFirstTimeUser: false,
    );
  }

  /// デモ用: さまざまなユーザーコンテキストを生成
  static UserContext generateDemoContext(String type) {
    switch (type) {
      case 'beginner':
        return UserContext.initial('demo_beginner');

      case 'intermediate':
        return UserContext(
          userId: 'demo_intermediate',
          interests: ['Technology', 'Books'],
          experienceLevel: 'intermediate',
          recentActions: ['view_products', 'search', 'view_profile'],
          featureUsageCount: {'search': 5, 'profile': 3},
          lastActiveAt: DateTime.now(),
          isFirstTimeUser: false,
        );

      case 'advanced':
        return UserContext(
          userId: 'demo_advanced',
          interests: ['Technology', 'Fashion', 'Sports', 'Books'],
          experienceLevel: 'advanced',
          recentActions: [
            'view_products',
            'search',
            'view_profile',
            'add_to_cart',
            'checkout'
          ],
          featureUsageCount: {
            'search': 20,
            'profile': 10,
            'cart': 8,
            'checkout': 3
          },
          lastActiveAt: DateTime.now(),
          isFirstTimeUser: false,
        );

      default:
        return UserContext.initial('demo_default');
    }
  }
}
