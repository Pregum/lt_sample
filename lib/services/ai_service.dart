import 'dart:math';
import '../models/user_context.dart';
import '../models/ai_suggestion.dart';

/// AI機能のモックサービス
/// 実際のAI APIを使用せず、ローカルで動作するシミュレーション
class AIService {
  static final Random _random = Random();

  /// Blank State: パーソナライズされたオンボーディング提案
  static Future<List<AISuggestion>> generateOnboardingSuggestions(
    UserContext context,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final suggestions = <AISuggestion>[];

    if (context.isFirstTimeUser) {
      suggestions.add(AISuggestion.onboarding(
        title: 'はじめてのご利用ですね',
        description: 'チュートリアルで基本機能を学びましょう。所要時間: 約2分',
      ));

      suggestions.add(AISuggestion.onboarding(
        title: 'サンプルデータで試す',
        description: 'サンプルデータを読み込んで、すぐに機能を体験できます',
      ));
    }

    if (context.interests.isEmpty) {
      suggestions.add(AISuggestion.onboarding(
        title: '興味のあるカテゴリを設定',
        description: 'あなたに合ったコンテンツを表示するために、興味を教えてください',
      ));
    }

    return suggestions;
  }

  /// Loading State: 動的なローディングメッセージ生成
  static Future<String> generateLoadingMessage(
    UserContext context,
    int progress,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final messages = [
      'データを準備しています...',
      'もうすぐ完了します...',
      'あなたに最適な情報を検索中...',
      '最新の情報を取得しています...',
      'おすすめのコンテンツを探しています...',
    ];

    if (progress < 30) {
      return messages[0];
    } else if (progress < 60) {
      return messages[1];
    } else if (progress < 90) {
      return messages[2];
    } else {
      return messages[3];
    }
  }

  /// Loading State: 予測的プリフェッチの候補生成
  static Future<List<String>> predictNextActions(
    UserContext context,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final predictions = <String>[];

    if (context.recentActions.contains('view_products')) {
      predictions.add('商品詳細を表示');
      predictions.add('カートに追加');
    }

    if (context.recentActions.contains('search')) {
      predictions.add('検索結果をフィルタ');
      predictions.add('関連商品を表示');
    }

    if (context.featureUsageCount['profile'] != null &&
        context.featureUsageCount['profile']! > 3) {
      predictions.add('プロフィールを編集');
    }

    return predictions.isEmpty
        ? ['ダッシュボードに戻る', '検索を開始']
        : predictions;
  }

  /// Error State: コンテキストに応じたエラーメッセージ生成
  static Future<String> generateContextualErrorMessage(
    String errorType,
    UserContext context,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    switch (errorType) {
      case 'network':
        if (context.isFirstTimeUser) {
          return '接続に失敗しました。Wi-Fiまたはモバイルデータが有効か確認してください。';
        } else {
          return 'ネットワークエラーが発生しました。オフラインモードで閲覧できるデータがあります。';
        }

      case 'not_found':
        return '指定された${context.recentActions.last}が見つかりませんでした。別のキーワードで検索してみてください。';

      case 'auth':
        if (context.isFirstTimeUser) {
          return 'この機能を使うにはログインが必要です。アカウント作成は30秒で完了します。';
        } else {
          return 'セッションの有効期限が切れました。もう一度ログインしてください。';
        }

      default:
        return 'エラーが発生しました。時間をおいて再度お試しください。';
    }
  }

  /// Error State: 解決策の提案
  static Future<List<String>> suggestErrorResolutions(
    String errorType,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    switch (errorType) {
      case 'network':
        return [
          'Wi-Fi接続を確認する',
          'モバイルデータをONにする',
          'オフラインモードで閲覧する',
        ];

      case 'not_found':
        return [
          '検索キーワードを変更する',
          'カテゴリから探す',
          '人気の商品を見る',
        ];

      case 'auth':
        return [
          'ログインする',
          'パスワードを再設定する',
          'ゲストとして続ける',
        ];

      default:
        return [
          'ページを再読み込みする',
          'アプリを再起動する',
          'サポートに問い合わせる',
        ];
    }
  }

  /// Partial State: 入力補完候補の生成
  static Future<List<String>> generateAutoCompletions(
    String input,
    UserContext context,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final suggestions = <String>[];

    // ユーザーの興味に基づく候補
    for (var interest in context.interests) {
      if (interest.toLowerCase().contains(input.toLowerCase())) {
        suggestions.add(interest);
      }
    }

    // 一般的な候補
    final commonSuggestions = [
      'Electronics',
      'Clothing',
      'Books',
      'Home & Kitchen',
      'Sports & Outdoors',
      'Technology',
      'Fashion',
      'Food',
    ];

    for (var suggestion in commonSuggestions) {
      if (suggestion.toLowerCase().contains(input.toLowerCase()) &&
          !suggestions.contains(suggestion)) {
        suggestions.add(suggestion);
      }
    }

    return suggestions.take(5).toList();
  }

  /// Ideal State: パーソナライズされたコンテンツ推薦
  static Future<List<AISuggestion>> generateRecommendations(
    UserContext context,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final recommendations = <AISuggestion>[];

    // 興味に基づく推薦
    for (var interest in context.interests) {
      recommendations.add(AISuggestion.recommendation(
        title: '$interest の新着',
        description: 'あなたの興味に基づいて、$interest カテゴリの最新アイテムをご紹介',
        confidence: 0.9,
      ));
    }

    // 行動履歴に基づく推薦
    if (context.recentActions.contains('view_products')) {
      recommendations.add(AISuggestion.recommendation(
        title: '最近見た商品の関連商品',
        description: '閲覧履歴から、あなたが興味を持ちそうな商品を見つけました',
        confidence: 0.85,
      ));
    }

    // 人気商品
    recommendations.add(AISuggestion.recommendation(
      title: '今週の人気商品',
      description: '多くのユーザーが購入している商品です',
      confidence: 0.75,
    ));

    return recommendations.take(3).toList();
  }

  /// Ideal State: AIチャットアシスタントの応答生成
  static Future<String> generateChatResponse(
    String userMessage,
    UserContext context,
  ) async {
    // タイプライター効果のための遅延
    await Future.delayed(const Duration(milliseconds: 1500));

    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hello') ||
        lowerMessage.contains('hi') ||
        lowerMessage.contains('こんにちは')) {
      return 'こんにちは！何かお手伝いできることはありますか？';
    }

    if (lowerMessage.contains('help') ||
        lowerMessage.contains('助けて') ||
        lowerMessage.contains('ヘルプ')) {
      return '以下の機能をご利用いただけます：\n'
          '• 商品検索\n'
          '• プロフィール編集\n'
          '• おすすめ商品の表示\n\n'
          '具体的に知りたいことを教えてください！';
    }

    if (lowerMessage.contains('search') ||
        lowerMessage.contains('検索') ||
        lowerMessage.contains('探す')) {
      return '検索機能をお探しですね。画面上部の検索バーから、商品名やカテゴリで検索できます。'
          '例えば「Electronics」や「Fashion」などのキーワードをお試しください。';
    }

    if (lowerMessage.contains('profile') ||
        lowerMessage.contains('プロフィール')) {
      return 'プロフィール画面では、個人情報の編集や興味のカテゴリ設定ができます。'
          '右下のプロフィールアイコンからアクセスできます。';
    }

    if (lowerMessage.contains('recommend') ||
        lowerMessage.contains('おすすめ')) {
      final interests =
          context.interests.isEmpty ? 'まだ設定されていません' : context.interests.join('、');
      return 'あなたの興味（$interests）に基づいて、おすすめ商品を表示しています。'
          'プロフィールで興味を追加すると、より精度の高い推薦が受けられます。';
    }

    // デフォルト応答
    return 'ご質問ありがとうございます。「ヘルプ」と入力すると、利用可能な機能の一覧が表示されます。';
  }

  /// Partial State: スマートなフォーム補完
  static Future<Map<String, String>> suggestFormCompletions(
    Map<String, String> currentData,
    UserContext context,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final suggestions = <String, String>{};

    // ユーザーコンテキストから補完候補を生成
    if (!currentData.containsKey('language') ||
        currentData['language']!.isEmpty) {
      suggestions['language'] = context.preferredLanguage;
    }

    if (!currentData.containsKey('interests') ||
        currentData['interests']!.isEmpty) {
      suggestions['interests'] = context.interests.join(', ');
    }

    return suggestions;
  }
}
